!/usr/bin/env ruby

require 'bio'

#Program uses bioruby to match degenerate primers
#Usage: ruby match_primers.rb input.fastq


#Forward Primers
forward = Regexp.new('^g[agr]agagtttgat[tcy][acm]tggctcag')
f1 = Bio::Sequence::NA.new('TCAGACGATGCGTCAT')
f2 = Bio::Sequence::NA.new('TACTAGAGTAGCACTC')
f3 = Bio::Sequence::NA.new('ACACGCATGACACACT')
f4 = Bio::Sequence::NA.new('ACAGTCTATACTGCTG')


#Reverse Primers
reverse = Regexp.new('aagtcgtaacaaggta[agr]ccgta$')
r1 = Bio::Sequence::NA.new('CTATACATGACTCTGC')
r2 = Bio::Sequence::NA.new('TGTGTATCAGTACATG')
r3 = Bio::Sequence::NA.new('GATCTCTACTATATGC')
r4 = Bio::Sequence::NA.new('ATGATGTGCTACATCT')

total_seqs = 0
forward_match = 0
reverse_match = 0
both_match = 0

bc1 = File.open('barcode_1', 'w')
bc2 = File.open('barcode_2', 'w')
bc3 = File.open('barcode_3', 'w')
bc4 = File.open('barcode_4', 'w')

def match_forward(bc, sequence)
	return true if bc.to_re.match(sequence)
end

def match_reverse(bc, sequence)
	return true if bc.to_re.match(sequence)
end

=begin
Bio::FlatFile.auto(ARGV[0]) do |ff|
  ff.each do |entry|
    total_seqs += 1
    seq = entry.naseq
    forward_match += 1 if forward.match(seq)
    reverse_match += 1 if reverse.match(seq)
    both_match += 1 if forward.match(seq) && reverse.match(seq)
  end
end
=end

fm = File.open('forward_match_location', 'w')
rm = File.open('reverse_match_location', 'w')
Bio::FlatFile.auto(ARGV[0]) do |ff|
  ff.each do |entry|
    total_seqs += 1
    seq = entry.naseq
    fm.puts forward =~ seq if forward.match(seq)
    rm.puts reverse =~ seq if reverse.match(seq)
  end
end


puts "Total seqs: #{total_seqs}"
puts "Forward matches: #{forward_match}"
puts "Reverse matches: #{reverse_match}"
puts "Both match: #{both_match}"
