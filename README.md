# I2GDS2025_IndividualProject
McKenna Vernon's Individual Project for Introduction to Genomic Data Science Fall 2025

My thesis will be written based on a prior student's collected wastewater, recycled water, and surface water samples. These samples have been sequenced and the data is ready to be analyzed (i.e., run through a Linux pipeline and create figures to interpret data).
I used a subset of these sequences (10 out of 127) and ran the first two steps of my pipeline: FastQC and MultiQC. Descriptions of these steps are below. 

**Note:** All bash scripts and csv files can be found in "code_files" folder.

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

## 2.4 Potential mistakes
Do not forget the "." after "multiqc". It's an easy character to miss, but without it, your code will fail.

## 2.5 Review MultiQC output
The output file (multiqc_report.html) will be located in the same directory as your fastqc output files. A folder called "multiqc_data" will also be created in this directory. It hosts various statistics and additional information that was generated during the multiqc run.

Download and open the multiqc_report.html file. Similar to the FastQC reports, this report will give you a big picture understanding of your read qualities and help you decide where to trim during next steps (i.e., using fastp or Trimmomatic).

Below is the report generated by my subset. Based on this report, I would assess that my reads have a good quality overall, seeing that the lowest Phred Quality Score is 32.63.
<p align="center">
<img width="2160" height="983" alt="MultiQCGDSSubset" src="https://github.com/user-attachments/assets/ed2b3131-bf84-4a72-938d-c91074f76e61" />
<img width="2160" height="988" alt="MultiQCwMinScore" src="https://github.com/user-attachments/assets/32ae7f2b-5fc3-4cc3-9d58-70a9f2d4cdf2" />
</p>

# 3. R Overview
The data used above has several pipeline steps remaining before figures can be made in R. However, a key figure would be a stacked bar plot showing what antibiotic resistance genes (ARGs) or drug resistances are present in different sample types. With this in mind, I took data from diferent stages of the wastewater treatment process that was used in my group project and made a stacked bar plot. 

## 3.1 R script
The R script below was used to create a stacked bar plot. This code takes any ARGs that appear at least 10 times across all sample types (here, 25 ARGs) and shows how present they are in each sample type (measured using normalization with the rpoB).
<details>
  <summary>NewIndProjF25.R</summary>

``` 
#Loading necessary packages, you may need to install
library(ggplot2)
library(dplyr)
library(RColorBrewer)

#Setting working directory
setwd("C:/Users/mjver/Downloads")

#Loading necessary data and assigning variables
Args <- read.csv("I2GDS_GroupProj_DIAMOND.csv", header = TRUE)
metadata <- read.csv("I2GDSMetadata.csv", header = TRUE)

#Counting frequency of each ARG and picking above a certain threshold
df <- data.frame(Args$gene)
df_freq <- df %>%
  count(Args$gene)
df_sort <- arrange(df_freq, desc(n))

top_args <- df_sort %>%
  filter(n >= 10)

#Creating new data frame with ARG name, rpob normalized value, and associated Sample Type
num_iterations = sum(top_args$n)
populate <- data.frame(
  Gene = character(num_iterations),
  rpob_norm = numeric(num_iterations),
  SampleType = character(num_iterations),
  stringsAsFactors = FALSE # Prevents character data from becoming factors
)

row_index <- 1
for (i in 1:nrow(top_args)) {
  for (j in 1:nrow(Args)) {
      if (top_args[i, 1] == Args[j, 1]) {
        populate[row_index, "Gene"] <- Args[j, 1]
      populate[row_index, "rpob_norm"] <- Args[j, 5]
      populate[row_index, "SampleType"] <- Args[j, 8]
      row_index <- row_index + 1
    }
  }
}

#Plotting ARGs that met presence threshold
populate$rpob_norm <- as.numeric(as.character(populate$rpob_norm))
populate$Gene <- factor(populate$Gene, levels = c("Escherichia", "Klebsiella", "Pseudomonas",
                                            "AxyY", "Bifidobacterium", "MexB", "MexF", "MuxB",
                                            "MuxC", "Nocardia", "Streptomyces", "acrB", "acrD",
                                            "acrF", "adeF", "amrB", "ceoB", "mdtB", "mdtC",
                                            "mexI", "mexK", "msbA", "mtrD", "oqxB", "smeE"))
populate$SampleType <- factor(populate$SampleType, levels = c("Influent", "Primary", "Act. Sludge",
                                                              "Secondary", "Floc Sed", "Ozonation",
                                                              "BAC/GAC", "Chlorination", "3 days", "Background"))

c25 <- c(
  "dodgerblue2", "#E31A1C", # red
  "green4",
  "#6A3D9A", # purple
  "#FF7F00", # orange
  "black", "gold1",
  "skyblue2", "#FB9A99", # lt pink
  "palegreen2",
  "#CAB2D6", # lt purple
  "#FDBF6F", # lt orange
  "gray70", "khaki2",
  "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
  "darkturquoise", "green1", "yellow4", "yellow3",
  "darkorange4", "brown"
)
ggplot(populate, aes(x=reorder(SampleType, -rpob_norm), y=rpob_norm,fill=Gene,)) + 
  geom_bar(position="stack", stat="identity") + 
  scale_fill_manual(values = c25) +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = .7)) + 
  labs(x = "Sample Type", y = "rpoB normalization values", title = "Top 25 ARGs present") +
  theme(plot.title = element_text(hjust = 0.5))
```
</details>

## 3.2 Resulting figure
Below is the figure generated by the R script above. Here, we can see that the most ARGs were present during the ozonation step of the wastewater treatment process and that many ARGs (e.g., adeF, ceoB) were the most present in ozonation samples.
<p align="center">
<img width="1534" height="866" alt="FinalIndProjRPlot" src="https://github.com/user-attachments/assets/6b5f6b1e-dfe2-45f0-b11c-8a117ba8f7c1" />
</p>
In the future, the full set of ARGs (not just those that appeared at least 10 times) could be reclassified based on their drug-resistance, and the stacked section of each plot could represent drug resistance instead. Being that some ARGs are resistant to the same drugs (and rare drug resistances could be classified as "Other"), this categorization would lead to a stacked bar plot that differentiates from the one above.

## 3.3 Potential mistakes
Do not forget the "row_index" and "row_index + 1" portion of the for loop. I did initially, and each time the for loop ran, values replaced an already populated row until only the last iteration remained, while all other rows were empty.
