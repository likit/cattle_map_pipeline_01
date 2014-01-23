#!/bin/sh -login
#PBS -l nodes=1:ppn=32,mem=24gb,walltime=72:00:00
#PBS -M preeyano@msu.edu
#PBS -m abe
#PBS -N RSEM_calc_expr_${sample_name}

cd ${PBS_O_WORKDIR}
module load bowtie
/mnt/home/preeyano/rsem-1.2.7/rsem-calculate-expression --paired-end --time -p 32 ${input_read1} ${input_read2} ${index} ${sample_name}
