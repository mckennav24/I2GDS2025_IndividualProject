#!/bin/bash
#SBATCH --account=introtogds #change to desired account
#SBATCH --partition=normal_q #change to desired partition
#SBATCH -t 20:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yourPID@vt.edu #insert your PID



mkdir -p /projects/ciwars/5052/WRF-5052_Metagenomic_Sequences/GDS_Subset/ConcatFiles/fastqc_results #creating a "fastqc_results" directory to host outputs. Change to reflect where you'd like this output directory to be created.

module load Miniconda3

source activate fastqc

cd /projects/ciwars/5052/WRF-5052_Metagenomic_Sequences/GDS_Subset/ConcatFiles    #Change to directory where fastq files are located

for file in *.fastq.gz; do       #Can change to .fastq if files are not zipped. May also need to change the "*.fastq.gz" to something more specific if the files you want run are not the only files in your directory that end in .fastq.gz

    fastqc "$file" -o /projects/ciwars/5052/WRF-5052_Metagenomic_Sequences/GDS_Subset/ConcatFiles/fastqc_results/  #Change to the path for the output directory created at the start of this code

done
