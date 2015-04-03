#!/usr/bin/env ruby

#This program gets all the raw counts of reads from the barcode_report.json file in the jobs directory (under results)
#Usage: ruby pool_samples.rb 

require 'json'
require 'yaml'

abort("Can't open the sample pool file!") unless File.exists?("sample_key_2.txt")


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
log = File.open('log_barcodes.txt', 'w')

pb_projects.each do |id, samps|

	curr_file = "/data/pacbio/smrtanalysis_userdata/jobs/016/0" + id + "/results/barcode_report.json"
	log.puts("The current file is: " + curr_file)

	puts curr_file
	abort("Yo, the file doesn't exist") if !File.exists?(curr_file)
	if File.exists?(curr_file)
		curr_file = File.read(curr_file)
		barcodes = JSON.parse(curr_file)
		puts barcodes.to_yaml

		samps.each do |rec|

			if rec.barcode_num.to_i == 1
				puts "#{rec.site_id}\t#{rec.patient}"
			elsif rec.barcode_num.to_i == 2
			elsif rec.barcode_num.to_i == 3
			elsif rec.barcode_num.to_i == 4
			end
		end
	end
end