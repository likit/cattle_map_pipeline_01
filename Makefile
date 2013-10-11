trim_adapter:
	python write_trimmomatic_script.py ../raw
	for f in *.gz_job.sh; do \
	qsub "$$f"; \
	done

quality_trim_paired:
	python write_condetri_job.py ../raw; for f in *.pe_condetri_job.sh; do qsub "$$f"; done

quality_trim_single:
	python merge_se_reads.py ../raw/; \
	for f in ../raw/*fq.se; do \
		perl ~/condetri_v2.1.pl -fastq1=$$f -sc=33 | tee $$f.condetri_se_log; \
	done

merge_qc_trimmed_single:
	python merge_qc_se_reads.py ../raw

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
	qsub interleave.sh

normalize_pe:
	qsub normalize_pe.sh

normalize_se:
	qsub normalize_se.sh

filter_abund:
	qsub filter_abund.sh

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
	cat *.1 | left.fq; \
	cat *.2 | right.fq

split_paired_reads:
	for f in ../raw/*.pe.qc.keep.abundfilt.gz; do \
	 python ~/khmer/scripts/split-paired-reads.py $$f; \
	done

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
	
build_blastdb:
	formatdb -i trinity-nematostella.renamed.fa -o T -p F
	formatdb -i mouse.protein.faa -o T -p T

reciprocal_blast:
	qsub run_blast_cow_x_mouse.sh
	qsub run_blast_mouse_x_cow.sh

annotate:
	python ~/eel-pond/make-uni-best-hits.py cow.x.mouse cow.x.mouse.homol
	python ~/eel-pond/make-reciprocal-best-hits.py cow.x.mouse mouse.x.cow cow.x.mouse.ortho
	
clean:
	rm *pe_trim_unpaired.fastq; \
	rm *se_trim.fastq

