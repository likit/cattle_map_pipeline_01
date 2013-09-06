import sys
import glob
import os

def main():
    reads_dir = sys.argv[1]
    for f in glob.glob(os.path.join(reads_dir, '*_R1_*unpaired.fastq')):
        f1 = f
        f2 = f.replace('R1', 'R1&2')
        f2 = os.path.split(f2)[-1].split('.')[0] + '.se_trim.fastq'
        f2 = os.path.join(reads_dir, f2)
        merged_file = f1.replace('pe_', '').replace('R1', 'R1&2')
        print >> sys.stderr, 'merging %s and %s' % (f1, f2)

        fp = open(merged_file, 'w')
        for line in open(f1):
            fp.write(line)
        for line in open(f2):
            fp.write(line)
        fp.close()


if __name__=='__main__':
    main()
