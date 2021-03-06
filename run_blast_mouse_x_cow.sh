#!/bin/sh -login
#PBS -l nodes=1:ppn=4,mem=24gb,walltime=72:00:00
#PBS -m abe
#PBS -N blast_mouse_x_cow_transcripts
#PBS -A ged-intel11

cd /mnt/ls12/preeyanon/cattle_map/paired/assembly/trinity_out_dir_stranded_new_partitions
blastall -i mouse.protein.faa -d Trinity.fasta.part.renamed.fasta -e 1e-3 -p tblastn -o mouse.x.cow -a 8 -v 4 -b 4
