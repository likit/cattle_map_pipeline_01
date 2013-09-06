import sys
import glob
import os

def main():
    reads_dir = sys.argv[1]
    for f in glob.glob(os.path.join(reads_dir, '*R1*fastq.se')):
        f1 = f
        f2 = f.replace('R1', 'R2')
        merged_file = f1.replace('R1', 'R1&2').replace('fastq', 'fq')
        print >> sys.stderr, 'merging %s and %s' % (f1, f2)

        fp = open(merged_file, 'w')
        for line in open(f1):
            fp.write(line)
        for line in open(f2):
            fp.write(line)
        fp.close()


if __name__=='__main__':
    main()
