#!/usr/bin/env ruby

passes = File.open('/home/josh/projects/nasal/stats/passes', 'r')
reads = File.open('/home/josh/projects/nasal/ee6000/headers', 'r')

pass_hash = {}
reads_hash = {}

passes.each do |line|
  arr = line.split
  pass_hash[arr[0]] = arr[1] 
end

reads.each do |line|
  
  arr = line.split(';')
  p = pass_hash[arr[0].gsub(/@/, '')]
  puts "#{arr[0]} #{p} #{arr[2].gsub(/ee=/, '')}"

end
