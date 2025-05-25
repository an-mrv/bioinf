#!/bin/sh
# проверяет качество ридов
fastqc $1

# создаёт индекс для референсного генома
minimap2 -d ref_genome.mmi $2

# выравнивает риды на референс, сохраняя результат в SAM-формате
minimap2 -a ref_genome.mmi $1 > aligned.sam

# конвертирует SAM в более компактный BAM
samtools view -b aligned.sam > aligned.bam

# считает % ридов, которые успешно выровнялись
samtools flagstat aligned.bam > report.txt

mapped_percent=$(grep -m1 -oE 'mapped \([0-9]+\.[0-9]+%' report.txt | grep -oE '[0-9]+\.[0-9]+')
if awk -v mp="$mapped_percent" 'BEGIN { exit (mp <= 90) }'; then
    echo "OK"

    # сортировка BAM файла
    samtools sort aligned.bam -o aligned_sorted.bam

    # поиск вариантов
    freebayes -f $2 aligned_sorted.bam > variants.vcf

    echo "Pipeline finished"
else
    echo "Not OK"
fi