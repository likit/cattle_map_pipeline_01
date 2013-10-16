#!/bin/sh -login
#PBS -l nodes=1:ppn=1,mem=24gb,walltime=24:00:00
#PBS -m abe
#PBS -N bed_to_juncs
#PBS -A ged-intel11

module load TopHat/2.0.8b
cd /mnt/ls12/preeyanon/cattle_map/paired/
for dir in *tophat_out
do
    cd $dir
    bed_to_juncs < junctions.bed
    cd ../
done
