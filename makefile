trim_adapter:

	python protocols/write_trimmomatic_script.py raw
	#for f in *.gz_job.sh; do qsub "$$f"; done
	#rm *.gz_job.sh

quality_trim_paired:

	python protocols/write_condetri_job.py raw; for f in *.pe_condetri_job.sh; do qsub "$$f"; done
	rm *.pe_condetri_job.sh

quality_trim_single:

	python protocols/merge_se_reads.py raw/; \
	for f in raw/*fq.se; do \
		perl ~/condetri_v2.1.pl -fastq1=$$f -sc=33 | tee $$f.condetri_se_log; \
	done

merge_qc_trimmed_single:

	python protocols/merge_qc_se_reads.py raw

fastqc_qc_trimmed:

	module load FastQC; \
	if [ ! -d ../FastQC_out_trimmed ]; then \
		mkdir ../FastQC_out_trimmed; \
	fi; \
	for f in ../raw/*001.trim_unpaired.fastq; do \
		fastqc --outdir ../FastQC_out_trimmed --threads 8 --noextract $$f; \
	done; \
	for f in ../raw/*trim?.fastq; do \
		fastqc --outdir ../FastQC_out_trimmed --threads 8 --noextract $$f; \
	done	

interleave_pe:

	qsub protocols/interleave.sh

normalize_pe:

	qsub protocols/normalize_pe.sh
	mv *keep raw/

normalize_se:

	qsub protocols/normalize_se.sh
	mv *keep raw/

filter_abund:

	qsub protocols/filter_abund.sh

extract_paired_reads:

	qsub extract_paired_reads.sh

merge_abundfilt_se:

	for f in ../raw/*abundfilt.se; do \
		base_filename=$$(basename $$f .pe_trim.fastq.keep.abundfilt.se); \
		unpaired_filename=$$(echo $$base_filename | sed 's/R1/R1\&2/').trim_unpaired.fastq.keep.abundfilt; \
		new_filename=$$base_filename.se.qc.keep.abundfilt.gz; \
		echo "merging..." $$unpaired_filename $$f "to" $$new_filename; \
		cat $$unpaired_filename $$f | gzip -c > $$new_filename; \
	done

rename_abundfilt_pe:

	for f in ../raw/*.pe_trim.fastq.keep.abundfilt.pe; do \
		newname=$$(basename $$f .pe_trim.fastq.keep.abundfilt.pe).pe.qc.keep.abundfilt; \
		echo "renaming" $$f "to" $$newname; \
		cp $$f $$newname; \
		gzip $$newname; \
	done; \

split_paired_reads:

	for f in ../raw/*.pe.qc.keep.abundfilt.gz; do \
	 python ~/khmer/scripts/split-paired-reads.py $$f; \
	done
	cat *.1 > left.fq; \
	cat *.2 > right.fq
	gunzip -c *.se.qc.keep.abundfilt.fq.gz >> left.fq

run_trinity:

	qsub trinity_job.sh

partition_transcripts:

	python ~/khmer/scripts/do-partition.py -x 1e9 -N 4 --threads 4 taurus Trinity.fasta

seqclean_transcripts:

	~/seqclean-x86_64/seqclean Trinity.fasta -c 4

partition_cleaned_transcripts:

	python ~/khmer/scripts/do-partition.py -x 1e9 -N 4 --threads 4 taurus Trinity.fasta.clean

rename_partitions:

	python ~/eel-pond/rename-with-partitions.py taurus Trinity.fasta.part

download_mouse_proteins:

	curl -O ftp://ftp.ncbi.nih.gov/refseq/M_musculus/mRNA_Prot/mouse.protein.faa.gz
	gunzip mouse.protein.faa.gz

download_human_proteins:

	curl -O ftp://ftp.ncbi.nih.gov/refseq/H_sapiens/mRNA_Prot/human.protein.faa.gz
	gunzip human.protein.faa.gz
	
download_cow_proteins:

	curl -O ftp://ftp.ncbi.nih.gov/refseq/B_taurus/mRNA_Prot/cow.protein.faa.gz
	guzip cow.protein.faa.gz

build_blastdb:

	formatdb -i Trinity.fasta.part.renamed.fasta -o T -p F
	formatdb -i mouse.protein.faa -o T -p T

build_blastdb_human:

	formatdb -i human.protein.faa -o T -p T
	
build_blastdb_cow:

	formatdb -i cow.protein.faa -o T -p T

reciprocal_blast:

	qsub run_blast_cow_x_mouse.sh
	qsub run_blast_mouse_x_cow.sh

annotate:

	python ~/eel-pond/make-uni-best-hits.py cow.x.mouse cow.x.mouse.homol
	python ~/eel-pond/make-reciprocal-best-hits.py cow.x.mouse mouse.x.cow cow.x.mouse.ortho
	python ~/eel-pond/make-namedb.py mouse.protein.faa mouse.namedb
	python -m screed.fadbm mouse.protein.faa
	python ~/eel-pond/annotate-seqs.py Trinity.fasta.part.renamed.fasta cow.x.mouse.ortho cow.x.mouse.homol

tophat_map:

	python write_tophat_job.py ../qc_trimmed
	for f in *tophat_job.sh; do \
		qsub $$f; \
	done

rsem:

	cd /mnt/ls12/preeyanon/cattle_map/paired/assembly/trinity_out_dir_stranded_new_partitions; \
	extract-transcript-to-gene-map-from-trinity Trinity.fasta.part.renamed.fasta Trinity.mapfile
	cd /mnt/ls12/preeyanon/cattle_map/paired/assembly/trinity_out_dir_stranded_new_partitions; \
	rsem-prepare-reference --transcript-to-gene-map --no-bowtie Trinity.mapfile Trinity.fasta.part.renamed.fasta taurus

count_reads:

	samtools view -S -H 4642MAP_CGATGT_L001_cdna_bowtie2_raw.sam | python header_to_bed.py > sequences.bed

clean:

	rm *pe_trim_unpaired.fastq; \
	rm *se_trim.fastq