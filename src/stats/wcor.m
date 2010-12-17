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
## @deftypefn{Function File} {@var{r} =} wcor(@var{X}, @var{w})
## Weighted correlation.
##
## Compute the weighted correlation of the columns of the @var{n} by
## @var{p} matrix @var{X}.  The rows of @var{X} are weighted by the
## values given in the @var{n} by 1 weight vector @var{w}.
## @end deftypefn

function r = wcor(X, w)

  [n p] = size(X);

  if nargin < 2, w = ones(n, 1); end

  q = wcov(X, w);

  v = diag(q);
  vrep = repmat(v, 1, p);
  vv = vrep .* vrep';

  r = q ./ sqrt(vv);

end
