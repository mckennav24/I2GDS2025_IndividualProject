# I2GDS2025_IndividualProject
McKenna Vernon's Individual Project for Introduction to Genomic Data Science Fall 2025
## Overview
My thesis will be written based on a prior student's collected wastewater, recycled water, and surface water samples. These samples have been sequenced and the data is ready to be analyzed (i.e., run through a Linux pipeline and create figures to interpret data).
I used a subset of these sequences (10 out of 127) and ran the first two steps of my pipeline: FastQC and MultiQC. Descriptions of these steps are below. 

**Note:** All bash scripts can be found in "code_files" folder.

# 1. FastQC
FastQC is a tool that evaluates the quality of raw sequencing data and creates a figure visualizing each read's quality score (quality scores are already assigned when the data is sequenced).
## 1.1 Create an environment to host FastQC
An environment is a virtual space in which analysis tools can be installed and utilized. Use the following command to list your already existing environments
```
module load Miniconda3/24.7.1-0
conda env list
```
If you don't see an environment in which you remember installing fastqc, create and activate an environment using the following code:
```
module load Miniconda3/24.7.1-0
conda create --name fastqc #a different environment name can be chosen if desired
source activate fastqc
```
You should now see (fastqc) \[yourPID@clustername directoryname\]$, indicating that you've entered the fastqc environment.

## 1.2 Install FastQC
To install fastqc, use the following code:
```
conda install bioconda::fastqc
```
Use the following line of code to confirm fastqc is installed
```
fastqc -h
```
If fastqc is properly installed, you will see a description of the fastqc program, a synopsis of its documentation, and options for program use. If it is not installed, you will see a message similar to the following:
```
fastqc: command not found
```
If you see this message, retry the installation process.

## 1.3 Run your data through FastQC
Use the following script (fastqcGDSsub.sh) to run fastqc on your raw sequence files. Here, FastQC v0.12.1 is used.
<details>
  <summary>fastqcGDSsub.sh</summary>

``` 
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
```
</details>

## 1.4 Review FastQC outputs
Navigate to the output directory created when fastqc was run. Each file (i.e., each read) will produce a fastqc.html and fastqc.zip file.
Download and open the .html file to evaluate the FastQC report for each sample. You may have an R1 and R2 read for each sample (a forward and reverse read, respectively), meaning you will have two reports per sample.

The image below is an example quality score report for one of my sample's read's. Based on this report, I would decide if there is a quality score (y-axis) cut off at which I want to trim my read(s).
<p align="center">
<img width="893" height="673" alt="8219-S100_S20_r1_001-fastqcreport" src="https://github.com/user-attachments/assets/87939409-623e-45e4-8cef-5da7eab4fb27" />
</p>
For reference, here is a table explaining the quality score meanings: 
<p align="center">
<img width="400" height="225" alt="phred_table" src="https://github.com/user-attachments/assets/6a0e6bdb-c9ad-45a4-bda4-bc6f23717fcc" />
</p>
Sourced from https://openlab.citytech.cuny.edu/bio-oer/analyzing-dna/next-gen-sequencing/2/

# 2. MultiQC
MultiQC is a tool that allows you to combine multiple FastQC reports from various samples into one graph and examine the overall quality score of all reads. Like FastQC, this output can also be used to inform future read trimming.

## 2.1 Create an environment to host MultiQC
If you are still within the fastqc environment, use the following line of code to exit your environment
```
conda deactivate
```
Use the following code to create a new environment for multiqc
```
conda create --name multiqc #a different environment name can be chosen if desired
source activate multiqc
```

## 2.2 Install MultiQC and activate environment
Use the following code to install multiqc
```
conda install bioconda::multiqc 
```
You can confirm multiqc is installed using the same strategy listed in the fastqc step, substituting "fastqc" for "multiqc".

Activate your new environment using: 
```
source activate multiqc
```

## 2.3 Run MultiQC
MultiQC's input is the fastqc reports in your previously created "fastqc_results" directory. MultiQC is programmed to understand the FastQC outputs, so there is no need to differentiate between file type (i.e., fastqc.html vs. fastqc.zip) with this tool. Use the following code to access those files and run them with multiqc. Here, MultiQC version 1.0.dev0 is used.
<details>
  <summary>multiqcGDSsub.sh</summary>

``` 
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
```
</details>

**Note:** Alternatively, after entering the environment where multiqc is installed, you can navigate to the directory that hosts the fastqc report files and run "multiqc ." in your terminal. However, keep file size in mind when choosing between this option and a bash script.

## 2.4 Review MultiQC output
The output file (multiqc_report.html) will be located in the same directory as your fastqc output files. A folder called "multiqc_data" will also be created in this directory. It hosts various statistics and additional information that was generated during the multiqc run.

Download and open the multiqc_report.html file. Similar to the FastQC reports, this report will give you a big picture understanding of your read qualities and help you decide where to trim during next steps (i.e., using fastp or Trimmomatic).

Below is the report generated by my subset. Based on this report, I would assess that my reads have a good quality overall, seeing that the lowest Phred Quality Score is 32.63.
<p align="center">
<img width="2160" height="983" alt="MultiQCGDSSubset" src="https://github.com/user-attachments/assets/ed2b3131-bf84-4a72-938d-c91074f76e61" />
<img width="2160" height="988" alt="MultiQCwMinScore" src="https://github.com/user-attachments/assets/32ae7f2b-5fc3-4cc3-9d58-70a9f2d4cdf2" />
</p>
