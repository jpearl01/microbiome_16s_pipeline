#!/usr/bin/env ruby
require 'bio'
#Program to pull out the strand inforamtion from a pacbio fastq after a Reads of Insert protocol
#only input should be the fastq (or fasta), although hardcoded the location of the rdp_16s location

#usage: ./fix_rev_comp_16s.rb reads.fq out_reads.fq

abort('Not a file!') unless File.exists?(ARGV[0])

strand_file = "strand_info"

`usearch -usearch_global #{ARGV[0]} -db ~/Documents/rdp_16s_8.udb -id 0.8 -strand both -userout #{strand_file} -userfields query+qstrand`

strand_hash = Hash[*File.read(strand_file).split]

output = File.open(ARGV[1], 'w')
count = 1

Bio::FlatFile.auto(ARGV[0]) do |ff|
	ff.each do |entry|
		next unless strand_hash.has_key?(entry.definition.split[0])
		if strand_hash[entry.definition.split[0]] == '+' && ARGV[2].nil?
			output.write(entry.to_s)
		elsif strand_hash[entry.definition.split[0]] == '+' && !ARGV[2].nil?
			output.write('@' + "#{ARGV[2]}#{count}" + "\n")
			output.write(entry.naseq.upcase)
			output.write("\n+\n")
			output.write(entry.quality_string + "\n")
		elsif strand_hash[entry.definition.split[0]] == '-' && ARGV[2].nil?
			#The most annoying way to reverse complement a fastq record in history
			output.write('@' + entry.definition + "\n")
			output.write(entry.naseq.reverse_complement.upcase)
			output.write("\n+\n")
			output.write(entry.quality_string.reverse + "\n")
		elsif strand_hash[entry.definition.split[0]] == '-' && !ARGV[2].nil?
			output.write('@' + "#{ARGV[2]}#{count}" + "\n")
			output.write(entry.naseq.reverse_complement.upcase)
			output.write("\n+\n")
			output.write(entry.quality_string.reverse + "\n")
		end
		count += 1
	end
end
