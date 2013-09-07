#!/bin/sh -login
#PBS -l nodes=1:ppn=1,mem=24gb,walltime=24:00:00
#PBS -M preeyano@msu.edu
#PBS -m abe
#PBS -N Normalize_C20_k20_paired

cd /mnt/lustre_scratch_2012/preeyanon/cattle_map/paired/diginorm
python ~/khmer/scripts/normalize-by-median.py -C 20 --loadhash normC20k20.kh --savehash normC20k20.kh ../qc_trimmed/*trim_unpaired.fastq
