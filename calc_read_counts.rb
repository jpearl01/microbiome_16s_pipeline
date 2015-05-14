#!/usr/bin/env ruby

filters = %w{no_filter no_human no_long ee30 ee20 ee10 ee1}
filt_files = %w{
	/home/josh/projects/nasal/ee6000/all_ee6000.fastq
	/home/josh/projects/nasal/ee6000/all_ee6k_unmapped.fastq
	/home/josh/projects/nasal/ee6000/max_len1500_ee6k.fastq
	/home/josh/projects/nasal/ee6000/4th_try/no_human_max_1500_ee30.fastq
	/home/josh/projects/nasal/ee6000/4th_try/no_human_max_1500_ee20.fastq
	/home/josh/projects/nasal/ee6000/4th_try/no_human_max_1500_ee10.fastq
	/home/josh/projects/nasal/ee6000/4th_try/no_human_max_1500_ee1.fastq
	}


samp_file = File.open('/home/josh/projects/nasal//sample_key_3.txt', 'r')

samples = []
count_hash = {}


samp_file.each do |line|

  next if $. == 1
  arr = line.split
  samples.push(arr[4] + "_" + arr[5])

end

samples.each do |s|
	count_hash[s] = Hash["no_filter", 0, "no_human", 0, "no_long", 0, "ee30", 0, "ee20", 0, "ee10", 0, "ee1", 0]
end

samp_and_ee_re = Regexp.new('barcodelabel=\d+_\d+_([^;]+);ee=([^;]+);')

file_num = 0
filt_files.each do |file|
	fh = File.open(file, 'r')
	fh.each do |line|
		next unless /^@/.match(line)
		match = samp_and_ee_re.match(line)
		next if match.nil?
		count_hash[match[1]][filters[file_num]] += 1
	end
	file_num += 1
end
samples.each do |s|
	h = count_hash[s]
	puts "#{s}\t#{h['no_filter']}\t#{h['no_human']}\t#{h['no_long']}\t#{h['ee30']}\t#{h['ee20']}\t#{h['ee10']}\t#{h['ee1']}\t"
end
