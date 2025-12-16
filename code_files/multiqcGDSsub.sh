#!/bin/bash
#SBATCH --account=introtogds #change to desired account
#SBATCH --partition=normal_q #change to desired partition
#SBATCH -t 20:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yourPID@vt.edu #insert your PID



module load Miniconda3

source activate multiqc

cd /projects/ciwars/5052/WRF-5052_Metagenomic_Sequences/GDS_Subset/ConcatFiles/fastqc_results    #Change to directory where fastq files are located



multiqc .
