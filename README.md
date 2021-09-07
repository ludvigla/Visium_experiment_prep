# Visium_experiment_prep

Clone repo:

```
git clone https://github.com/ludvigla/Visium_experiment_prep
```

Navigate to folder and run script:

```
cd Visium_experiment_prep
sh create_exp.sh --help
```


# Usage

Example 1:

Visium slide named V10T03-324 with all four capture areas (A1, B1, C1, D1) included (Homo sapiens GRCh38-3.0.0 reference genome):

```
sh create_exp.sh -i V10T03-324 -a A1,B1,C1,D1 --reference-genome /fastdisk/10x/refdata-cellranger-GRCh38-3.0.0 --fastqc-script FastQC_sbatch.sh --spaceranger-script spaceranger_sbatch.sh --email-user name.lastname@scilifelab.se
```

Example 2:

Visium slide named V10T03-324 with three capture areas (A1, C1, D1) included and merging required (Mus Musculus mm10-3.0.0 reference genome)

```
sh create_exp.sh -i V10T03-324 -a A1,C1,D1 --reference-genome /fastdisk/10x/refdata-cellranger-mm10-3.0.0 --fastqc-script FastQC_sbatch.sh --spaceranger-script spaceranger_sbatch.sh --merge-script merge.sh --email-user name.lastname@scilifelab.se
```
