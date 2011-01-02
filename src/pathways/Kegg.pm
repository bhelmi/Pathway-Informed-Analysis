#
# Copyright 2011 Thomas Eastman
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
# Load portions of the Kyoto Encyclopedia of Genes and Genomes (KEGG)
# database and make them available to other programs.  The provided data
# is parsed from the flat text files provided via the KEGG FTP server as
# opposed to using the KEGG web services.  The required files must be
# downloaded and arranged according to the same directory layout on the
# FTP server.  This package provides information related to metabolic
# pathways and the reactions and compounds that occur on them.  Each
# instance corresponds to the pathways of a single organism.  Other
# data available in KEGG such as genes, signaling pathways, etc. is not
# included here.
#

package Kegg;

use strict;
use warnings;
use Utils;

# relative file names (or file name patterns) for KEGG database files
my $compound_file = "/ligand/compound/compound";
my $reaction_file = "/ligand/reaction/reaction";
my $glycan_file = "/ligand/glycan/glycan";
my $enzyme_file = "/ligand/enzyme/enzyme";
my $rpair_file = "/ligand/rpair/rpair";
my $pathway_name_file = "/pathway/map_title.tab";
my $pathway_data_file = "/pathway/organisms/ORG/ORGID.EXT";
my $pathway_map_data_file = "/pathway/map/mapID.EXT";
my $pathway_mapping_file = "/ligand/reaction/reaction_mapformula.lst";
my $orthology_file = "/genes/ko";

# KEGG database names
my $db_compound = "compound";
my $db_glycan = "glycan";
my $db_orthology = "orthology";
my $db_reaction = "reaction";
my $db_enzyme = "enzyme";
my $db_pathway = "pathway";
my $db_rpair = "rpair";

# KEGG database fields
my $field_name = "NAME";
my $field_type = "TYPE";
my $field_compound = "COMPOUND";
my $field_reaction = "REACTION";
my $field_pathway = "PATHWAY";
my $field_rpair = "RPAIR";
my $field_orthology  = "ORTHOLOGY";
my $field_enzyme = "ENZYME";
my $field_definition = "DEFINITION";
my $field_equation = "EQUATION";

# file name extensions used by KEGG pathway data files
my %pathway_extension = (
  "compound" => "cpd",
  "reaction" => "rn",
  "orthology" => "orth",
);

# create a new KEGG database using the data files from a specific location
# and the pathways for a particular organism
sub new
{
    my ($class, $prefix, $organism, $debug) = @_;

    my $self = {
	prefix => $prefix,
	organism => $organism,
	debug => defined($debug) && $debug,
    };
    bless $self, $class;

    # initialize the database
    $self->_load_compound();
    $self->_load_reaction();
    $self->_load_glycan();

    return $self;
}

# return IDs for all compounds
sub compounds
{
    my $self = shift;

    return keys %{$self->{compound}};
}

# return the name of a compound
sub compound_name
{
    my ($self, $id) = @_;

    return $self->{compound}{$id}{name};
}

# return the synonyms of a compound
sub compound_synonyms
{
    my ($self, $id) = @_;

    return @{$self->{compound}{$id}{synonym}};
}

# return IDs for all glycans
sub glycans
{
    my $self = shift;

    return keys %{$self->{glycan}};
}

# return IDs for all reactions
sub reactions
{
    my $self = shift;

    return keys %{$self->{reaction}};
}

# return the equation of a reaction
sub reaction_equation
{
    my ($self, $rn_id) = @_;

    return $self->_get_field($db_reaction, $rn_id, "equation");
}

# return the enzyme(s) that can catalyze a reaction
sub reaction_enzymes
{
    my ($self, $rn_id) = @_;

    return $self->_get_field($db_reaction, $rn_id, "enzyme");
}

# return the orthologs corresponding to a reaction
sub reaction_orthologs
{
    my ($self, $rn_id) = @_;

    return $self->_get_field($db_reaction, $rn_id, "orthology");
}

# return the reaction pairs involved in a reaction
sub reaction_rpairs
{
    my ($self, $rn_id) = @_;

    return $self->_get_field($db_reaction, $rn_id, "rpair");
}

# return IDs for all KEGG orthology entries
sub orthologs
{
    my $self = shift;

    $self->_load_orthology() unless exists $self->{$db_orthology};

    return keys %{$self->{$db_orthology}};
}

# return IDs for all KEGG enzyme entries
sub enzymes
{
    my $self = shift;

    $self->_load_enzyme() unless exists $self->{$db_enzyme};

    return keys %{$self->{$db_enzyme}};
}

# return IDs for all KEGG rpair entries
sub rpairs
{
    my $self = shift;

    $self->_load_rpair() unless exists $self->{$db_rpair};

    return keys %{$self->{$db_rpair}};
}

# return possible types of a reaction pair
sub rpair_types
{
    my ($self, $rp_id) = @_;

    return $self->_get_field($db_rpair, $rp_id, "type");
}

# return the two compounds of a reaction pair
sub rpair_compounds
{
    my ($self, $rp_id) = @_;

    return $self->_get_field($db_rpair, $rp_id, "compound");
}

# return IDs for all KEGG pathways
sub pathways
{
    my $self = shift;

    $self->_load_pathway_names() unless exists $self->{$db_pathway};

    return keys %{$self->{$db_pathway}};
}

# return IDs of all compounds in a specific pathway
sub pathway_compounds
{
    my ($self, $path_id) = @_;

    my $compound = $self->_get_field($db_pathway, $path_id, "compound");

    return $compound;
}

# return IDs of all reactions in a specific pathway
sub pathway_reactions
{
    my ($self, $path_id) = @_;

    my $reaction = $self->_get_field($db_pathway, $path_id, "reaction");

    return $reaction;
}

# return the set of orthologs in a specific pathway
sub pathway_orthologs
{
    my ($self, $path_id) = @_;

    my $orthology = $self->_get_field($db_pathway, $path_id, "orthology");

    return $orthology;
}

# return the subset of orthologs in a specific pathway that look like EC numbers
sub pathway_enzymes
{
    my ($self, $path_id) = @_;

    my $orthology = $self->_get_field($db_pathway, $path_id, "orthology");
    my $enzymes = {};
    for my $orth (keys %$orthology){
	if($orth =~ /^E((\d+|-)\.(\d+|-)\.(\d+|-)\.(\d+|-))/){
	    $enzymes->{$1} = 1;
	}
    }

    return $enzymes;
}

# return the equation for a reaction as it appears on a specific pathway
sub pathway_equation
{
    my ($self, $path_id, $rn_id) = @_;

    my $equation = $self->_get_field($db_pathway, $path_id, "equation");

    return $equation->{$rn_id};
}

# return the directon of a reaction as it appears on a specific pathway
sub pathway_direction
{
    my ($self, $path_id, $rn_id) = @_;

    my $equations = $self->_get_field($db_pathway, $path_id, "equation");

    return $equations->{$rn_id}{direction};
}

# return the name (or first synonym) of a KEGG database entry
sub name
{
    my ($self, $id) = @_;

    my $db = $self->_get_db($id);

    return $self->_get_field($db, $id, "name");
}

# return a description of a KEGG database entry
sub definition
{
    my ($self, $id) = @_;

    my $db = $self->_get_db($id);

    return $self->_get_field($db, $id, "definition");
}

# return the synonyms of a KEGG database entry
sub synonyms
{
    my ($self, $id) = @_;

    my $db = $self->_get_db($id);

    return $self->_get_field($db, $id, "synonym");
}

# return the type of a KEGG database entry
sub type
{
    my ($self, $id) = @_;

    return $self->_get_db($id);
}

# return the database that a KEGG entry is in
sub _get_db
{
    my ($self, $id) = @_;

    return $db_reaction if $id =~ /^R\d{5}$/;
    return $db_compound if $id =~ /^C\d{5}$/;
    return $db_glycan if $id =~ /^G\d{5}$/;
    return $db_orthology if $id =~ /^K\d{5}$/;
    return $db_rpair if $id =~ /^RP\d{5}$/;
    return $db_pathway if $id =~ /^([a-z]{2,3})?(\d{5})$/; # pathway ID with optional organism code
    return $db_enzyme if $id =~ /^(EC )?(\d+|-)\.(\d+|-)\.(\d+|-)\.(\d+|-)$/;

    Utils::Error("no database for ID '$id'");
}

# return the value of a database field for a KEGG entry in that database
sub _get_field
{
    my ($self, $db, $id, $field) = @_;

    Utils::Debug($self->{debug}, "get field: database=$db, id=$id, field=$field");

    # load database if necessary
    unless(exists($self->{$db})){
	if($db eq $db_reaction){
	    $self->_load_reaction();
	}elsif($db eq $db_compound){
	    $self->_load_compound();
	}elsif($db eq $db_glycan){
	    $self->_load_glycan();
	}elsif($db eq $db_orthology){
	    $self->_load_orthology();
	}elsif($db eq $db_rpair){
	    $self->_load_rpair();
	}elsif($db eq $db_pathway){
	    $self->_load_pathway_names();
	}else{
	    Utils::Error("unrecognized database '$db'");
	}
    }

    # stop if ID is not valid
    Utils::Error("unrecognized id '$id'") unless _is_valid_id($id);

    # load pathway data if necessary
    if($db eq $db_pathway && !exists($self->{$db}{$id}{$field})){
	if($field eq "compound" || $field eq "reaction" || $field eq "orthology"){
	    $self->_load_pathway_data($field);
	}elsif($field eq "mapping" || $field eq "equation"){
	    $self->_load_pathway_mapping();
	}else{
	    Utils::Error("unrecognized pathway field '$field'");
	}
    }

    return $self->{$db}{$id}{$field};
}

# get the path to a KEGG pathway data file
sub _get_pathway_file
{
    my ($self, $path_id, $ext) = @_;

    my $organism = $self->{organism};
    my $file = $organism eq "map" ? $pathway_map_data_file : $pathway_data_file;
    $file =~ s/ID/$path_id/g;
    $file =~ s/ORG/$organism/g;
    $file =~ s/EXT/$ext/g;

    return $self->{prefix} . $file;
}

# load a list of compounds (and glycans), reactions or orthologs present in a pathway
sub _load_pathway_data
{
    my ($self, $field) = @_;

    my $ext = $pathway_extension{$field}; # file extension depends on the type of data
    for my $path_id (keys %{$self->{$db_pathway}}){
	my $file = $self->_get_pathway_file($path_id, $ext);
	next unless -e $file; # pathways may only have some of the data files
	open DATA, "<$file" or Utils::Error("$0: $file: $!");
	while(<DATA>){
	    my ($path_element) = split /\s+/;
	    $self->{$db_pathway}{$path_id}{$field}{$path_element} = 1;
	}
	close DATA;
    }

    Utils::Debug($self->{debug}, "loaded KEGG pathway data '$field'");
}

# load the names of all KEGG pathways
sub _load_pathway_names
{
    my $self = shift;

    my $file = $self->{prefix} . $pathway_name_file;
    open NAME, "<$file" or Utils::Error("$0: $file: $!");
    while(<NAME>){
	chomp;
	my ($path_id,$path_name) = split /\t/;
	$self->{$db_pathway}{$path_id}{name} = $path_name;
    }
    close NAME;

    Utils::Debug($self->{debug}, "loaded KEGG pathway names");
}

# load mapping of reactions to KEGG pathways
sub _load_pathway_mapping
{
    my $self = shift;

    my $file = $self->{prefix} . $pathway_mapping_file;
    my $line = 0;
    open MAPPING, "<$file" or Utils::Error("$0: $file: $!");
    while(<MAPPING>){
	chomp;
	my ($rn_id, $path_id, $str) = split /: /;
	my $equation = _parse_equation($str);
	$self->{$db_pathway}{$path_id}{mapping}{$rn_id}{++$line} = $equation;

	my $prev = $self->{$db_pathway}{$path_id}{equation}{$rn_id};
	if(defined($prev)){
	    my $un = _union_equation($equation, $prev);
	    $self->{$db_pathway}{$path_id}{equation}{$rn_id} = $un;
	}else{
	    $self->{$db_pathway}{$path_id}{equation}{$rn_id} = $equation;
	}
    }
    close MAPPING;

    Utils::Debug($self->{debug}, "loaded KEGG reaction to pathway mapping");
}

# load the contents of the KEGG compound database
sub _load_compound
{
    my $self = shift;

    my $file = $self->{prefix} . $compound_file;
    open COMPOUND, "<$file" or Utils::Error("$0: $file: $!");
    while(<COMPOUND>){
	# the first field of each entry is the entry id
	/^ENTRY\s+(C\d{5})/ or Utils::Error("$0: $file: invalid entry: '$_'");
	my $id = $1;
	my $names = "";
	my @synonym;
	my @reaction;
	my @pathway;

	# process all remaining entry fields
	my $field = "";
	my $data;
	while(<COMPOUND>){
	    chomp;
	    /^\/\/\// and last;
	    /^ENTRY\s+/ and Utils::Error("$0: $file: $id: unexpected termination of entry");
	    /^([A-Z]*)\s*(.*)$/ or Utils::Error("$0: $file: $id: unrecognized data: '$_'");
	    $field = $1 if $1 ne ""; # update current field when new field is encountered
	    $data = $2;

	    # fields can span multiple lines, update entry based on current field
	    if($field eq $field_name){
		$names .= $data;
	    }elsif($field eq $field_reaction){
		push @reaction, split(/\s+/,$data);
	    }elsif($field eq $field_pathway && $data =~ /PATH: map(\d{5})/){
		push @pathway, $1;
	    }
	}
	@synonym = split /;/, $names;

	$self->{$db_compound}{$id} = {
	    name => $synonym[0],
	    synonym => \@synonym,
	    reaction => { map { $_ => 1 } @reaction },
	    pathway => { map { $_ => 1 } @pathway },
	};
    }
    close COMPOUND;

    Utils::Debug($self->{debug}, "loaded KEGG COMPOUND database");
}

# load the contents of the KEGG reaction database
sub _load_reaction
{
    my $self = shift;

    my $file = $self->{prefix} . $reaction_file;
    open REACTION, "$file" or Utils::Error("$0: $file: $!");
    while(<REACTION>){
	# the first field of each entry is the entry id
	/^ENTRY\s+(R\d{5})/ or Utils::Error("$0: $file: invalid entry: '$_'");
	my $id = $1;
	my $name = "";
	my $definition = "";
	my $equation = "";
	my @enzyme;
	my @orthology;
	my @pathway;
	my @rpair;

	# process all remaining entry fields
	my $field = "";
	my $data;
	while(<REACTION>){
	    chomp;
	    /^\/\/\// and last;
	    /^ENTRY/ and Utils::Error("$0: $file: $id: unexpected termination of entry");
	    /^([A-Z]*)\s*(.*)$/ or Utils::Error("$0: $file: $id: unrecognized data: '$_'");
	    $field = $1 if $1 ne ""; # update current field when new field is encountered
	    $data = $2;

	    # fields can span multiple lines, update entry based on current field
	    if($field eq $field_name){
		$name .= " " unless $name eq "" || $name =~ /-$/;
		$name .= $data;
	    }elsif($field eq $field_definition){
		$definition .= " " unless $definition eq "" || $definition =~ /-$/;
		$definition .= $data;
	    }elsif($field eq $field_equation){
		$equation .= " " unless $equation eq "";
		$equation .= $data;
	    }elsif($field eq $field_enzyme){
		push @enzyme, split(/\s+/,$data);
	    }elsif($field eq $field_orthology && $data =~ /KO: (K\d{5})/){
		push @orthology, $1;
	    }elsif($field eq $field_pathway && $data =~ /PATH: rn(\d{5})/){
		push @pathway, $1;
	    }elsif($field eq $field_rpair && $data =~ /RP: (RP\d{5})/){
		push @rpair, $1;
	    }
	}

	$self->{$db_reaction}{$id} = {
	    name => $name,
	    definition => $definition,
	    equation => _parse_equation($equation),
	    enzyme => { map { $_ => 1 } @enzyme },
	    orthology => { map { $_ => 1 } @orthology },
	    pathway => { map { $_ => 1 } @pathway },
	    rpair => { map { $_ => 1 } @rpair },
	};
    }
    close REACTION;

    Utils::Debug($self->{debug}, "loaded KEGG REACTION database");
}

# load the contents of the KEGG orthology database
sub _load_orthology
{
    my $self = shift;

    my $file = $self->{prefix} . $orthology_file;
    open ORTHOLOGY, "$file" or Utils::Error("$0: $file: $!");
    while(<ORTHOLOGY>){
	# the first field of each entry is the entry id
	/^ENTRY\s+(K\d{5})/ or Utils::Error("$0: $file: invalid entry: '$_'");
	my $id = $1;
	my $name = "";
	my $definition = "";

	# process all remaining entry fields
	my $field = "";
	my $data;
	while(<ORTHOLOGY>){
	    chomp;
	    /^\/\/\// and last;
	    /^ENTRY/ and Utils::Error("$0: $file: $id: unexpected termination of entry");
	    /^([A-Z]*)\s*(.*)$/ or Utils::Error("$0: $file: $id: unrecognized data: '$_'");
	    $field = $1 if $1 ne ""; # update current field when new field is encountered
	    $data = $2;

	    # fields can span multiple lines, update entry based on current field
	    if($field eq $field_name){
		$name .= " " unless $name eq "" || $name =~ /-$/;
		$name .= $data;
	    }elsif($field eq $field_definition){
		$definition .= " " unless $definition eq "" || $definition =~ /-$/;
		$definition .= $data;
	    }
	}

	$self->{$db_orthology}{$id} = {
	    name => $name,
	    definition => $definition,
	};
    }
    close ORTHOLOGY;

    Utils::Debug($self->{debug}, "loaded KEGG ORTHOLOGY database");
}

# load the contents of the KEGG glycan database
sub _load_glycan
{
    my $self = shift;

    my $file = $self->{prefix} . $glycan_file;
    open GLYCAN, "$file" or Utils::Error("$0: $file: $!");
    while(<GLYCAN>){
	# the first field of each entry is the entry id
	/^ENTRY\s+(G\d{5})/ or Utils::Error("$0: $file: invalid entry: '$_'");
	my $id = $1;
	my $names = "";
	my @synonym;

	# process all remaining entry fields
	my $field = "";
	my $data;
	while(<GLYCAN>){
	    chomp;
	    /^\/\/\// and last;
	    /^ENTRY/ and Utils::Error("$0: $file: $id: unexpected termination of entry");
	    /^([A-Z]*)\s*(.*)$/ or Utils::Error("$0: $file: $id: unrecognized data: '$_'");
	    $field = $1 if $1 ne ""; # update current field when new field is encountered
	    $data = $2;

	    # fields can span multiple lines, update entry based on current field
	    if($field eq $field_name){
		$names .= $data;
	    }
	}
	@synonym = split /;/, $names;

	$self->{$db_glycan}{$id} = {
	    name => @synonym > 0 ? $synonym[0] : $id, # many glycan entries have no names
	    synonym => \@synonym,
	};
    }
    close GLYCAN;

    Utils::Debug($self->{debug}, "loaded KEGG GLYCAN database");
}

# load the contents of the KEGG enzyme database
sub _load_enzyme
{
    my $self = shift;

    my $file = $self->{prefix} . $enzyme_file;
    open ENZYME, "<$file" or Utils::Error("$0: $file: $!");
    while(<ENZYME>){
	# the first field of each entry is the entry id
	/^ENTRY\s+(EC (\d+|-)\.(\d+|-)\.(\d+|-)\.(\d+|-))/ or Utils::Error("$0: $file: invalid entry: '$_'");
	my $id = $1;
	my $names = "";
	my @synonym;
	my @orthology;

	# process all remaining entry fields
	my $field = "";
	my $data;
	while(<ENZYME>){
	    chomp;
	    /^\/\/\// and last;
	    /^ENTRY/ and Utils::Error("$0: $file: $id: unexpected termination of entry");
	    /^([A-Z]*)\s*(.*)$/ or Utils::Error("$0: $file: $id: unrecognized data: '$_'");
	    $field = $1 if $1 ne ""; # update current field when new field is encountered
	    $data = $2;

	    # fields can span multiple lines, update entry based on current field
	    if($field eq $field_name){
		$names .= $data;
	    }elsif($field eq $field_orthology && $data =~ /KO: (K\d{5})/){
		push @orthology, $1;
	    }
	}
	@synonym = split /;/, $names;

	$self->{$db_enzyme}{$id} = {
	    name => @synonym > 0 ? $synonym[0] : $id, # many enzyme entries have no names
	    synonym => \@synonym,
	    orthology => { map { $_ => 1 } @orthology },
	};
    }
    close ENZYME;

    Utils::Debug($self->{debug}, "loaded KEGG ENZYME database");
}

# load elements of the KEGG rpair database
sub _load_rpair
{
    my $self = shift;

    my $file = $self->{prefix} . $rpair_file;
    open RPAIR, "<$file" or Utils::Error("$0: $file: $!");
    while(<RPAIR>){
	# the first field of each entry is the entry id
	/^ENTRY\s+(RP\d{5})/ or Utils::Error("$0: $file: invalid entry: '$_'");
	my $id = $1;
	my $name;
	my @compound;
	my @type;
	my @reaction;

	# process all remaining entry fields
	my $field = "";
	my $data;
	while(<RPAIR>){
	    chomp;
	    /^\/\/\// and last;
	    /^ENTRY\s+/ and Utils::Error("$0: $file: $id: unexpected termination of entry");
	    /^([A-Z]*)\s*(.*)$/ or Utils::Error("$0: $file: $id: unrecognized data: '$_'");
	    $field = $1 if $1 ne ""; # update current field when new field is encountered
	    $data = $2;

	    # fields can span multiple lines, update entry based on current field
	    if($field eq $field_name){
		$name = $data;
	    }elsif($field eq $field_compound && $data =~ /(C\d{5})/){
		push @compound, $1;
	    }elsif($field eq $field_type){
		push @type, split(/\s+/, $data);
	    }elsif($field eq $field_reaction){
		push @reaction, split(/\s+/, $data);
	    }
	}

	$self->{$db_rpair}{$id} = {
	    name => $name,
	    compound => \@compound,
	    type => { map { $_ => 1 } @type },
	    reaction => { map { $_ => 1 } @reaction },
	};
    }
    close RPAIR;

    Utils::Debug($self->{debug}, "loaded KEGG RPAIR database");
}

# parse a KEGG reaction equation
sub _parse_equation
{
    my $str = shift;

    my $equation = {};
    if($str =~ /(<?=>?)/){
	my $dir = $1;
	my ($left, $right) = split / $dir /, $str;
	for my $cpd (split(/ \+ /, $left)){
	    my $coeff = 1;
	    if($cpd =~ /^(\w+) ([CG]\d{5})/){
		$coeff = $1;
		$cpd = $2;
	    }elsif($cpd =~ /^([CG]\d{5})/){
		$cpd = $1;
	    }
	    $equation->{left}{$cpd} = $coeff;
	}
	for my $cpd (split(/ \+ /, $right)){
	    my $coeff = 1;
	    if($cpd =~ /^(\w+) ([CG]\d{5})/){
		$coeff = $1;
		$cpd = $2;
	    }elsif($cpd =~ /^([CG]\d{5})/){
		$cpd = $1;
	    }
	    $equation->{right}{$cpd} = $coeff;
	}
	$equation->{direction} = $dir;
    }

    return $equation;
}

# produce the union of two KEGG reaction equations
sub _union_equation
{
    my ($eqn1, $eqn2) = @_;

    my $union = {};
    my $dir1 = $eqn1->{direction};
    my $dir2 = $eqn2->{direction};
    if($dir1 eq $dir2){
	$union->{direction} = $dir1;
    }else{
	$union->{direction} = "<=>";
    }
    my @left = (keys %{$eqn1->{left}}, keys %{$eqn2->{left}});
    my @right = (keys %{$eqn1->{right}}, keys %{$eqn2->{right}});
    for my $cpd (@left){
	$union->{left}{$cpd} = 1;
    }
    for my $cpd (@right){
	$union->{right}{$cpd} = 1;
    }

    return $union;
}

# convert a KEGG reaction equation into a string
sub _equation_string
{
    my $eqn = shift;

    my @left;
    for my $cpd_id (sort keys %{$eqn->{left}}){
	my $coeff = $eqn->{left}{$cpd_id};
	push @left, "$coeff $cpd_id";
    }
    my @right;
    for my $cpd_id (sort keys %{$eqn->{right}}){
	my $coeff = $eqn->{right}{$cpd_id};
	push @right, "$coeff $cpd_id";
    }
    my $lstr = join " + ", @left;
    my $rstr = join " + ", @right;
    unless(defined($lstr)){
	$lstr = '';
    }
    unless(defined($rstr)){
	$rstr = '';
    }
    my $dir = $eqn->{direction};
    unless(defined($dir)){
	$dir = '';
    }

    return join " ", $lstr, $dir, $rstr;
}

# determine if an ID is a valid KEGG database ID
sub _is_valid_id
{
    my $id = shift;

    return 1 if $id =~ /^R\d{5}$/; # KEGG reaction database
    return 1 if $id =~ /^C\d{5}$/; # KEGG compound database
    return 1 if $id =~ /^G\d{5}$/; # KEGG glycan database
    return 1 if $id =~ /^K\d{5}$/; # KEGG orthology database
    return 1 if $id =~ /^RP\d{5}$/; # KEGG rpair database
    return 1 if $id =~ /^([a-z]{2,3})?(\d{5})$/; # KEGG pathway ID with optional organism code
    return 1 if $id =~ /^(EC )?(\d+|-)\.(\d+|-)\.(\d+|-)\.(\d+|-)$/; # EC number
    return 0;
}

1;
