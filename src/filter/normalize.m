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
## @deftypefn{Function File} {[@var{m}, @var{b}] =} normalize(@var{data}, @var{scale}, @var{trans})
## Linear transformation of continuous attributes into a specific range.
##
## Transform the continuous attribute values given by the columns of the
## @var{n} by @var{p} matrix @var{data} into a specific range determined
## by @var{scale} and @var{trans}.  Specifically, the minimum
## transformed attribute value is determined by @var{trans} and the
## maximum is @var{trans} + @var{scale}.
##
## The transformation is accomplished in a linear fashion using the
## appropriate elements of the 1 by @var{p} slope vector @var{m} and
## intercept vector @var{b}.  For example
##
## @example
## data(i, j) = m(j) * data(i, j) + b(j);
## @end example
##
## @seealso{transform}
## @end deftypefn

function [m b] = normalize(data, scale, trans)

  if nargin < 2
    scale = 1.0;
    trans = 0.0;
  end

  ## produce attributes such that:
  ## min value is translation
  ## max value is translation + scale

  ## x = x - min(x); # minimum value becomes 0.0
  ## x = x / max(x); # maximum value becomes 1.0
  ## x = x * scale;  # minimum/maximum values become 0.0/scale
  ## x = x + trans;  # minimum/maximum values become translation/translation+scale

  n = size(data, 1);

  data_min = min(data);
  data_max = max(data - repmat(data_min, n, 1));

  m = scale ./ data_max;
  b = -scale * data_min ./ data_max + trans;

end
