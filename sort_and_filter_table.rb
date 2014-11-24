#!/usr/bin/env ruby

#ruby sort_and_filter_table.rb sample_utax.results sample.table

otu_names = {}

File.open(ARGV[0]).each do |rec|
	rec_arr = rec.split
	name_arr = rec_arr[1].split(',')
	otu_names[rec_arr[0]] = rec_arr[0] + "_" + name_arr[-2] + "_" + name_arr[-1]
end

#otu_names.each do |key,val|
#	puts "key #{key} goes to value #{val}"
#end

otu_table = {}

File.open(ARGV[1]).each do |rec|
	next unless $. != 1
	tbl_arr = rec.split
	tbl_arr[0] = otu_names[tbl_arr[0]] if !otu_names[tbl_arr[0]].nil?
	otu_table[tbl_arr[0]] = tbl_arr[1].to_i
	#puts "key #{tbl_arr[0]} goes to value #{tbl_arr[1]}"
end

##{ARGV[2]}/
out_file = File.open("data_to_plot.dat",'w')
#out_file.write(otu_table.shift.join(" ") + "\n")

otu_table.sort_by{|k,v| v}.each do |k,v|
	#puts "#{k} #{v}\n" #unless v < 3
	out_file.write("#{k} #{v}\n") unless v < 3
end