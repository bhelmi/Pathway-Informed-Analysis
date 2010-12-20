## Copyright 2010 Thomas Eastman
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {[@var{data}, @var{classes}, @var{graph}] =} permute_nodes(@var{data}, @var{classes}, @var{graph})
## Permute node labels (variables).
##
## Randomly permute the variables in the @var{n} by @var{p} matrix
## @var{data}.  This is equivalent to permuting the labels of the nodes
## in the graph structure @var{graph}.  The class labels in the @var{n}
## by 1 vector @var{classes} is unchanged.
##
## @seealso{permutations}
## @end deftypefn

function [data classes graph] = permute_nodes(data, classes, graph)

  ## randomly permute the nodes in the model by rearranging the columns of the data set
  p = size(data, 2);
  ord = randperm(p);
  data = data(:, ord);

end
