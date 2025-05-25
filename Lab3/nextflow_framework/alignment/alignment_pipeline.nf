#!/usr/bin/env nextflow

params.reads = "/Users/anastasiamrv/IdeaProjectsNSU/bioinf/Lab3/ERR14949205.fastq"
params.reference = "/Users/anastasiamrv/IdeaProjectsNSU/bioinf/Lab3/hg38.fa"
params.output_dir = "results"

process fastqc_analysis {
    publishDir "${params.output_dir}/fastqc", mode: 'copy'

    input:
    path reads

    output:
    path "fastqc_results/*_fastqc.{zip,html}", emit: qc_reports

    script:
    """
    mkdir -p fastqc_results
    fastqc "$reads" -o fastqc_results
    """
}

process build_index {
    publishDir "${params.output_dir}/index", mode: 'copy'

    input:
    path reference

    output:
    path "${reference}.mmi", emit: index

    script:
    """
    minimap2 -d "${reference}.mmi" "$reference"
    """
}

process align_reads {
    publishDir "${params.output_dir}/alignment", mode: 'copy'

    input:
    path reads
    path index

    output:
    path "aligned.sam", emit: sam

    script:
    """
    minimap2 -a "$index" "$reads" > aligned.sam
    """
}

process alignment_stats {
    publishDir "${params.output_dir}/stats", mode: 'copy'

    input:
    path sam_file

    output:
    path "alignment_stats.txt", emit: stats
    path "aligned.bam", emit: bam
    val "OK", emit: status

    script:
    '''
    samtools view -b ''' + sam_file + ''' > aligned.bam
    samtools flagstat aligned.bam > alignment_stats.txt

    mapped_percent=$(grep -m1 -oE 'mapped \\([0-9]+\\.[0-9]+%' alignment_stats.txt | grep -oE '[0-9]+\\.[0-9]+')
    if awk -v mp="$mapped_percent" 'BEGIN { exit (mp <= 90) }'; then
        echo "OK"
    else
        echo "Not OK"
    fi
    '''
}

process sort_bam {
    publishDir "${params.output_dir}/sorted_bam", mode: 'copy'

    input:
    path bam_file
    val status

    output:
    path "sorted.bam", emit: sorted_bam

    when:
    status == "OK"

    script:
    """
    samtools sort "$bam_file" -o sorted.bam
    """
}

process freebayes {
    publishDir "${params.output_dir}/freebayes", mode: 'copy'

    input:
    path reference
    path sorted_bam_file
    val status

    output:
    path "variants.vcf", emit: variants

    when:
    status == "OK"

    script:
    """
    freebayes -f "${reference}" "$sorted_bam_file" > variants.vcf
    """
}

process completion_message {
    output:
    stdout

    script:
    """
    echo "Pipeline finished"
    """
}

workflow {
    main:
        fastqc_analysis(params.reads)
        build_index(params.reference)
        align_reads(params.reads, build_index.out.index)
        alignment_stats(align_reads.out.sam)
        sort_bam(alignment_stats.out.bam, alignment_stats.out.status)
        freebayes(params.reference, sort_bam.out.sorted_bam, alignment_stats.out.status)
        completion_message()
}
