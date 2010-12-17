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
# Generate one or more undirected graph structures from a set of pathways.
# Each generated structure will contain a single node for every unqiue
# metabolite that appears on a pathway from which it is generated.  Within
# a structure, two metabolite are joined by an edge if and only if they
# both appear in a common reaction equaiton (on either side).
#
# The graph type option (given by -t or --type) controlls two aspects of
# graph generation.  This option requires an argument (type specification)
# indicating the source of reaction equations and pathway compounds.
#
# Full biochemical reaction equations are used if the type specification
# contains the character 'E' otherwise equations are restricted to what
# is specified by the graphical representation of the pathway (optionally
# indicated by the character 'e').  KEGG does not represent complete
# equations in its pathway diagrams thus the distinction is meaningful.
# This may not apply to other pathway databases however.
#
# The character 'C' in the type specification indicates that the generated
# graph should include any compound that occurs in the reaction equations
# (whatever the source).  The compounds included with each equation are
# limmited by default (optionally indicated by the character 'c') to those
# appearing on the pathway where the equation appears.  Note that in this
# case, different pathways may include the same reaction with different sets
# of compounds.
#
# To generate graph structures consistent with the pathway diagrams given
# by KEGG or another database, the graph type specification 'ec' should be
# used.
#
# This program will completely ignore metabolites designated as "currency
# metabolites."  These are metabolites that are assumed to be available in
# sufficiently high concentration that they do not influence the reactions
# in which they participate.  Currency metabolites are take from the set of
# files given by the -X or --ignore-file option (one file per instance of
# the option).
#

use strict;
use warnings;
use Switch;
use Options qw(:standard :output :input :attr $network_type);
use Graph::Convert;
use Utils;
use BioCyc;
use Kegg;

Options::Process();

my $db = $db_type->new($db_prefix, $organism, $debug);

my @pathways = Utils::LoadPathwayList($input_file);

if($output_separate){
    # generate graph for each of the selected pathways separately
    for my $path_id (@pathways) {
	my $graph = generate($db, $network_type, \%element_ignore, $path_id);
	my $file = $output_prefix . $path_id . "." . $output_format;
	open GRAPH, ">$file" or Utils::Error("$0: $file: $!");
	Graph::Convert::ConvertDefault($graph, $command, \*GRAPH);
	close GRAPH;
    }
}else{
    my $graph = generate($db, $network_type, \%element_ignore, @pathways);
    Graph::Convert::ConvertDefault($graph, $command, \*STDOUT);
}

# generate a pathway graph for a set of pathways
sub generate
{
    my ($db, $type, $currency, @pathways) = @_;

    # determine graph encoding
    my $use_full_equations = 0;
    my $use_all_compounds = 0;
    my @code = split //, $type;
    for my $flag (@code){
	switch($flag){
	    case 'E' { $use_full_equations = 1; }
	    case 'e' { $use_full_equations = 0; }
	    case 'C' { $use_all_compounds = 1; }
	    case 'c' { $use_all_compounds = 0; }

	    else     { Utils::Error("unrecognized graph encoding flag: '$flag' (type = '$type')"); }
	}
    }

    my $graph = Graph::Undirected->new;

    for my $path_id (@pathways){

	Utils::Debug($debug, "generate: adding pathway '$path_id'");

	my $path_compounds = $db->pathway_compounds($path_id);
	my $path_reactions = $db->pathway_reactions($path_id);

	for my $cpd_id (keys %$path_compounds){
	    Utils::Debug($debug, "generate: pathway '$path_id' has compound '$cpd_id'");
	}
	for my $rn_id (keys %$path_reactions){
	    Utils::Debug($debug, "generate: pathway '$path_id' has reaction '$rn_id'");
	}

	for my $rn_id (keys %$path_reactions){

	    Utils::Debug($debug, "generate: adding reaction '$rn_id' from pathway '$path_id'");

	    my $rn_equation  = $use_full_equations ? $db->reaction_equation($rn_id) : $db->pathway_equation($path_id,$rn_id);

	    my @left = keys %{$rn_equation->{left}};
	    my @right = keys %{$rn_equation->{right}};

	    # join all pairs of metabolites in a reaction
	    for my $cpd_id1 (@left, @right){
		for my $cpd_id2 (@left, @right){
		    # do not join a metabolite to itself
		    next if $cpd_id1 eq $cpd_id2;

		    # ignore "currency" metabolites
		    next if defined $currency->{$cpd_id1};
		    next if defined $currency->{$cpd_id2};

		    unless($use_all_compounds){
			next unless defined $path_compounds->{$cpd_id1};
			next unless defined $path_compounds->{$cpd_id2};
		    }

		    Utils::Debug($debug, "adding $rn_id: $cpd_id1 $cpd_id2");

		    # connect each substrate, product pair
		    $graph->add_edge($cpd_id1, $cpd_id2);

		    $graph->set_vertex_attribute($cpd_id1, "type", "compound");
		    $graph->set_vertex_attribute($cpd_id2, "type", "compound");
		}
	    }
	}
    }

    return $graph;
}
