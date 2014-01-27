#!/bin/sh -login
#PBS -l nodes=1:ppn=4,mem=24gb,walltime=24:00:00
#PBS -M preeyano@msu.edu
#PBS -m abe
#PBS -N Seqclean_${PBS_JOBID}
#PBS -A ged-intel11

cd ${PBS_O_WORKDIR}

/mnt/home/preeyano/seqclean-x86_64/seqclean ${input} -c 4
