#!/bin/sh -login
#PBS -l nodes=1:ppn=1,mem=20gb,walltime=24:00:00
#PBS -m abe
#PBS -N Bowtie2_build_trinity_part

module load bowtie2
module load SAMTools
cd $PBS_O_WORKDIR

bowtie2-build ../assembly/trinity_out_dir_stranded/Trinity_part.transcripts.fa Trinity_part
