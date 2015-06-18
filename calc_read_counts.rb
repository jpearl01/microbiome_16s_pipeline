#!/usr/bin/env ruby

filters = %w{no_filter no_human trimmed no_long ee30 ee10 ee1 ee.5 ee.01}
filt_files = %w{
	/home/josh/projects/nasal/ee6000/all_ee6000.fastq
	/home/josh/projects/nasal/ee6000/all_ee6k_unmapped.fastq
	/home/josh/projects/nasal/ee6000/ee6k_unmapped_trimmed.fastq
	/home/josh/projects/nasal/ee6000/max_len1500_trimmed_unmapped_ee6k.fastq
	/home/josh/projects/nasal/ee6000/4th_try/ee30/may_2015_ee30_tunc1500.fasta
	/home/josh/projects/nasal/ee6000/4th_try/ee10v2/may_2015_ee10_tunc1500.fasta
	/home/josh/projects/nasal/ee6000/4th_try/ee1/may_2015_ee1_tunc1500.fasta
	/home/josh/projects/nasal/ee6000/4th_try/ee.5/may_2015_ee.5_tunc1500.fasta
        /home/josh/projects/nasal/ee6000/4th_try/ee.01/may_2015_ee0.01_tunc1500.fasta
	}


samp_file = File.open('/home/josh/projects/nasal/sample_key_3.txt', 'r')

samples = []
count_hash = {}


samp_file.each do |line|

  next if $. == 1
  arr = line.split
  samples.push(arr[4] + "_" + arr[5]) unless samples.include?("#{arr[4]}_#{arr[5]}")

end

samples.each do |s|
	count_hash[s] = Hash["no_filter", 0, "no_human", 0, "trimmed", 0, "no_long", 0, "ee30", 0, "ee10", 0, "ee1", 0, "ee.5", 0, "ee.01", 0]
end

samp_and_ee_re = Regexp.new('barcodelabel=\d+_\d+_([^;]+);[ee=([^;]+);]*')

file_num = 0
filt_files.each do |file|
	fh = File.open(file, 'r')
	fh.each do |line|
		next unless /^@m|^>/.match(line)
		match = samp_and_ee_re.match(line)
		next if match.nil?
		count_hash[match[1]][filters[file_num]] += 1
	end
	file_num += 1
end

#write the header
puts "sample\t" + filters.join("\t")

samples.each do |s|
	h = count_hash[s]
  puts "#{s}\t#{h['no_filter']}\t#{h['no_human']}\t#{h['trimmed']}\t#{h['no_long']}\t#{h['ee30']}\t#{h['ee10']}\t#{h['ee1']}\t#{h['ee.5']}\t#{h['ee.01']}\t"
end
