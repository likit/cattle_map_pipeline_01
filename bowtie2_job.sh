#!/bin/sh -login
#PBS -l nodes=1:ppn=4,mem=20gb,walltime=36:00:00
#PBS -m abe
#PBS -N Bowtie2_${job_name}

module load bowtie2
module load SAMTools
cd $PBS_O_WORKDIR
bowtie2 -X 1000 --nofw ${index} -1 ${input_one} -2 ${input_two} -S ${output}
