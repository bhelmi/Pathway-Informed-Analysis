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

# This program implements the "full marginalization" graph structure
# transformation described in section 5.2.1 (Eastman 2010).  It produces
# a transformed undirected graphical model structure corresponding to the
# marginal distribution of the observed variables.

use strict;
use warnings;
use Options qw(:standard :output :input :attr);
use Graph::Transform;
use Graph::Convert;
use Graph::IO;
use Utils;

Options::Process();

my $graph = Graph::IO::Load($input_file);

# marginalize out all unobserved nodes
my @nodes = $graph->vertices;
for my $v (@nodes){
    next if exists $element_value{$v};
    Utils::Debug($debug, "marginalizing out $v");
    Graph::Transform::Marginalize($graph, $v);
}

Graph::Convert::Convert($graph, $output_format, $command, \*STDOUT);
