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
# Print a list of record IDs for a database.  The --db or --database
# option determines the selected database.
#

use strict;
use warnings;
use Options qw(:standard);
use BioCyc;
use Kegg;

Options::Process();

my $db = $db_type->new($db_prefix, $organism, $debug);

my @ids =
    $db_name eq "pathway"  ? $db->pathways()  :
    $db_name eq "reaction" ? $db->reactions() :
    $db_name eq "compound" ? $db->compounds() :
    $db_name eq "glycan"   ? $db->glycans()   :
    $db_name eq "enzyme"   ? $db->enzymes()   : ();

Utils::Warn("no records in database '$db_name'") if @ids == 0;

for my $id (@ids){
    print "$id\n";
}
