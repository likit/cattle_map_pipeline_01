#!/bin/sh -login
#PBS -l nodes=1:ppn=1,mem=24gb,walltime=24:00:00
#PBS -m abe
#PBS -N Abundance_filtering
#PBS -A ged-intel11

cd ${PBS_O_WORKDIR}
python ~/khmer/scripts/filter-abund.py -V normC20k20.kh raw/*keep
