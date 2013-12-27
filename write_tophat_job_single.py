import sys
import os
import glob

def main():
    reads_dir = sys.argv[1]
    files = os.path.join(reads_dir, '*trim_unpaired.fastq')
    for f in glob.glob(files):
        print >> sys.stderr, 'writing a job file for %s' % f
        input_file = os.path.split(f)[-1]
        header = '''
#!/bin/sh -login
#PBS -l nodes=1:ppn=4,mem=20gb,walltime=36:00:00
#PBS -m abe
#PBS -N Tophat_%s
'''
        command = '''
module load TopHat/2.0.8b
cd %s
tophat -o ../%s_tophat_out -j %s -p 4 ../bosTau7.fa.masked %s
'''

        header = header % os.path.split(f)[-1]
        junctions_path = input_file.replace('R1_R2', 'R1').split('.')[0] + \
                                '.pe_trim1.fastq_tophat_out/junctions.junc'
        command = command % (os.path.abspath(reads_dir),
                                input_file, os.path.join('../tophat', junctions_path), input_file)
        fp = open('%s_tophat_job.sh' % input_file, 'w')
        print >> fp, header
        print >> fp, command
        fp.close()

if __name__=='__main__':
    main()
