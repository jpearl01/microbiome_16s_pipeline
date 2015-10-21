#!/usr/bin/env ruby

#Usage: ruby pool_samples.rb expected_error truncation_length

require 'bio'


abort("Can't open the sample pool file!") unless File.exists?("sample_key_3.txt")
abort("Need to enter the expected error: usage -> pool_samples.rb expected_error") if ARGV[0].nil?

ee = ARGV[0]


#Lets store stdout to a log file
$stdout.reopen('16s_before_after.log', 'w')

class Barcode_16s_record

	attr_accessor :pool, :barcode_num, :site_id, :patient, :sample

end

def write_to_fastq (fh, header, sequence, quality)
	fh.write('@' + header + "\n")
	fh.write(sequence)
	fh.write("\n+\n")
	fh.write(quality + "\n")
end

pb_projects = {}


File.foreach("sample_key_3.txt") do |entry|
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

	curr_file = "/data/pacbio/smrtanalysis_userdata/jobs/016/0" + id + "/data/barcoded-fastqs.tgz" if /^16/.match(id)
	curr_file = "/data/pacbio/smrtanalysis_userdata/jobs/017/0" + id + "/data/barcoded-fastqs.tgz" if /^17/.match(id)
	log.puts("The current file is: " + curr_file)
	abort("The file #{curr_file} does not exist!") if !File.exists?(curr_file)
	`tar xvf #{curr_file}`
	samps.each do |rec|

		log.puts("Pool: #{rec.pool} Barcode: #{rec.barcode_num}")
		base_name = "#{rec.pool}_#{rec.barcode_num}_#{rec.site_id}_#{rec.patient}"
		bc = "barcodelabel=#{base_name}\;"
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
			$stderr.puts(base_name)
=begin
			before = `grep -c '>' #{fq}`
			`fix_rev_comp_16s.rb #{fq} corrected.fq`
			after = `grep -d '>' corrected.fq`
			puts "#{base_name}\t#{before.strip}\t#{after.strip}"


			log.puts("usearch -fastq_filter corrected.fq  -fastqout #{base_name}.fastq  -relabel #{bc} -fastq_maxee #{ee}")
			`usearch -fastq_filter corrected.fq -fastqout #{base_name}.fastq -fastaout #{base_name}.fasta -relabel #{bc} -fastq_maxee #{ee} `
=end
			
			#Add in the barcode to the fastq header
			corrected = File.open('corrected.fq', 'w')
			fh = Bio::FlatFile.auto(fq)
			fh.each do |entry|
				new_header = entry.definition.split[0]
				new_header = new_header + ";" + bc
				write_to_fastq(corrected, "#{new_header}", entry.naseq.upcase, entry.quality_string)
			end
			corrected.puts ""
			corrected.close
			#Remember to include the '-threads 1' to account for the non-unique id relabelling bug
      `usearch -fastq_filter corrected.fq -fastqout #{base_name}.fastq -fastaout #{base_name}.fasta -fastq_maxee #{ee} -eeout `
                  

			File.delete(fq)
		else
			log.puts("No file for sample #{id} barcode #{rec.barcode_num}")
		end
	end
end

File.delete('corrected.fq')

`mkdir -p ee#{ee}` unless Dir.exists?("ee#{ee}")
`cat *.fasta > ee#{ee}/all_ee#{ee}.fasta`
`cat *.fastq > ee#{ee}/all_ee#{ee}.fastq`
