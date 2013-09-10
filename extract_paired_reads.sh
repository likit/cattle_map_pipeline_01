#!/bin/sh -login
#PBS -l nodes=1:ppn=1,mem=24gb,walltime=12:00:00
#PBS -M preeyano@msu.edu
#PBS -m abe
#PBS -N extract-paired-reads
#PBS -A ged-intel11


cd /mnt/lustre_scratch_2012/preeyanon/cattle_map/paired/diginorm
for f in *.pe*abundfilt
do
    python ~/khmer/scripts/extract-paired-reads.py $f
done
