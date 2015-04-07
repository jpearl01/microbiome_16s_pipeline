#!/usr/bin/env ruby

#This program gets all the raw counts of reads from the barcode_report.json file in the jobs directory (under results)
#Usage: ruby pool_samples.rb 

require 'json'
require 'yaml'

abort("Can't open the sample (key) pool file!") unless File.exists?("sample_key_2.txt")


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
	m_log = "/data/pacbio/smrtanalysis_userdata/jobs/016/0" + id + "/log/master.log"
	abort("Can't open the json file: #{curr_file}") unless File.exists?(curr_file)	
	abort("Can't open the master log file: #{m_log}") unless File.exists?(m_log)

	log.puts("The current file is: " + curr_file)


	barcodes = JSON.parse(File.read(curr_file))
	samps.each do |rec|

		if rec.barcode_num.to_i == 1
			barcode_name = '0001_Forward--0002_Forward'
			if barcodes["tables"][0]['columns'][0]['values'].index(barcode_name).nil?
				reads = 0
			else
				ind = barcodes["tables"][0]['columns'][0]['values'].index(barcode_name)
				reads = barcodes["tables"][0]['columns'][1]['values'][ind]
			end
			puts "#{id}\t#{rec.site_id}\t#{rec.patient}\t#{barcode_name}\t#{reads}"
		elsif rec.barcode_num.to_i == 2
			barcode_name = '0003_Forward--0004_Forward'
			if barcodes["tables"][0]['columns'][0]['values'].index(barcode_name).nil?
				reads = 0
			else
				ind = barcodes["tables"][0]['columns'][0]['values'].index(barcode_name)
				reads = barcodes["tables"][0]['columns'][1]['values'][ind]
			end
			puts "#{id}\t#{rec.site_id}\t#{rec.patient}\t#{barcode_name}\t#{reads}"
		elsif rec.barcode_num.to_i == 3
			barcode_name = '0005_Forward--0006_Forward'

			if barcodes["tables"][0]['columns'][0]['values'].index(barcode_name).nil?
				reads = 0
			else
				ind = barcodes["tables"][0]['columns'][0]['values'].index(barcode_name)
				reads = barcodes["tables"][0]['columns'][1]['values'][ind]
			end
			puts "#{id}\t#{rec.site_id}\t#{rec.patient}\t#{barcode_name}\t#{reads}"
		elsif rec.barcode_num.to_i == 4
			barcode_name = '0007_Forward--0008_Forward'
			if barcodes["tables"][0]['columns'][0]['values'].index(barcode_name).nil?
				reads = 0
			else
				ind = barcodes["tables"][0]['columns'][0]['values'].index(barcode_name)
				reads = barcodes["tables"][0]['columns'][1]['values'][ind]
			end
			puts "#{id}\t#{rec.site_id}\t#{rec.patient}\t#{barcode_name}\t#{reads}"
		end
	end
end
