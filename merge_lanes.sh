#!/bin/sh
for f in *L001*bam
do
    first_lane="$f"
    second_lane=$(echo "$f" | sed s/L001/L002/)
    merged_file=$(echo "$f" | sed s/L001/both/)
    printf "Merging %s and %s to %s\n" $first_lane $second_lane $merged_file
    samtools merge -h header.inh $merged_file $first_lane $second_lane
done
