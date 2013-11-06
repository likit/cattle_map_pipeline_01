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
        header = '''
#!/bin/sh -login
#PBS -l nodes=1:ppn=4,mem=24gb,walltime=12:00:00
#PBS -m abe
#PBS -N RSEM_%s
'''
        command = '''
module load RSEM
cd %s
rsem-calculate-expression -p 4 --time --sam --paired-end --forward-prob 0 %s %s %s
'''

        header = header % os.path.split(f)[-1]
        sample_name = "_".join(f1.split('_')[:3])
        samfile = sample_name + '.transcripts.sam'
        command = command % (assembly_dir,
                                samfile,
                                reference,
                                sample_name)
        fp = open('%s_rsem_calc_job.sh' % f1, 'w')
        print >> fp, header
        print >> fp, command
        fp.close()

if __name__=='__main__':
    main()
