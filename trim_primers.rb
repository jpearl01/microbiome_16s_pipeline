#!/usr/bin/env ruby

require 'bio'

#Program uses bioruby to match degenerate primers
#Usage: ruby match_primers.rb input.fastq output_file


#Forward Primers (normal and reverse complement)
f_re = Regexp.new('(^g?[agr]?a?g?a?g?t?t?t?g?a?t[tcy][acm]tggctcag)')
f_re_rc = Regexp.new('(ctgagcca[tgk][agr]at?c?a?a?a?c?t?c?t?[tcy]?c?)$')


#Reverse Primers (normal and reverse complement)
r_re = Regexp.new('(aagtcgtaacaa?g?g?t?a?[agr]?c?c?g?t?a?)$')
r_re_rc = Regexp.new('^(t?a?c?g?g?[tcy]?t?a?c?c?t?tgttacgactt)')

brain_r_re = Regexp.new('(ccagcag?c?c?g?c?g?g?t?a?a?t?)$')

total_seqs = 0
forward_match = 0
reverse_match = 0
both_match = 0

puts "Ambiguous forward primer base regex #{f_re}"
puts "Ambiguous reverse primer base regex #{r_re}"

fm = File.open('forward_match_lengths', 'w')
rm = File.open('reverse_match_lengths', 'w')
fnr = File.open('forward_not_reverse.fastq', 'w')
rnf = File.open('reverse_not_forward.fastq', 'w')
output = File.open(ARGV[1], 'w')

def get_subsequence(f_match_len, r_match_len, seq)
  sub_seq = seq.subseq(f_match_len + 1, seq.length - r_match_len)
  sub_seq.upcase
end

def write_fastq_entry(header, sequence, qual, fh)
  fh.puts('@' + header)
  fh.puts(sequence.upcase)
  fh.puts("+")
  fh.puts(qual)
end

Bio::FlatFile.auto(ARGV[0]) do |ff|
  db_class = ''
  if Regexp.new('Fasta').match(ff.dbclass.to_s)
    db_class = 'fasta'
    fnr = File.open('forward_not_reverse.fasta', 'w')
    rnf = File.open('reverse_not_forward.fasta', 'w')

  elsif Regexp.new('Fastq').match(ff.dbclass.to_s)
    db_class = 'fastq'
    fnr = File.open('forward_not_reverse.fastq', 'w')
    rnf = File.open('reverse_not_forward.fastq', 'w')
  else 
    abort("I don't recognize this kind of file")
  end

  
  ff.each do |entry|
    rev_comp = false
    seq = entry.naseq
    total_seqs += 1

    f_match = f_re.match(seq)
    r_match = r_re.match(seq)
    if f_match && r_match
      forward_match += 1 if f_match 
      reverse_match += 1 if r_match 
    else
      f_match = f_re_rc.match(seq)
      r_match = r_re_rc.match(seq)
      rev_comp = true if f_match && r_match
      forward_match += 1 if f_match 
      reverse_match += 1 if r_match 
    end      

    if r_match && f_match
      both_match += 1
      f_len = f_match[1].length
      r_len = r_match[1].length
      seq = seq.complement if rev_comp
      sub_seq = get_subsequence(f_len, r_len, seq)
      fm.puts f_len
      rm.puts r_len

      if db_class == 'fasta'
        abort("#{r_match}") if r_match[1].nil?
        output.puts(">#{entry.definition}")
        output.puts(sub_seq)
      else
        q = entry.quality_string
        q = q.reverse if rev_comp
        end_qual = seq.length - r_len - 1
        sub_qual = q[ f_len .. end_qual ]
        write_fastq_entry(entry.definition, sub_seq, sub_qual, output)

      end

    elsif f_match
      if db_class == 'fasta'
        fnr.puts(">#{entry.definition}")
        fnr.puts(seq.upcase)
      else
        q = entry.quality_string
        q = q.reverse if rev_comp
        write_fastq_entry(entry.definition, seq, q, fnr)
      end

    elsif r_match
       if db_class == 'fasta'
        rnf.puts(">#{entry.definition}")
        rnf.puts(seq.upcase)
      else
        q = entry.quality_string
        q = q.reverse if rev_comp
        write_fastq_entry(entry.definition, seq, q, rnf)
      end
    end
  end
end


puts "Total seqs: #{total_seqs}"
puts "Forward matches: #{forward_match}"
puts "Reverse matches: #{reverse_match}"
puts "Both match: #{both_match}"
