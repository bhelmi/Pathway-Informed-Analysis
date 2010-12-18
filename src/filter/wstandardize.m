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
## @deftypefn{Function File} {[@var{m}, @var{b}] =} wstandardize(@var{data}, @var{weights}, @var{flag})
## Linear transformation of continuous attributes from weighted
## instances to have zero mean and unit variance.
##
## Transform the continuous attribute values given by the columns of the
## @var{n} by @var{p} matrix @var{data} such that the transformed
## attributes have mean zero and variance one.  The @var{n} by 1 vector
## @var{weights} gives the weight of each instance in @var{data}.
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

function [m b] = wstandardize(data, weights, flag)

  n = size(data, 1);

  if nargin < 2, weights = ones(n, 1); end
  if nargin < 3, flag = 0; end

  mu = wmean(data, weights);
  sigma2 = wvar(data, weights, flag);
  sigma = sqrt(sigma2);

  m = 1 ./ sigma;
  b = -mu ./ sigma;

end
