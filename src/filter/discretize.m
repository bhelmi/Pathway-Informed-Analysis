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
## @deftypefn{Function File} {@var{data} =} discretize(@var{data}, @var{split})
## Discretize continuous attributes given a set of split points.
##
## Convert the continuous attribute values given by the columns of the
## @var{n} by @var{p} matrix @var{data} into discrete values.  The
## discretization is defined by one or more per-attribute split points
## given in the @var{p} by 1 cell array @var{split}.  Split point(s)
## corresponding to attribute @var{i} are determined by the vector
## @var{split@{i@}}.  If attribute @var{i} is split at @var{nsplit}
## points then its values in the returned matrix @var{data} will be in
## the set @{1, 2, ..., @var{nsplit} + 1@}.
## @end deftypefn

function data = discretize(data, split)

  [n p] = size(data);

  for i = 1:n
    for v = 1:p
      data(i, v) = sum(data(i, v) > split{v}) + 1;
    end
  end

end
