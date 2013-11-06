import sys
import os
import glob

def main():
    reads_dir = sys.argv[1]
    files = os.path.join(reads_dir, '*pe*trim1*')
    for f in glob.glob(files):
        print >> sys.stderr, 'writing a job file for %s' % f
        f1 = os.path.split(f)[-1]
        f2 = f1.replace('trim1', 'trim2')
        header = '''
#!/bin/sh -login
#PBS -l nodes=1:ppn=4,mem=20gb,walltime=36:00:00
#PBS -m abe
#PBS -N Tophat_%s
'''
        command = '''
module load TopHat/2.0.8b
cd %s
tophat -o ../%s_tophat_out -r 150 -p 4 --library-type fr-firststrand ../bosTau7.fa.masked %s %s
'''

        header = header % os.path.split(f)[-1]
        command = command % (os.path.abspath(reads_dir), f1, f1, f2)
        fp = open('%s_tophat_job.sh' % f1, 'w')
        print >> fp, header
        print >> fp, command
        fp.close()

if __name__=='__main__':
    main()
