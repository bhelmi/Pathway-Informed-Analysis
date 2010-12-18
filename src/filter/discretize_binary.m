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
## @deftypefn{Function File} {@var{split} =} discretize_binary(@var{data})
## Discretize continuous attributes into binary values.
##
## Discretize the columns of the @var{n} by @var{p} matrix @var{data} by
## splitting each attribute at its mean value.
##
## @seealso{discretize}
## @end deftypefn

function split = discretize_binary(data)

  p = size(data, 2);
  mu = mean(data);
  split = cell(p, 1);
  for v = 1:p
    ## divide the range of values into two intervals
    split{v} = [ mu(v) ];
  end

end
