#/usr/bin/env ruby

#Usage: ruby create_bed_from_primer_matches.rb matches.txt
#where matches.txt is the output from the search_oligodb usearch algorithm

#Going with the convention that forward primers end with an 'F' and reverse with an 'R'

#primer matches file handle
pm_fh = ARGV[0]

class Bed_record
  attr_accessor :fasta_rec, :start, :end
end

rec_hash = {}

File.open(pm_fh).each do |line|
  a = line.split
  if /.+F$/.match(a[1])
    rec_hash[a[0]] = Bed_record.new if rec_hash[a[0]].nil?
    rec_hash[a[0]].fasta_rec = a[0]
    rec_hash[a[0]].start = a[2]
  elsif /.+R$/.match(a[1])
    rec_hash[a[0]] = Bed_record.new if rec_hash[a[0]].nil?
    rec_hash[a[0]].fasta_rec = a[0]
    rec_hash[a[0]].end = a[3]
  end
end

bed_fn = File.basename(pm_fh) + ".bed"

bed_fh = File.open(bed_fn, 'w')

rec_hash.each do |k, v|
  next if v.start.nil? || v.end.nil?
  bed_fh.puts v.fasta_rec.to_s + "\t" + v.start.to_s + "\t" + v.end.to_s
end
