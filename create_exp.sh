#!/bin/bash

# Get script name
SCRIPT=$(basename "$0")

FASTQ=''
while (( "$#" )); do
  case "$1" in
    -i|--visium-id)
      VISIUMID=$2
      shift 2
      ;;
    -o|--output)
      OUTPUT=$2
      shift 2
      ;;
    -a|--areas)
      AREAS=$2
      shift 2
      ;;
    --reference-genome)
      REF=$2
      shift 2
      ;;
    --fastqc-script)
      FASTQCSCRIPT=$2
      shift 2
      ;;
    --spaceranger-script)
      SPACERANGERSCRIPT=$2
      shift 2
      ;;
      --merge-script)
      MERGESCRIPT=$2
      shift 2
      ;;
    --email-user)
      EMAIL=$2
      shift 2
      ;;
    --mem-gb)
      MEMGB=$2
      shift 2
      ;;
    --ncores)
      NCORES=$2
      shift 2
      ;;
    --time-limit)
      TIMELIMIT=$2
      shift 2
      ;;
    -h|--help)
cat << EOF
$SCRIPT [-h] [-l -o -a --annotation-file --fastqc-script --spaceranger-script --merge-script --email-user --mem-gb --ncores --time-limit] 

   This script is used to create a folder structure suitable for 
   10x Visium preprocessing using spaceranger. To run the script 
   you need a Visium ID, a spaceranger reference genome, area IDs,
   as well as additional script named FastQC_sbatch.sh and 
   spaceranger_sbatch.sh.

   In addition, you can include a merge.sh script if you need 
   to merge multiple lanes. You can also set an email address 
   which will be added to the FastQC_sbatch.sh and spaceranger.sh 
   scripts in order to send progress reports.

   options:
    -h|--help  Print help messages
    -o|--output Output path
    -i|--visium-id Visium ID, e.g. V10T03-324
    -a|--areas Area id, e.g. A1,B1,C1,D1
    --reference-genome Path to reference genome prepared with spaceranegr mkref
    --fastqc-script Path to FastQC sbatch script
    --spaceranger-script Path to spaceranger sbatch script
    --merge-script Path to merge script
    --email-user Add email adress to get status report
    --mem-gb Memory limit in GBs
    --ncores Number of cores to be used
    --time-limit

EOF
      exit 1
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
  esac
done

# Find file extension
#EXTGTF=`echo $(basename $GTF) | cut -d'.' -f2,3`

if [[ ! $VISIUMID ]]; then
        echo "No Visium id supplied"
        exit 1
fi
if [[ ! $REF ]]; then
        echo "No reference genome supplied"
        exit 1
fi
if [[ ! $FASTQCSCRIPT ]]; then
        echo "No FastQC script supplied"
        exit 1
fi
if [[ ! $SPACERANGERSCRIPT ]]; then
        echo "No spaceranger script supplied"
        exit 1
fi
if [[ ! $AREAS ]]; then
	echo "Areas are missing"
	exit 1
fi
if [[ ! $OUTPUT ]]; then
	echo "No output folder specified"
	exit 1
else
	ABSPATH=$(realpath $OUTPUT)
fi

# Unpack area codes
IFS=',' read -r -a AREA <<< "${AREAS}"
ALEN="${#AREA[@]}"

# Create directories
for index in "${!AREA[@]}"
do
	# Create directiores
	DIR="${ABSPATH}/${VISIUMID}_${AREA[index]}"
	RAWDATA="${DIR}/raw_data"
	OUTPUTDATA="${DIR}/output_data"
	IMAGES="${DIR}/images"
	mkdir $DIR
	mkdir $RAWDATA $OUTPUTDATA $IMAGES
	
	# Add FastqQC script
	while read -r LINE
        	do
		if [[ $LINE =~ "#SBATCH -J" ]]
        	then
        	        LINE="#SBATCH -J FastQC_${VISIUMID}_${AREA[index]}"
        	fi
		if [[ $LINE =~ "fastqc" ]]
        	then
			if [[ $MERGESCRIPT ]]; then
				LINE="fastqc merged_${VISIUMID}_${AREA[index]}_*"
        	    	else
				LINE="fastqc ${VISIUMID}_${AREA[index]}_*"
			fi
        	fi
		if [[ $LINE =~ "#SBATCH --mail-user" && $EMAIL ]]
		then
			LINE="#SBATCH --mail-user ${EMAIL}"
		fi
		echo $LINE >> $RAWDATA/FastQC_sbatch.sh
        done < $FASTQCSCRIPT
	
	# Add merge script (optional)
	if [[ $MERGESCRIPT ]]; then
        	while read -r LINE
        		do
        		if [[ $LINE =~ "sample=" ]]
        		then
                		LINE="sample=${VISIUMID}_${AREA[index]}"
        		fi
        		echo $LINE >> $RAWDATA/merger.sh
        		done < $MERGESCRIPT
	fi
	
	# Add spaceranger sbatch script
	while read -r LINE
        	do
		if [[ $LINE =~ "#SBATCH -N 1 -n 1 -c" && $NCORES ]]
		then
			LINE="#SBATCH -N 1 -n 1 -c ${NCORES}"
		fi
		if [[ $LINE =~ "#SBATCH -t" && $TIMELIMIT ]]
		then
			LINE="#SBATCH -t ${TIMELIMIT}:00:00"
		fi
		if [[ $LINE =~ "#SBATCH --mem" && $MEMGB ]]
		then
			LINE="#SBATCH --mem ${MEMGB}000"
		fi
        	if [[ $LINE =~ "#SBATCH -J" ]]
        	then
        	        LINE="${LINE} ${VISIUMID}_${AREA[index]}"
        	fi
		if [[ $LINE =~ "#SBATCH --mail-user" && $EMAIL ]]
                then
                    	LINE="#SBATCH --mail-user ${EMAIL}"
                fi
        	if [[ $LINE =~ "FASTQ=" ]]
        	then
			LINE="FASTQ=${RAWDATA}"
        	fi
        	if [[ $LINE =~ "SAMPLE=" ]]
        	then
			if [[ $MERGESCRIPT ]]
			then
                		LINE="SAMPLE=merged_${VISIUMID}_${AREA[index]}"
			else
				LINE="SAMPLE=${VISIUMID}_${AREA[index]}"
			fi
        	fi
		if [[ $LINE =~ "SAMPLEID=" ]]
		then
			LINE="SAMPLEID=${VISIUMID}_${AREA[index]}"
		fi
        	if [[ $LINE =~ "SLIDE=" ]]
        	then
                	LINE="SLIDE=${VISIUMID}"
        	fi
        	if [[ $LINE =~ "AREA=" ]]
        	then
                	LINE="AREA=${AREA[index]}"
        	fi
        	if [[ $LINE =~ "REF=" ]]
        	then
                	LINE="REF=${REF}"
        	fi
        	echo $LINE >> $OUTPUTDATA/spaceranger_sbatch.sh
        done < $SPACERANGERSCRIPT
done

