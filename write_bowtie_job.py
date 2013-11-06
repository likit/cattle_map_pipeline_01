import sys
import os
import glob

def main():
    reads_dir = os.path.abspath(sys.argv[1])
    assembly_dir = os.path.abspath(sys.argv[2])
    reference = sys.argv[3]
    files = os.path.join(reads_dir, '*pe*trim1*')
    for f in glob.glob(files):
        print >> sys.stderr, 'writing a job file for %s' % f
        f1 = os.path.split(f)[-1]
        f2 = f1.replace('trim1', 'trim2')
        header = '''
#!/bin/sh -login
#PBS -l nodes=1:ppn=4,mem=20gb,walltime=36:00:00
#PBS -m abe
#PBS -N Bowtie_%s
'''
        command = '''
module load bowtie
module load SAMTools
cd %s
bowtie --sam --phred33-quals -e 99999999 -a -m 200 -l 25 -I 1 -n 2 -X 1000 --nofw %s -1 %s -2 %s > %s.transcripts.sam
'''

        header = header % os.path.split(f)[-1]
        sample_name = "_".join(f1.split('_')[:3])
        command = command % (assembly_dir,
                                reference,
                                os.path.join(reads_dir, f1),
                                os.path.join(reads_dir, f2),
                                sample_name)
        fp = open('%s_bowtie_job.sh' % f1, 'w')
        print >> fp, header
        print >> fp, command
        fp.close()

if __name__=='__main__':
    main()
