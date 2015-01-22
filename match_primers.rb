#!/usr/bin/env ruby

require 'bio'

#Program uses bioruby to match degenerate primers
#Usage: ruby match_primers.rb input.fastq


#Forward Primers
forward = Regexp.new('^g[agr]agagtttgat[tcy][acm]tggctcag')

#Reverse Primers
reverse = Regexp.new('aagtcgtaacaaggta[agr]ccgta$')

total_seqs = 0
forward_match = 0
reverse_match = 0
both_match = 0

puts "Ambiguous forward primer base regex #{forward}"
puts "Ambiguous reverse primer base regex #{reverse}"

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
