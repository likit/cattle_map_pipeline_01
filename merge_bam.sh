#!/bin/sh

for f in *trim1.fastq_tophat_out
do
    sample_name=$(echo $f | cut -f 1,2,3,4 -d '_')
    printf "Merging on %s...\n" $sample_name
    dir_ext1="_001.pe_trim1.fastq_tophat_out/accepted_hits.bam"
    dir_ext2="_R2_001.trim_unpaired.fastq_tophat_out/accepted_hits.bam"
    samtools merge -n -f -h header.inh "$sample_name"_merge.bam $sample_name$dir_ext1 $sample_name$dir_ext2
done
