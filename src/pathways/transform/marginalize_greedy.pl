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

# This program implements the "greedy marginalization" graph structure
# transformation described in section 5.2.1 (Eastman 2010).  It produces
# a transformed undirected graphical model structure corresponding to the
# marginal distribution of the observed variables and a number of latent
# variables.  Variables are iteratively selected for marginalization such
# that the number of parameters in the resulting Gaussian Markov Random
# Field model are not increased.

use strict;
use warnings;
use Options qw(:standard :output :input :attr);
use Graph::Transform;
use Graph::Convert;
use Graph::IO;
use Utils;

Options::Process();

my $graph = Graph::IO::Load($input_file);

# compute parameter change values for every unobserved node
my %changes;
my @nodes = $graph->vertices;
for my $v (@nodes){
    next if exists $element_value{$v};
    $changes{$v} = paramchange($graph, $v);
}

# greedily marginalize out nodes until the model cannot be simplified
while(1){
    # find the node that give the best change in the number of parameters
    my $minchange = 0;
    my $minv;
    for my $v (sort keys %changes){
	my $change = $changes{$v};
	if($change <= $minchange){
	    $minchange = $change;
	    $minv = $v;
	}
    }

    if(defined($minv)){
	# determine nodes that will have new parameter change values
	my @affected = affectednodes($graph, $minv);

	Utils::Debug($debug, "marginalizing out $minv");
	Graph::Transform::Marginalize($graph, $minv);

	# update parameter change values for affected unobserved nodes
	delete $changes{$minv};
	for my $v (@affected){
	    next if exists $element_value{$v};
	    $changes{$v} = paramchange($graph, $v);
	}
    }else{
	last;
    }
}

Graph::Convert::Convert($graph, $output_format, $command, \*STDOUT);


# compute the change in the number of GMRF parameters obtained by marginalizing out a node
sub paramchange
{
    my ($graph, $v) = @_;

    my @neighbors = $graph->neighbors($v);
    my $nneighbors = @neighbors;

    my $change;

    # remove v and incident edges
    $change = -1;
    $change = $change - $nneighbors;

    # add edges to fully connect the neighborhood of v
    $change = $change + $nneighbors * ($nneighbors - 1) / 2;
    $change = $change - countedges($graph, @neighbors);

    return $change;
}

# count the number of edges that exist among a set of nodes
sub countedges
{
    my ($graph, @nodes) = @_;

    my $count = 0;
    for my $u (@nodes){
	for my $v (@nodes){
	    next if $u eq $v;
	    $count++ if $graph->has_edge($u, $v);
	}
    }
    $count /= 2;

    return $count;
}

# determine the set of nodes affected by marginalizing out a node
sub affectednodes
{
    my ($graph, $v) = @_;

    my %affected;

    my @neighbors_v = $graph->neighbors($v);
    for my $u (@neighbors_v){
	my @neighbors_u = $graph->neighbors($u);
	for my $w (@neighbors_u){
	    $affected{$w} = 1;
	}
	$affected{$u} = 1;
    }

    # do not include the marginalized node itself
    delete $affected{$v};

    return keys %affected;
}
