import sys
import os
import glob

def main():
    reads_dir = sys.argv[1]
    files = os.path.join(reads_dir, '*R1*pe')
    for f in glob.glob(files):
        print >> sys.stderr, 'writing a job file for %s' % f
        f1 = os.path.split(f)[-1]
        f2 = f1.replace('R1', 'R2')
        header = '''
#!/bin/sh -login
#PBS -l nodes=1:ppn=1,mem=12gb,walltime=12:00:00
#PBS -M preeyano@msu.edu
#PBS -m abe
#PBS -N Condetri_%s
'''
        command = '''
cd %s
perl ~/condetri_v2.1.pl -fastq1=%s -fastq2=%s -sc=33
'''

        header = header % os.path.split(f)[-1]
        command = command % (os.path.abspath(reads_dir), f1, f2)
        fp = open(f1 + '_condetri_job.sh', 'w')
        print >> fp, header
        print >> fp, command
        fp.close()

if __name__=='__main__':
    main()
