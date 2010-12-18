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
## @deftypefn{Function File} {@var{split} =} discretize_zscores(@var{data}, @var{threshold})
## Discretize continuous attributes into three intervals based on Z-score thresholds.
##
## Discretize the columns of the @var{n} by @var{p} matrix @var{data} by
## splitting each attribute into three intervals determined by a
## threshold on its Z-scores.  The thresholds are determined by
## +@var{threshold} and -@var{threshold}.
##
## The intuition is that each continuous value is discretized into high,
## normal and low values.
## @seealso{discretize}
## @end deftypefn

function split = discretize_zscores(data, threshold)

  if nargin < 2, threshold = 1.0; end

  p = size(data, 2);
  split = cell(p, 1);
  for v = 1:p
    values = data(:, v);
    sigma = std(values);
    mu = mean(values);

    ## divide the range of values into three intervals
    split{v} = [ -threshold * sigma + mu; threshold * sigma + mu ];
  end

end
