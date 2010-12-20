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
## @deftypefn{Function File} {[@var{data}, @var{classes}, @var{graph}] =} permute_instances(@var{data}, @var{classes}, @var{graph})
## Permute instances and class labels.
##
## Randomly permute the instances in the @var{n} by @var{p} matrix
## @var{data} and the corresponding class labels in the @var{n} by 1
## vector @var{classes}.  After permutation, rearrange the instances
## such that the class distribution is consistent across folds
## (regardless of how many folds are used). The graph structure (if any)
## for the @var{p} variables is unchanged.
##
## The purpose of this program is to determine how consistent cross
## validation results are for different fold selections.
##
## @seealso{permutations}
## @end deftypefn

function [data classes graph] = permute_instances(data, classes, graph)

  ## randomly permute the instances
  n = size(data, 1);
  ord = randperm(n);
  data = data(ord, :);
  classes = classes(ord, :);

  ## rearrange to ensure approximately equal class distribution within each fold
  [data classes] = distribute_classes(data, classes);

end
