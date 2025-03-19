#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Import modules
include { FASTP } from './modules/fastp'
include { SPADES } from './modules/spades'
include { FASTQC } from './modules/fastqc'
include { MULTIQC } from './modules/multiqc'

// Parameter definition, if they are not provided this are the defaults
params.reads = "$projectDir/test_data/*_{1,2}.fastq.gz"
params.outdir = "results"

// Log parameters
log.info """\
    GENOMIC ANALYSIS PIPELINE
    =========================
    reads        : ${params.reads}
    outdir       : ${params.outdir}
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
    
    // The trimmed reads channel
    ch_trimmed_reads = FASTP.out.trimmed_reads
    
    // Parallel execution of SPAdes assembly and FastQC on trimmed reads
    SPADES(ch_trimmed_reads)
    FASTQC(ch_trimmed_reads)
    
    // Run MultiQC only on FastQC reports
    ch_fastqc_reports = FASTQC.out.zip.collect()
    
    MULTIQC(ch_fastqc_reports)
}

// Workflow completion notification
workflow.onComplete {
    log.info "Pipeline completed at: $workflow.complete"
    log.info "Execution status: ${ workflow.success ? 'OK' : 'Failed' }"
    log.info "Execution duration: $workflow.duration"
}

