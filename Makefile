trim_adapter:
	python write_trimmomatic_script.py ../raw; for f in *.gz_job.sh; do qsub "$f"; done

quality_trim_paired:
	python write_condetri_job.py ../raw; for f in *.pe_condetri_job.sh; do qsub "$f"; done

quality_trim_single:
	python merge_se_reads.py ../raw/; \
	for f in ../raw/*fq.se; do \
		perl ~/condetri_v2.1.pl -fastq1=$$f -sc=33 | tee $$f.condetri_se_log; \
	done

merge_qc_trimmed_single:
	python scripts/merge_qc_se_reads.py ../

fastqc_qc_trimmed:
	mkdir ../FastQC_out_trimmed; \
	for f in ../*fastq; do \
		fastqc --outdir ../FastQC_out_trimmed --threads 8 --noextract $$f; \
	done

interleave_pe:
	qsub interleave.sh

clean:
	rm *pe_trim_unpaired.fastq; \
	rm *se_trim.fastq

