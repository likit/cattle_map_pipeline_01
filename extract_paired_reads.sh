#!/bin/sh -login
#PBS -l nodes=1:ppn=1,mem=24gb,walltime=12:00:00
#PBS -M preeyano@msu.edu
#PBS -m abe
#PBS -N Extract_paired_reads
#PBS -A ged-intel11


cd ${PBS_O_WORKDIR}
for f in *.pe*abundfilt
do
    python ~/khmer/scripts/extract-paired-reads.py $f
done
