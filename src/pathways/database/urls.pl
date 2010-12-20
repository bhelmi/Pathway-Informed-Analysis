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
# Print a list of record URLs for a database.  The --db or --database
# option determines the selected database.
#

use strict;
use warnings;
use Options qw(:standard);
use Utils;
use Kegg;

Options::Process();

my $db = $db_type->new($db_prefix, $organism, $debug);

# URL patterns for KEGG database entries
my $url_prefix    = "http://www.genome.jp/dbget-bin";
my $url_pathway   = "$url_prefix/get_pathway?org_name=ORG&mapno=ID";
my $url_reaction  = "$url_prefix/www_bget?reaction+ID";
my $url_compound  = "$url_prefix/www_bget?compound+ID";
my $url_glycan    = "$url_prefix/www_bget?glycan+ID";
my $url_enzyme    = "$url_prefix/www_bget?enzyme+ID";

my ($url_pattern, @ids) =
    $db_name eq "pathway"   ? ($url_pathway,   $db->pathways)  :
    $db_name eq "reaction"  ? ($url_reaction,  $db->reactions) :
    $db_name eq "compound"  ? ($url_compound,  $db->compounds) :
    $db_name eq "glycan"    ? ($url_glycan,    $db->glycans)   :
    $db_name eq "enzyme"    ? ($url_enzyme,    $db->enzymes)   : ("", );

Utils::Warn("no records in database '$db_name'") if @ids == 0;

# generate a URL for each entry
for my $id (sort @ids){
    my $url = $url_pattern;
    $url =~ s/ORG/$organism/;
    $url =~ s/ID/$id/;
    $url =~ s/EC //; # remove EC prefix from enzyme IDs
    print "$id\t$url\n";
}
