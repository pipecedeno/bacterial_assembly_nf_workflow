process SPADES {
    tag "${meta.id}"
    conda "bioconda::spades"
    publishDir "${params.outdir}/spades", mode: 'copy'
    
    input:
    tuple val(meta), path(reads)
    
    output:
    // tuple val(meta), path("${meta.id}_assembly"), emit: assembly_dir // This would be to save all the files that spades creates
    tuple val(meta), path("${meta.id}_assembly/scaffolds.fasta"), emit: scaffolds
    tuple val(meta), path("${meta.id}_assembly/contigs.fasta"), emit: contigs
    
    script:
    def prefix = "${meta.id}"
    
    """
    spades.py \
        -1 ${reads[0]} \
        -2 ${reads[1]} \
        --isolate \
        -o ${prefix}_assembly \
        -t $task.cpus
    """
}