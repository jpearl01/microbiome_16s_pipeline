#!/usr/bin/env ruby

require 'bio'

#Program uses bioruby to match degenerate primers
#Usage: ruby match_primers.rb input.fastq output_file


#Forward Primers
f_re = Regexp.new('(a?g?[agr]?g?t?t?[tcy]?g?a?t?[tcy][acm]tggctcag)')

#Reverse Primers
r_re = Regexp.new('(aagtcgtaacaa?g?g?t?a?[agr]?c?[tcy]?)')


total_seqs = 0
forward_match = 0
reverse_match = 0
both_match = 0
not_both_match = 0

puts "Ambiguous forward primer base regex #{f_re}"
puts "Ambiguous reverse primer base regex #{r_re}"

fm = File.open('forward_match_lengths', 'w')
rm = File.open('reverse_match_lengths', 'w')
output = File.open(ARGV[1], 'w')
Bio::FlatFile.auto(ARGV[0]) do |ff|
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
    f_match = f_re.match(seq)
    r_match = r_re.match(seq)
    forward_match += 1 if !f_match.nil? 
    reverse_match += 1 if !r_match.nil? 
    #Adding in the ability to check the reverse complement of the sequence, if there was no hit
    if f_match.nil? && r_match.nil?
        f_match = f_re.match(seq.complement)
        r_match = r_re.match(seq.complement)
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
      else
        not_both_match += 1
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
puts "Mismatched: #{not_both_match}"
