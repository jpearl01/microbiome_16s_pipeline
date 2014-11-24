#!/usr/bin/env bash

#Script to cluster OTUs from 16s sequencing runs on the pacbio

echo "Program requires arguments: fastq_from_pacbio name_of_sample max_expected_error truncation_length"


fastq_file=$1
echo -e "Fastq file:"'\t'$fastq_file
samp_name=$2
echo -e "Sample name:"'\t'$samp_name
ee=$3
echo -e "Expected error:"'\t'$ee
trunc_len=$4
echo -e "Truncation len:"'\t'$trunc_len
fasta_reads=${samp_name}_ee${ee}_tunc${trunc_len}.fasta
echo -e "Fasta output:"'\t'$fasta_reads
derep_fasta=${samp_name}_ee${ee}_tunc${trunc_len}_derep.fasta
echo -e "Derep output:"'\t'$derep_fasta
sorted=${samp_name}_ee${ee}_tunc${trunc_len}_sorted.fasta
otus=${samp_name}_ee${ee}_tunc${trunc_len}_otus.fasta
readmap=${samp_name}_ee${ee}_tunc${trunc_len}.uc
table=${samp_name}_ee${ee}_tunc${trunc_len}.table
utax=${samp_name}_ee${ee}_tunc${trunc_len}_utax.results
to_plot="data_to_plot.dat"

usearch -fastq_filter $fastq_file  -fastaout $fasta_reads -fastq_maxee $ee -fastq_trunclen $trunc_len -relabel barcodelabel=${samp_name}\;${samp_name}_ -eeout
usearch -derep_fulllength $fasta_reads -output $derep_fasta -sizeout -minseqlength 300
usearch -sortbysize $derep_fasta -output $sorted -minsize 4
python ~/programs/usearch/fasta_number.py $sorted OTU_ > $otus
usearch -usearch_global $fasta_reads -db $otus -strand plus -id 0.97 -uc $readmap
python ~/programs/usearch/uc2otutab.py $readmap > $table
usearch8 -utax $otus -db ~/Documents/rdp_16s.fa -strand plus -utax_rawscore -tt ~/Documents/rdp_16s.tt -utaxout $utax
#create a sorted file for the plot function
#grep 'OTUId' $table > ${to_plot}
#grep -v 'OTUId' $table | sort -n -k2 >> ${to_plot}
/home/josh/projects/brain/sort_and_filter_table.rb $utax $table
gnuplot -e "filename='${to_plot}'" /home/josh/projects/brain/plot.sh