#!/usr/bin/env ruby

require 'bio'

#Program uses bioruby to match degenerate primers
#Usage: ruby match_primers.rb input.fastq


#Forward Primers
f_re = Regexp.new('(^g?[agr]?a?g?a?g?t?t?t?g?a?t[tcy][acm]tggctcag)')

#Reverse Primers
r_re = Regexp.new('(aagtcgtaacaa?g?g?t?a?[agr]?c?c?g?t?a?)$')
brain_r_re = Regexp.new('(ccagcag?c?c?g?c?g?g?t?a?a?t?)$')

total_seqs = 0
forward_match = 0
reverse_match = 0
both_match = 0

puts "Ambiguous forward primer base regex #{f_re}"
puts "Ambiguous reverse primer base regex #{f_re}"

fm = File.open('forward_match_lengths', 'w')
rm = File.open('reverse_match_lengths', 'w')
output = File.open('primers_trimmed.fasta', 'w')
Bio::FlatFile.auto(ARGV[0]) do |ff|
  ff.each do |entry|
    seq = entry.naseq
    total_seqs += 1
    f_match = f_re.match(seq)
    r_match = brain_r_re.match(seq)
    forward_match += 1 if !f_match.nil? 
    reverse_match += 1 if !r_match.nil? 
    if !r_match.nil? && !f_match.nil?
      both_match += 1 
      abort("#{r_match}") if r_match[1].nil?
      sub_seq = seq.subseq(f_match[1].length + 1, seq.length - r_match[1].length)
      output.puts(">#{entry.definition}")
      output.puts(sub_seq)
    end


    fm.puts f_match[1].length if !f_match.nil?
    rm.puts r_match[1].length if !r_match.nil?
  end
end


puts "Total seqs: #{total_seqs}"
puts "Forward matches: #{forward_match}"
puts "Reverse matches: #{reverse_match}"
puts "Both match: #{both_match}"
