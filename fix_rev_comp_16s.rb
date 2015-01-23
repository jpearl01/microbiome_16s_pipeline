#!/usr/bin/env ruby
require 'bio'
#Program to pull out the strand inforamtion from a pacbio fastq after a Reads of Insert protocol
#only input should be the fastq (or fasta), although hardcoded the location of the rdp_16s location
	
#usage: ./fix_rev_comp_16s.rb reads.fq out_reads.fq new_header_name
	
abort('Not a file!') unless File.exists?(ARGV[0])
	
strand_file = "strand_info"
	
`usearch -usearch_global #{ARGV[0]} -db ~/Documents/rdp_16s_8.udb -id 0.8 -strand both -userout #{strand_file} -userfields query+qstrand`
	
strand_hash = Hash[*File.read(strand_file).split]

output = File.open(ARGV[1], 'w')
count = 1

#Let's dry this out with a method	
def write_to_fastq (fh, header, sequence, quality)
	fh.write('@' + header + "\n")
	fh.write(sequence)
	fh.write("\n+\n")
	fh.write(quality + "\n")
end

Bio::FlatFile.auto(ARGV[0]) do |ff|
	ff.each do |entry|
		next unless strand_hash.has_key?(entry.definition.split[0])
		if strand_hash[entry.definition.split[0]] == '+' && ARGV[2].nil?
			#write output with same header, and same strand
			output.write(entry.to_s)
		elsif strand_hash[entry.definition.split[0]] == '+' && !ARGV[2].nil?
			#write output with new header, but same strand
			write_to_fastq(output, "#{ARGV[2]}#{count}", entry.naseq.upcase, entry.quality_string)
		elsif strand_hash[entry.definition.split[0]] == '-' && ARGV[2].nil?
			#write output with same header, but reverse compliment
			write_to_fastq(output, entry.definition, entry.naseq.reverse_complement.upcase, entry.quality_string.reverse)
		elsif strand_hash[entry.definition.split[0]] == '-' && !ARGV[2].nil?
			#write output with new header and reverse compliment sequence
			write_to_fastq(output, "#{ARGV[2]}#{count}", entry.naseq.reverse_complement.upcase, entry.quality_string.reverse)
		end
		count += 1
	end
end
