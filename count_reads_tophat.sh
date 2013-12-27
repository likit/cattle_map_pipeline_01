for d in *tophat_out
do
    cd $d
    printf "Sorting %s" $d/accepted_hits.bam
    samtools sort -n accepted_hits.bam accepted_hits_sorted_by_name
    printf "Converting %s" $d/accepted_hits.bam
    samtools view -o accepted_hits_sorted_by_name.sam accepted_hits_sorted_by_name.bam
    printf "Counting %s" $d/accepted_hits.bam
    htseq-count --stranded=reverse accepted_hits_sorted_by_name.sam ~/bosTau7/Bos_taurus.UMD3.1.73.gtf > accepted_hits_counts.txt
    cd ../
done

for d in *unpaired_tohat_out
do
    cd $d
    printf "Converting %s" $d/accepted_hits.bam
    samtools view -o accepted_hits.sam accepted_hits.bam
    printf "Counting %s" $d/accepted_hits.bam
    htseq-count accepted_hits.sam ~/bosTau7/Bos_taurus.UMD3.1.73.gtf > accepted_hits_counts.txt
    cd ../
done
