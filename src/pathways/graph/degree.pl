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
# Print a list of the nodes in a graph structure sorted by degree.
#

use strict;
use warnings;
use Options qw(:standard :input :attr);
use Graph::IO;

Options::Process();

my $graph = Graph::IO::Load($input_file);
my %degree = map { $_ => degree($graph, $_) } $graph->vertices;
my @nodes = sort { $degree{$b} <=> $degree{$a} } keys %degree;

for my $v (@nodes){
    my $name = $element_name{$v};
    print "$v\t$degree{$v}";
    print " # $name" if defined($name);
    print "\n";
}

sub degree
{
    my ($graph, $v) = @_;

    if($graph->is_directed()){
	# directed graphs define degree(v) = in_degree(v) - out_degree(v)
	return $graph->in_degree($v) + $graph->out_degree($v);
    }else{
	return $graph->degree($v);
    }
}
