#!/usr/bin/env ruby

require 'bio'
require 'damerau-levenshtein'

#Program uses bioruby to match degenerate primers
#Usage: ruby match_primers.rb forward_primer reverse_primer input.fastq output_file

fp   = ARGV[0]
rp   = ARGV[1]
inpt = ARGV[2]
outp = ARGV[3]

dl = DamerauLevenshtein

total_seqs = 0
forward_match = 0
reverse_match = 0
both_match = 0

puts "Forward primer base regex #{fp}"
puts "Reverse primer base regex #{rp}"

fm = File.open('forward_match_lengths', 'w')
rm = File.open('reverse_match_lengths', 'w')
output = File.open(outp, 'w')
Bio::FlatFile.auto(inpt) do |ff|
  db_class = ''
  if Regexp.new('Fasta').match(ff.dbclass.to_s)
    db_class = 'fasta'
  elsif Regexp.new('Fastq').match(ff.dbclass.to_s)
    db_class = 'fastq'
  else 
    abort("I don't recognize this kind of file")
  end
  ff.each do |entry|
    seq = entry.naseq
    is_comp = false
    total_seqs += 1
    f_match = dl(seq[0..21], fp)
    r_match = dl(seq[-22..-1], rp)
    forward_match += 1 if f_match < 7 
    reverse_match += 1 if r_match < 7 
    #Adding in the ability to check the reverse complement of the sequence, if there was no hit
    if f_match.nil? && r_match.nil?
        f_match = dl(seq.complement[0..21], fp)
        r_match = dl(seq.complement[-22..-1], rp)
        forward_match += 1 if !f_match.nil? 
        reverse_match += 1 if !r_match.nil? 
        is_comp = true
    end

    if db_class == 'fasta'
      if !r_match.nil? && !f_match.nil?
        both_match += 1 
        abort("Unexpected match: #{r_match}") if r_match[1].nil?
        if is_comp
            seq = seq.complement
            sub_seq = seq.subseq(f_match[1].length + 1, seq.length - r_match[1].length)
            cap_sub_seq = sub_seq.swapcase
            output.puts(">#{entry.definition}")
            output.puts(cap_sub_seq)
        else
            sub_seq = seq.subseq(f_match[1].length + 1, seq.length - r_match[1].length)
            cap_sub_seq = sub_seq.swapcase
            output.puts(">#{entry.definition}")
            output.puts(cap_sub_seq)
        end
    end
    else
      if !r_match.nil? && !f_match.nil?
        both_match += 1
        if is_comp
            seq = seq.complement
            sub_seq = seq.subseq(f_match[1].length + 1, seq.length - r_match[1].length)
            cap_sub_seq = sub_seq.swapcase
            end_qual = seq.length - r_match[1].length - 1
            sub_qual = entry.quality_string.reverse[f_match[1].length .. end_qual ]
            output.write('@' + entry.definition + "\n")
            output.write(cap_sub_seq)
            output.write("\n+\n")
            output.write(sub_qual + "\n")
        else
            sub_seq = seq.subseq(f_match[1].length + 1, seq.length - r_match[1].length)
            cap_sub_seq = sub_seq.swapcase
            end_qual = seq.length - r_match[1].length - 1
            sub_qual = entry.quality_string[f_match[1].length .. end_qual ]
            output.write('@' + entry.definition + "\n")
            output.write(cap_sub_seq)
            output.write("\n+\n")
            output.write(sub_qual + "\n")
        end
      end
    end


    fm.puts f_match[1].length if !f_match.nil?
    rm.puts r_match[1].length if !r_match.nil?
  end
end


puts "Total seqs: #{total_seqs}"
puts "Forward matches: #{forward_match}"
puts "Reverse matches: #{reverse_match}"
puts "Both match: #{both_match}"
