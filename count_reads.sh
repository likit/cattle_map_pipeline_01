#!/bin/sh -login
#PBS -l nodes=1:ppn=1,mem=12gb,walltime=48:00:00
#PBS -M preeyano@msu.edu
#PBS -m abe
#PBS -N SAMTools_cDNA_${input}

module load SAMTools
module load BEDTools

cd ${PBS_O_WORKDIR}
bamfile=$(basename ${input} .sam).bam
sorted_bamfile=$(basename ${input} .sam).sorted
samtools view -b -S -o "$bamfile" ${input}
printf "Sorting %s to %s\n" $bamfile $sorted_bamfile
samtools sort "$bamfile" "$sorted_bamfile"
samtools index "$sorted_bamfile".bam
multiBamCov -bams "$sorted_bamfile".bam -bed Trinity_part.bed > ${input}.counts
#multiBamCov -bams ${input} -bed Trinity_part.bed > ${input}.counts2
