#!/bin/sh -login
#PBS -l nodes=1:ppn=1,mem=24gb,walltime=24:00:00
#PBS -M preeyano@msu.edu
#PBS -m abe
#PBS -N Abundance_filtering
#PBS -A ged-intel11


cd /mnt/lustre_scratch_2012/preeyanon/cattle_map/paired/diginorm
python ~/khmer/scripts/filter-abund.py -V normC20k20.kh *keep
