#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Import modules
include { FASTP } from './modules/fastp'
include { SPADES } from './modules/spades'
include { FASTQC } from './modules/fastqc'
include { MULTIQC } from './modules/multiqc'

// Parameter definition, if they are not provided these are the defaults
params.reads = "$projectDir/test_data/*_{1,2}.fastq.gz"
params.outdir = "results"
params.execution_mode = "parallel"

// Log parameters
log.info """\
    GENOMIC ANALYSIS PIPELINE
    =========================
    reads          : ${params.reads}
    outdir         : ${params.outdir}
    execution_mode : ${params.execution_mode}
    """
    .stripIndent()


// Main workflow
workflow {
    // Create a channel with the pairs of input files, a channel is like a list
    // or a vector, in this case it is a list of tuples
    Channel
        .fromFilePairs(params.reads, checkIfExists: true)
        .map { tuple -> 
            def meta = [id: tuple[0]]
            [ meta, tuple[1] ]
        }
        .set { ch_raw_reads }
    
    // Trimming with Fastp
    FASTP(ch_raw_reads)
    
    // Saving the trimmed reads names to be the input of the following modules
    ch_trimmed_reads = FASTP.out.trimmed_reads
    
    if (params.execution_mode == "parallel") {
        // Parallel execution of SPAdes and FastQC on trimmed reads
        SPADES(ch_trimmed_reads)
        FASTQC(ch_trimmed_reads)
        
        // Collect fastqc reports to be the input of the multiqc module
        ch_fastqc_reports = FASTQC.out.zip.collect()
        
        MULTIQC(ch_fastqc_reports)
    } else if (params.execution_mode == "sequential") {
        // This is quite dumb as if there are not enough resources it is going
        // to be executed sequentially either way

        // Sequential execution: first FastQC and MultiQC, then SPAdes
        FASTQC(ch_trimmed_reads)
        
        // Collect fastqc reports to be the input of the multiqc module
        ch_fastqc_reports = FASTQC.out.zip.collect()
        
        MULTIQC(ch_fastqc_reports)
        
        // Then SPAdes after MultiQC completes
        MULTIQC.out.report.view() // This creates a dependency that ensures SPAdes runs after MultiQC
        SPADES(ch_trimmed_reads)
    } else {
        error "Invalid execution_mode: ${params.execution_mode}. Valid options are 'parallel' or 'sequential'."
    }
}

// completion notification
workflow.onComplete {
    log.info "Pipeline completed at: $workflow.complete"
    log.info "Execution status: ${ workflow.success ? 'OK' : 'Failed' }"
    log.info "Execution duration: $workflow.duration"
}