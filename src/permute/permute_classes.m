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
## @deftypefn{Function File} {[@var{data}, @var{classes}, @var{graph}] =} permute_classes(@var{data}, @var{classes}, @var{graph})
## Permute class labels.
##
## Randomly permute the class labels in the @var{n} by 1 vector
## @var{classes} corresponding to the instances in the @var{n} by
## @var{p} matrix @var{data}.  The matrix @var{data} and the graph
## structure (if any) for the @var{p} variables are unchanged.
##
## @seealso{permutations}
## @end deftypefn

function [data classes graph] = permute_classes(data, classes, graph)

  ## randomly permute the class labels
  n = size(data, 1);
  ord = randperm(n);
  classes = classes(ord, :);

end
