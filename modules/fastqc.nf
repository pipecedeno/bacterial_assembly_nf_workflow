process FASTQC {
    tag "${meta.id}"
    conda "bioconda::fastqc=0.12.1"
    publishDir "${params.outdir}/fastqc", mode: 'copy'
    
    input:
    tuple val(meta), path(reads)
    
    output:
    path "*.html", emit: html
    path "*.zip", emit: zip
    
    script:
    """
    fastqc ${reads} -t $task.cpus
    """
}