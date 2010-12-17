#!/usr/bin/perl
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
# This program implements the "full merge" graph structure transformation
# described in section 5.2.2 (Eastman 2010).  It produces a transformed
# undirected graphical model structure by iteratively merging every pair
# of adjacent latent variable nodes into a single new latent variable node
# until no such pair exists.
#

use strict;
use warnings;
use Options qw(:standard :output :input :attr);
use Graph::Transform;
use Graph::Convert;
use Graph::IO;
use Utils;

Options::Process();

my $graph = Graph::IO::Load($input_file);

# merge every pair of adjacent unobserved nodes
while(1){
    # flag indicating that there might be more nodes to merge
    my $more = 0;

    my @nodes = $graph->vertices;
    for my $u (@nodes){
	for my $v (@nodes){
	    next unless $graph->has_edge($u, $v);
	    next if exists $element_value{$u};
	    next if exists $element_value{$v};
	    Utils::Debug($debug, "merging $u and $v");
	    Graph::Transform::Merge($graph, $u, $v);
	    $more = 1;
	}
    }

    last unless $more;
}

Graph::Convert::Convert($graph, $output_format, $command, \*STDOUT);
