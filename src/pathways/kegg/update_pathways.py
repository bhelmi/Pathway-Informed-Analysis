#!/usr/bin/python
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

import re
import sys
import SOAPpy

wsdl = 'http://soap.genome.jp/KEGG.wsdl'

if len(sys.argv) != 3:
    print "Usage: ", sys.argv[0], "organism", "prefix"
    sys.exit(1)

organism = sys.argv[1]
prefix = sys.argv[2]

serv = SOAPpy.WSDL.Proxy(wsdl)

# get the list of pathways corresponding to the selected organism
pathways = serv.list_pathways(organism)
for path in pathways:
    path_id = path.entry_id
    print path_id
    
    # get the numeric pathway ID
    path_num = re.match("path:" + organism + r"(\d{5})", path_id).group(1)

    # get a list of reactions and compounds on the current pathway
    reactions = serv.get_reactions_by_pathway(path_id)
    compounds = serv.get_compounds_by_pathway(path_id)
    
    file_cpd = prefix + organism + path_num + ".cpd"
    file_rn = prefix + organism + path_num + ".rn"
    
    # write the compound ID file for the current pathway
    f = open(file_cpd, 'w')
    for cpd in compounds:
        cpd_id = re.match(r"cpd:(C\d{5})", cpd).group(1)
        print >>f, cpd_id
    f.close()

    # write the reaction ID file for the current pathway
    f = open(file_rn, 'w')
    for rn in reactions:
        rn_id = re.match(r"rn:(R\d{5})", rn).group(1)
        print >>f, rn_id
    f.close()
