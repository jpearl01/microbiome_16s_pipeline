#!/usr/bin/env ruby

require 'bio'

fh = Bio::FlatFile.auto(ARGV[0])
fo = File.open(ARGV[1], 'w')

fh.each do |entry|
  fo.puts entry.quality_scores.inject{ |sum, el| sum + el }.to_f / entry.quality_scores.size
end
