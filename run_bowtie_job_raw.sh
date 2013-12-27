#!/bin/sh
if [ $# -lt 5 ]
then
    printf "\nUsage run_bowtie.sh [output dir] [reads dir] [index] [output suffix] [job script]\n"
    exit 0
fi

output_dir="$1"
reads_dir="$2"
index="$3"
suffix="$4"
script="$5"
for f in "$reads_dir"/*R1*.fq
do
    input_one="$f"
    input_two=$(echo "$f" | sed s/R1/R2/)
    job_name=$(basename "$f" | cut -f 1,2,3 -d "_")"$suffix"
    output="$output_dir"/"$job_name".sam
    #printf "Output dir %s\n" $output_dir
    #printf "Reads dir %s\n" $reads_dir
    #printf "Index file %s\n" $index
    #printf "Suffix %s \n" $suffix
    #printf "Script %s\n" $script
    #printf "Output %s\n\n" $output
    qsub -v input_one="$input_one",input_two="$input_two",output="$output",job_name="$job_name",index="$index" "$script"
done
