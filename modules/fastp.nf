process FASTP {
    tag "${meta.id}"
    conda "bioconda::fastp=0.23.4"
    publishDir "${params.outdir}/fastp", mode: 'copy'
    
    input:
    tuple val(meta), path(reads)
    
    output:
    tuple val(meta), path("*_trimmed.fastq.gz"), emit: trimmed_reads
    path "*.json", emit: json_report
    path "*.html", emit: html_report
    
    script:
    def prefix = "${meta.id}"
    
    """
    fastp \
        --in1 ${reads[0]} \
        --in2 ${reads[1]} \
        --out1 ${prefix}_R1_trimmed.fastq.gz \
        --out2 ${prefix}_R2_trimmed.fastq.gz \
        --detect_adapter_for_pe \
        --trim_poly_g \
        --trim_front1 30 --trim_front2 30 \
        --cut_front --cut_front_window_size 5 --cut_front_mean_quality 30 \
        --cut_tail --cut_tail_window_size 5 --cut_tail_mean_quality 30 \
        --qualified_quality_phred 30 \
        --average_qual 30 \
        --length_required 50 \
        --low_complexity_filter \
        --complexity_threshold 30 \
        --json ${prefix}_fastp.json \
        --html ${prefix}_fastp.html \
        --thread $task.cpus
    """
}