trim-adapter:

	python protocol/write_trimmomatic_script.py raw
	#for f in *.gz_job.sh; do qsub "$$f"; done
	#rm *.gz_job.sh

quality-trim-paired:

	python protocol/write_condetri_job.py raw; for f in *.pe_condetri_job.sh; do qsub "$$f"; done
	rm *.pe_condetri_job.sh

quality-trim-single:

	python protocol/merge_se_reads.py raw/; \
	for f in raw/*fq.se; do \
		perl ~/condetri_v2.1.pl -fastq1=$$f -sc=33 | tee $$f.condetri_se_log; \
	done

merge-qc-trimmed-single:

	python protocol/merge_qc_se_reads.py raw

#fastqc_qc_trimmed:
#
#	module load FastQC; \
#	if [ ! -d ../FastQC_out_trimmed ]; then \
#		mkdir ../FastQC_out_trimmed; \
#	fi; \
#	for f in ../raw/*001.trim_unpaired.fastq; do \
#		fastqc --outdir ../FastQC_out_trimmed --threads 8 --noextract $$f; \
#	done; \
#	for f in ../raw/*trim?.fastq; do \
#		fastqc --outdir ../FastQC_out_trimmed --threads 8 --noextract $$f; \
#	done	

interleave-pe:

	qsub protocol/interleave.sh

normalize-pe:

	qsub protocol/normalize_pe.sh

normalize-se:

	qsub protocol/normalize_se.sh

filter-abund:

	qsub protocol/filter_abund.sh

extract-paired-reads:

	qsub protocol/extract_paired_reads.sh

merge_abundfilt_se:

	for f in *abundfilt.se; do \
		base_filename=$$(basename $$f .pe_trim.fastq.keep.abundfilt.se); \
		unpaired_filename=$$(echo $$base_filename | sed 's/R1/R1\&2/').trim_unpaired.fastq.keep.abundfilt; \
		new_filename=$$base_filename.se.qc.keep.abundfilt.gz; \
		echo "merging..." $$unpaired_filename $$f "to" $$new_filename; \
		cat $$unpaired_filename $$f | gzip -c > $$new_filename; \
	done

rename_abundfilt_pe:

	for f in *.pe_trim.fastq.keep.abundfilt.pe; do \
		newname=$$(basename $$f .pe_trim.fastq.keep.abundfilt.pe).pe.qc.keep.abundfilt; \
		echo "renaming" $$f "to" $$newname; \
		cp $$f $$newname; \
		gzip $$newname; \
	done; \

split_paired_reads:

	for f in *.pe.qc.keep.abundfilt.gz; do \
	 python ~/khmer/scripts/split-paired-reads.py $$f; \
	done
	cat *.1 > left.fq; \
	cat *.2 > right.fq
	gunzip -c *.se.qc.keep.abundfilt.gz >> left.fq

run_trinity:

	qsub protocol/trinity.sh

merge-lanes:

	for one in raw/*L001*.fastq.gz; do \
		two=$$(echo $$one | sed 's/L001/L002/'); \
		merged=$$(echo $$one | sed 's/L001/merged/'); \
		echo "merging " $$one " and " $$two; \
		zcat $$one $$two > $$merged; \
	done

run-rsem-calc:

	for left in raw/*merged*R1*.fastq.gz; do \
		sample=$$(basename $$left _R1_001.fastq.gz); \
		right=$$(echo $$left | sed 's/R1/R2/'); \
		qsub -v input_read1=$$left,input_read2=$$right,sample_name=$$sample,index="assembly/TRANS" protocol/rsem_calculate_expr_paired.sh; \
	done


partition_transcripts:

	python ~/khmer/scripts/do-partition.py -x 1e9 -N 4 --threads 4 taurus assembly/TRANS.transcripts.flt.fa

run-rsem-prepare:

	cd assembly; ~/rsem-1.2.7/extract-transcript-to-gene-map-from-trinity Trinity.fasta Trinity.map
	cd assembly; qsub ../protocol/rsem_prepare_reference.sh
	cd assembly; qsub -v left="../raw/4642MAP_CGATGT_L001_R1_001.fastq.gz",right="../raw/4642MAP_CGATGT_L001_R2_001.fastq.gz" ../protocol/run_rsem.sh

run-blat-transcripts:

	cd assembly; qsub -v input="TRANS.transcripts.flt.fa" ../protocol/blat_job.sh
