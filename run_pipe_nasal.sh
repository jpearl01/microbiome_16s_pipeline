#!/usr/bin/env bash
#modify the labels to only include the barcode, which we don't know :-/
#perl -pi.bak -e 's/>.+/>barcodelabel=undetermined\;PC_$./' barcode_label.fasta

if [ $# -ne 4 ]; then
    echo "Must have 4 arguments to run this script, fastq_file sample_name ee trunc_len"
    exit 0
fi

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

#Option for truncating
#-fastq_trunclen $trunc_len 

#Option for relabelling, which hopefully we don't need anymore
#-relabel barcodelabel=${samp_name}\;${samp_name}_ -eeout -fastq_trunclen $trunc_len 

#need this if starting from fastq
usearch -fastq_filter $fastq_file  -fastaout $fasta_reads -fastq_maxee $ee 
#-minuniquesize 2
#usearch -derep_fulllength $fasta_reads -fastaout derep.fasta -sizeout 
usearch -derep_fulllength $fasta_reads -fastaout derep.fasta -sizeout -strand both
usearch -sortbysize derep.fasta -fastaout sorted.fasta
usearch -cluster_otus sorted.fasta -otus old_otus.fasta -uparseout uparseout -sizeout -sizein -strand both
python ~/bin/fasta_number.py old_otus.fasta OTU_ > otus.fasta
usearch -usearch_global $fastq_file -db otus.fasta -strand both -uc readmap -id .97
python ~/bin/uc2otutab.py readmap > table
#Remember to change the taxconfs if not using fl (full length) sequences also chaned the database to use greengenes, hopefully species level assignment
#I don't have the tt and tc files for the greengenes database and therefore can't get a species level assignment
#TODO: find a species level assignment databse
usearch -utax otus.fasta -db ~/Documents/rdp_16s_64bit.udb -taxconfs ~/Documents/rdp_16s_fl.tc -tt ~/Documents/rdp_16s.tt -utaxout utax
sort_and_filter_table.rb utax table
gnuplot -e "filename='data_to_plot.dat'" ~/bin/plot.sh
