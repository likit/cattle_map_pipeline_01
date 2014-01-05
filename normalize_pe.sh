#!/bin/sh -login
#PBS -l nodes=1:ppn=1,mem=24gb,walltime=24:00:00
#PBS -m abe
#PBS -N Normalize_C20_k20_paired

cd ${PBS_O_WORKDIR}
python ~/khmer/scripts/normalize-by-median.py -p -k 20 -C 20 -N 4 -x 4e9 --savehash normC20k20.kh raw/*pe_trim.fastq
