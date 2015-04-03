#!/usr/bin/env ruby

#This program is to collapse duplicate runs (columns) and then to sum to the genus level (rows) 

require 'matrix'



fh = File.open('table')
ids = []
orig_patient_samp = {}
final_patient_samp = {}

fh.each do |line|

  if $. == 1
    ids = line.split
    line.split.each do |id|
      orig_patient_samp[id] = []
    end
  else
    i = 0
    line.split.each do |val|
      orig_patient_samp[ids[i]].push(val)
      i+=1
    end
  end

end
fh.close

#Now lets deal with collapsing down the rows which have the same genus
fh = File.open('utax')
row_to_collapse = {}
fh.each do |line|
  arr = line.split
  otu = arr[0]
  #Break up the line, get the otu, and then get the 6th position which is the genus, split that to get rid of the confidence value
  genus = arr[1].split(',')[5].split('(')[0]
#  STDERR.puts otu + " " +genus
  if row_to_collapse[genus].nil?
    row_to_collapse[genus] = []
  end
  row_to_collapse[genus].push(otu)

end

final_patient_samp['OTUId'] = orig_patient_samp['OTUId']
#puts orig_patient_samp.inspect
ids.each do |id|
  id_a = id.split('_')
  next unless id_a.size > 1
  #get the new id for this patient (i.e. drop the sample pool and other var and just have patient and site)
  m = id_a[2] + '_' + id_a[3]
  matches = []
  #loop through all the original ids and snag the full id name, then match duplicates
  orig_patient_samp.keys.each do |k|
    if m.match(k) 
      matches.push(k)
    end
  end
  #If there was a match, we need to sum those vectors, so must convert to integer first, and then 'splat' (*) into a vector array; sum the two
  if matches.size == 2
    s = Vector[*orig_patient_samp[matches[0]].map(&:to_i)] + Vector[*orig_patient_samp[matches[0]].map(&:to_i)]
    final_patient_samp[m]=s.to_a#.map(&:to_s)
  else
    #otherwise, just make a single new column of all the values converted to ints
    final_patient_samp[m] = orig_patient_samp[id]
  end
end

otus_by_row = {}
mat = Matrix.columns(final_patient_samp.values[1..final_patient_samp.length])
vec = mat.row_vectors

puts final_patient_samp.keys.join(' ')
row_to_collapse.keys.each do |genus|

  total_vector = nil
  row_to_collapse[genus].each do |o|
    if total_vector.nil?
      total_vector = vec[final_patient_samp['OTUId'].index(o)-1].map(&:to_i)
      puts vec[final_patient_samp['OTUId'].index(o)-1]
    else
      total_vector = total_vector + vec[final_patient_samp['OTUId'].index(o)-1].map(&:to_i)
    end
    
  end
  abort
  puts genus + " " + total_vector.to_a.join(" ")
end
#puts Matrix.columns(final_patient_samp.values)
abort

puts final_patient_samp.keys.join(' ')
(0..final_patient_samp['OTUId'].size).each do |i|
  l = ""
  
  final_patient_samp.keys.each do |k|
    val = final_patient_samp[k][i]
    #puts k.to_s + " " + i.to_s
    l = l + "#{val}  "

  end
  puts l
end
