#!/bin/sh -login
#PBS -l nodes=1:ppn=8,mem=24gb,walltime=72:00:00
#PBS -m abe
#PBS -N blast_human_x_cow_transcripts
#PBS -A ged-intel11

cd /mnt/ls12/preeyanon/cattle_map/paired/assembly/trinity_out_dir_stranded_new_partitions
blastall -i human.protein.faa -d Trinity.fasta.part.renamed.fasta -e 1e-3 -p tblastn -o human.x.cow -a 8 -v 4 -b 4
