#!/bin/sh -login
#PBS -l nodes=1:ppn=4,mem=24gb,walltime=72:00:00
#PBS -m abe
#PBS -N blast_cow_x_mouse_proteins
#PBS -A ged-intel11

cd /mnt/ls12/preeyanon/cattle_map/paired/assembly/trinity_out_dir_stranded_new_partitions
blastall -i Trinity.fasta.part.renamed.fasta -d mouse.protein.faa -e 1e-3 -p blastx -o cow.x.mouse -a 8 -v 4 -b 4
