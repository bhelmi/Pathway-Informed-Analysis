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
# Print a list of the nodes in a graph structure sorted by node ID.
#

use strict;
use warnings;
use Options qw(:standard :input :attr);
use Utils;

Options::Process();

my $graph = Utils::LoadGraph($input_file);
my @nodes = sort $graph->vertices;
for my $v (@nodes){
    my $name = $element_name{$v};
    print "$v\t$name\n";
}
