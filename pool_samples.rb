#!/usr/bin/env ruby

#Usage: ruby pool_samples.rb expected_error truncation_length

abort("Can't open the sample pool file!") unless File.exists?("sample_key_2.txt")

#Lets store stdout to a log file
$stdout.reopen('16s_before_after.log', 'w')

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

pb_projects.each do |id, samps|

	curr_file = "/data/pacbio/smrtanalysis_userdata/jobs/016/0" + id + "/data/barcoded-fastqs.tgz"
	log.puts("The current file is: " + curr_file)
	abort("The file #{curr_file} does not exist!") if !File.exists?(curr_file)
	`tar xvf #{curr_file}`
	samps.each do |rec|

		log.puts("Pool: #{rec.pool} Barcode: #{rec.barcode_num}")
		base_name = "#{rec.pool}_#{rec.barcode_num}_#{rec.site_id}_#{rec.patient}"
		bc = "barcodelabel=#{base_name}\\;#{rec.site_id}_#{rec.patient}_"
		fq = ''

		if rec.barcode_num.to_i == 1
			fq = '0001_Forward--0002_Forward.fastq'
		elsif rec.barcode_num.to_i == 2
			fq = "0003_Forward--0004_Forward.fastq"
		elsif rec.barcode_num.to_i == 3
			fq = "0005_Forward--0006_Forward.fastq"
		elsif rec.barcode_num.to_i == 4
			fq = "0007_Forward--0008_Forward.fastq"
		end

		if File.exists?(fq)
			$stderr.puts(fq)
			`fix_rev_comp_16s.rb #{fq} corrected.fq`
			log.puts("usearch -fastq_filter corrected.fq  -fastqout #{base_name}.fastq  -relabel #{bc} -fastq_maxee #{ARGV[0]}")
			`usearch -fastq_filter corrected.fq -fastqout #{base_name}.fastq -fastaout #{base_name}.fasta -relabel #{bc} -fastq_maxee #{ARGV[0]} `
			File.delete(fq)
		else
			log.puts("No file for sample #{id} barcode #{rec.barcode_num}")
		end
	end
end

File.delete('corrected.fq')

`mkdir -p all_seqs` unless Dir.exists?('all_seqs')
`cat *.fasta > all_seqs/all_ee#{ARGV[0]}.fasta`
`cat *.fastq > all_seqs/all_ee#{ARGV[0]}.fastq`