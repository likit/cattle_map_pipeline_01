#!/bin/sh -login
#PBS -l nodes=1:ppn=8,mem=126gb,walltime=72:00:00
#PBS -M preeyano@msu.edu
#PBS -m abe
#PBS -N Trinity_${PBS_JOBID}

export PATH=/opt/cus/java/jre1.6.0_18/bin/java:$PATH

module load trinity/20130225
module load bowtie

ulimit -s unlimited
cd ${PBS_O_WORKDIR}

Trinity.pl --output assembly --SS_lib_type RF --seqType fq --left left.fq --right right.fq --CPU 8 --bflyHeapSpaceInit 4G --JM 60G
