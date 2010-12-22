#!/usr/bin/ruby
#
# Copyright 2010 Thomas Eastman
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
# For a given organism, download the list of reactions and compounds on
# each KEGG pathway for that organism and write each list to a file
# with a given prefix.  KEGG used to provide these files for download
# via FTP but it appears as though they no longer do.
#

require 'bio'

if ARGV.length != 2
  puts "Usage: " + $0 + " organism prefix"
  exit(1)
end

organism = ARGV[0]
prefix = ARGV[1]

serv = Bio::KEGG::API.new

# get the list of pathways corresponding to the selected organism
pathways = serv.list_pathways(organism)
pathways.each do |path|
  path_id = path.entry_id
  puts path_id

  # get the numeric pathway ID
  path_num = path_id.match(/^path:#{organism}(\d{5})$/)[1]

  # get a list of reactions and compounds on the current pathway
  reactions = serv.get_reactions_by_pathway(path_id)
  compounds = serv.get_compounds_by_pathway(path_id)

  file_cpd = prefix + organism + path_num + ".cpd"
  file_rn = prefix + organism + path_num + ".rn"

  # write the compound ID file for the current pathway
  File.open(file_cpd, 'w') do |f|
    compounds.each do |cpd|
      puts cpd
      cpd_id = cpd.match(/^cpd:(C\d{5})$/)[1]
      f.puts cpd_id
    end
  end

  # write the reaction ID file for the current pathway
  File.open(file_rn, 'w') do |f|
    reactions.each do |rn|
      rn_id = rn.match(/^rn:(R\d{5})$/)[1]
      f.puts rn_id
    end
  end
end
