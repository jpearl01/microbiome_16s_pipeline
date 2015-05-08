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
named=${samp_name}_ee${ee}_tunc${trunc_len}_otus_named.fasta
readmap=${samp_name}_ee${ee}_tunc${trunc_len}.uc
table=${samp_name}_ee${ee}_tunc${trunc_len}.table
utax=${samp_name}_ee${ee}_tunc${trunc_len}_utax.results
to_plot="data_to_plot.dat"

# -fastq_trunclen $trunc_len -relabel barcodelabel=${samp_name}\;${samp_name}_ -eeout
usearch -fastq_filter $fastq_file  -fastaout $fasta_reads -fastq_maxee $ee
usearch -derep_fulllength $fasta_reads -fastaout $derep_fasta -sizeout 
usearch -sortbysize $derep_fasta -fastaout $sorted -minsize 2

usearch -cluster_otus $sorted -otus $otus
python ~/external_bio_programs/usearch/fasta_number.py $otus OTU_ > $named
usearch -usearch_global $fasta_reads -strand both -db $named -id 0.97 -uc $readmap
python ~/external_bio_programs/usearch/uc2otutab.py $readmap > $table
usearch -utax $named -db ~/Documents/rdp_16s.fa -utax_rawscore -tt ~/Documents/rdp_16s.tt -utaxout $utax
#create a sorted file for the plot function
#grep 'OTUId' $table > ${to_plot}
#grep -v 'OTUId' $table | sort -n -k2 >> ${to_plot}
~/workspace/bioruby/microbiome_16s_pipeline/sort_and_filter_table.rb $utax $table
gnuplot -e "filename='${to_plot}'" ~/workspace/bioruby/microbiome_16s_pipeline/plot.sh