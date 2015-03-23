#!/usr/bin/env ruby
require 'bio'

#Usage: ruby generate_stats.rb 

abort("Can't open the sample pool file! (should be 'sample_key_2.txt')") unless File.exists?("sample_key_2.txt")


class Barcode_16s_record

	attr_accessor :pool, :barcode_num, :site_id, :patient, :sample

end

pb_projects = {}


File.foreach("sample_key_2.txt") do |entry|
	next if $. == 1
	arr = entry.split
	pb_projects[arr.last] = [] unless pb_projects.has_key?(arr.last)
	rec = Barcode_16s_record.new
	rec.pool = arr[1]
	rec.barcode_num = arr[2]
	rec.site_id = arr[4]
	rec.patient = arr[5]
	rec.sample = arr[6]
	pb_projects[arr.last].push(rec)
end

puts "Sanity check, number of projects are: " + pb_projects.count.to_s

#Lets make a log file for some stuff
log = File.open('log.txt', 'w')
stats = File.open('stats.txt', 'w')

pb_projects.each do |id, samps|

	curr_file = "/data/pacbio/smrtanalysis_userdata/jobs/016/0" + id + "/data/barcoded-fastqs.tgz"
	if File.exists?(curr_file)
		`tar xvf #{curr_file}`
		samps.each do |rec|
			
			base_name = "#{rec.pool}_#{rec.barcode_num}_#{rec.site_id}_#{rec.patient}"
			bc = "barcodelabel=#{base_name}\\;#{rec.site_id}_#{rec.patient}_"
			before = 0
			after = 0
			if rec.barcode_num.to_i == 1
				if File.exists?("0001_Forward--0002_Forward.fastq")
					before = Bio::FlatFile.open(Bio::Fastq, "0001_Forward--0002_Forward.fastq").count
					`fix_rev_comp_16s.rb 0001_Forward--0002_Forward.fastq #{base_name}.fq #{bc}`
					after = Bio::FlatFile.open(Bio::Fastq, "#{base_name}.fq").count if File.exists?("#{base_name}.fq")
					File.delete("0001_Forward--0002_Forward.fastq")
				else
					log.puts("No file for sample #{id} barcode #{rec.barcode_num}")
				end
			elsif rec.barcode_num.to_i == 2
				if File.exists?("0003_Forward--0004_Forward.fastq")
					before = Bio::FlatFile.open(Bio::Fastq, "0003_Forward--0004_Forward.fastq").count
					`fix_rev_comp_16s.rb 0003_Forward--0004_Forward.fastq #{base_name}.fq #{bc}`
					File.delete("0003_Forward--0004_Forward.fastq")
					after = Bio::FlatFile.open(Bio::Fastq, "#{base_name}.fq").count if File.exists?("#{base_name}.fq")
				else
					log.puts("No file for sample #{id} barcode #{rec.barcode_num}")
				end
			elsif rec.barcode_num.to_i == 3
				if File.exists?("0005_Forward--0006_Forward.fastq")
					before = Bio::FlatFile.open(Bio::Fastq, "0005_Forward--0006_Forward.fastq").count
					`fix_rev_comp_16s.rb 0005_Forward--0006_Forward.fastq #{base_name}.fq #{bc}`
					File.delete("0005_Forward--0006_Forward.fastq")
					after = Bio::FlatFile.open(Bio::Fastq, "#{base_name}.fq").count if File.exists?("#{base_name}.fq")
				else
					log.puts("No file for sample #{id} barcode #{rec.barcode_num}")
				end
			elsif rec.barcode_num.to_i == 4
				if File.exists?("0007_Forward--0008_Forward.fastq")
					before = Bio::FlatFile.open(Bio::Fastq, "0007_Forward--0008_Forward.fastq").count
					`fix_rev_comp_16s.rb 0007_Forward--0008_Forward.fastq #{base_name}.fq #{bc}`
					File.delete("0007_Forward--0008_Forward.fastq")
					after = Bio::FlatFile.open(Bio::Fastq, "#{base_name}.fq").count if File.exists?("#{base_name}.fq")
				else
					log.puts("No file for sample #{id} barcode #{rec.barcode_num}")
				end
			end
			stats.puts("#{base_name}\t#{before}\t#{after}")

					
		end

	end
end