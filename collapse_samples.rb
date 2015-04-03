#!/usr/bin/env ruby

#The goal of this program is to collapse nasal samples which have more than one pacbio cell into single columsn in the 'table' file

class Sample

	attr_accessor :patient,:site,:otus

end