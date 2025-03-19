# Genomic Analysis Pipeline

A Nextflow pipeline for processing paired-end reads, including trimming, assembly, and quality control.

## Workflow Overview

This pipeline performs the following steps:
1. Trimming of raw reads with Fastp (Module 1)
2. Processing of trimmed reads in either parallel or sequential mode:
   
   **Parallel Mode (Default):**
   - Assembly of trimmed reads with SPAdes (Module 2) runs simultaneously with FastQC (Module 3)
   - Aggregating FastQC reports with MultiQC (Module 4)
   
   **Sequential Mode:**
   - Quality control of trimmed reads with FastQC (Module 3)
   - Aggregating FastQC reports with MultiQC (Module 4)
   - Assembly of trimmed reads with SPAdes (Module 2) only after QC steps are completed

### Workflow Diagram

```
                          Raw Reads
                             |
                             v
                     +----------------+
                     |     FASTP      |
                     +----------------+
                             |
                      Trimmed Reads
                       /          \
                      /            \
                     v              v
            +----------------+ +----------------+
            |     SPADES     | |     FASTQC     |
            +----------------+ +----------------+
                     |                |
                     |                |
              Assembly Files     FastQC Reports
                                      |
                                      v
                                +----------------+
                                |    MULTIQC     |
                                +----------------+
                                      |
                                      v
                                 QC Summary
```
FastQC and SPADES could be executed at the same time or sequentially depending on the mode selected, if executed in sequential order then FastP is going to be executed first, followed by Fastqc and multiqc to end with Spades.

## Requirements

- Nextflow v24.10.5
- Conda or Mamba (for managing software dependencies)
- Tested in Linux and MacOS

## Installation

1. Clone this repository:
```bash
git clone https://github.com/pipecedeno/bacterial_assembly_nf_workflow.git
cd bacterial_assembly_nf_workflow
```

2. Install Nextflow and nf-core tools:
```bash
conda create -n nf -c bioconda nextflow=24.10.5 -y
conda activate nf
conda install -c bioconda nf-core -y
```

## Test Data

The repository includes a small test dataset in the `test_data/` directory:
- `sample1_1.fastq.gz` and `sample1_2.fastq.gz`: A small paired-end dataset

To run the pipeline on this test data:

```bash
nextflow run main.nf -profile test,conda,parallel
```

In case you want to run it sequentially use:

```bash
nextflow run main.nf -profile test,conda,sequential
```

## Running the Pipeline

### Basic Usage

```bash
nextflow run main.nf --reads '/path/to/reads/*_{1,2}.fastq.gz' --outdir results --execution_mode [parallel/sequential] -profile conda
```

### Parameters

- `--reads`: Path to input reads (default: `test_data/*_{1,2}.fastq.gz`)
- `--outdir`: Output directory (default: `results`)
- `--execution_mode`: Execution mode - 'parallel' or 'sequential' (default: `parallel`)

## Output

The pipeline generates the following outputs:

- `results/fastp/`: Trimmed reads and Fastp reports
- `results/spades/`: SPAdes assembly output
- `results/fastqc/`: FastQC reports
- `results/multiqc/`: Aggregated QC report
- `results/execution_timeline.html`: Timeline of the pipeline execution
- `results/execution_report.html`: Detailed execution report

## Folder organization

```
├── main.nf              # Main workflow file
├── nextflow.config      # Configuration file
├── modules/             # Modules Directory
│   ├── fastp.nf
│   ├── spades.nf
│   ├── fastqc.nf
│   └── multiqc.nf
└── test_data/           # Test dataset
```