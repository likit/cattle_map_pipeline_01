import sys
import glob
import os


def main():
    reads_dir = sys.argv[1]
    fileext = os.path.join(reads_dir, '*R1*fastq.gz')
    for f in glob.glob(fileext):
        print >> sys.stderr, 'writing a job file for %s' % f
        m1 = f
        m2 = f.replace('R1', 'R2')
        m1_pe = os.path.splitext(m1)[0] + ('.pe')
        m2_pe = os.path.splitext(m2)[0] + ('.pe')
        m1_se = os.path.splitext(m1)[0] + ('.se')
        m2_se = os.path.splitext(m2)[0] + ('.se')

        header = '''
#!/bin/sh -login
#PBS -l nodes=1:ppn=4,mem=24gb,walltime=12:00:00
#PBS -m abe
#PBS -N Trimmomatic_%s
#PBS -A ged-intel11
'''

        command = '''
cd ${PBS_O_WORKDIR} 
java -jar ~/Trimmomatic-0.30/trimmomatic-0.30.jar PE -threads 4 -phred33 %s %s %s %s %s %s ILLUMINACLIP:./protocols/TruSeq2-PE.fa:2:30:10 MINLEN:50
'''
        header = header % os.path.split(m1)[-1]
        command = command % (m1, m2, m1_pe, m1_se, m2_pe, m2_se)
        fp = open('%s_job.sh' % os.path.split(f)[-1], 'w')
        print >> fp, header
        print >> fp, command
        fp.close()


if __name__=='__main__':
    main()
