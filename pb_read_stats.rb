#!/usr/bin/env ruby

#Usage: ruby pool_samples.rb expected_error truncation_length

require 'bio'

abort("Can't open the sample pool file!") unless File.exists?("/home/josh/projects/nasal/sample_key_3.txt")

pb_projects={}

class Barcode_16s_record

        attr_accessor :pool, :barcode_num, :site_id, :patient, :sample

end


File.foreach("/home/josh/projects/nasal/sample_key_3.txt") do |entry|
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
log = File.open('read_statistics', 'w')

pb_projects.each do |id, samps|

  curr_files = "/data/pacbio/smrtanalysis_userdata/jobs/016/0" + id + "/data/*.ccs.h5" if /^16/.match(id)
  curr_files = "/data/pacbio/smrtanalysis_userdata/jobs/017/0" + id + "/data/*.ccs.h5" if /^17/.match(id)
  `python ~/bin/ccs_passes.py #{curr_files} >> passes`

end
