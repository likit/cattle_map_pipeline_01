#!/bin/sh -login
#PBS -l nodes=1:ppn=1,mem=12gb,walltime=12:00:00
#PBS -M preeyano@msu.edu
#PBS -m abe
#PBS -N Interleave_all_paired_reads

cd /mnt/lustre_scratch_2012/preeyanon/cattle_map/paired/
find ./raw/ -name "*pe_trim1.fastq" | while read FILE
do
    r1=$FILE
    r2=$(echo $FILE | sed s/trim1/trim2/)
    out=$(echo $(basename $FILE) | sed s/trim1/trim/)
    python ~/khmer/scripts/interleave-reads.py $r1 $r2 > $out
done
