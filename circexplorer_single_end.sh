#!/bin/bash


# Mouse
mm39_ref_fasta=/path_to_your_annotation/ref_and_annotations/gencode_mm39/GRCm39.genome.fa
mm39_kg_gtf=/path_to_your_annotation/ref_and_annotations/gencode_mm39/gencode.vM28.annotation.gtf
mm39_star_index=/path_to_your_annotation/ref_and_annotations/gencode_mm39/star_index
mm39_ref_all=/path_to_your_annotation/ref_and_annotations/gencode_mm39/gencode.vM28.annotation.txt

##STAR alignment(single-end)

STAR_align=$(ls /path_to_your_fqfiles/fastq_files/*.fastq.gz | cut -d '/' -f 8 | cut -d '.' -f 1); #Please read about cut command first

for DR in $STAR_align;
do
        FL1=$(ls /path_to_your_fqfiles/fastq_files/${DR}.fastq.gz) ##
        STAR --runThreadN 30  --genomeDir ${mm39_star_index} --readFilesIn <(gunzip -c ${FL1}) --outSAMtype BAM Unsorted --chimSegmentMin 10 --outFileNamePrefix ${DR}_
done;
echo "STAR alignment Completed successfully..."

######
parse=$(ls *Chimeric.out.junction | cut -d "_" -f 1); #Please read about cut command first
for i in $parse;
do
        CIRCexplorer2 parse -t STAR ${i}_Chimeric.out.junction > ${i}_CIRCexplorer2_parse.log
        mv back_spliced_junction.bed ${i}_back_spliced_junction.bed
done;
echo "CIRCexplorer2 Parsing Completed successfully..."

######
annotate=$(ls *.bed | cut -d '_' -f 1); #Please read about cut command first

echo "circRNA annotation started..."

for f in $annotate;
do
        CIRCexplorer2 annotate -r ${mm39_ref_all} -g ${mm39_ref_fasta} -b ${f}_back_spliced_junction.bed -o ${f}_circularRNA_known.txt > ${f}_CIRCexplorer2_annotate.log;
done;
echo "CIRCexplorer2 Annotation Completed successfully..."