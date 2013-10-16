#!/bin/sh -login
#PBS -l nodes=1:ppn=1,mem=20gb,walltime=24:00:00
#PBS -m abe
#PBS -N RSEM_prepare_reference


module load bowtie/1.0.0
module load RSEM

cd /mnt/ls12/preeyanon/cattle_map/paired/assembly/trinity_out_dir_stranded_new_partitions
rsem-prepare-reference --transcript-to-gene-map Trinity.mapfile Trinity.fasta.part.renamed.fasta taurus
