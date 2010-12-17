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
## @deftypefn{Function File} {mu =} wmean(@var{X}, @var{w})
## Weighted arithmetic mean.
##
## Compute the weighted arithmetic mean of the columns of the @var{n}
## by @var{p} matrix @var{X}.  The rows of @var{X} are weighted by the
## values given in the @var{n} by 1 weight vector @var{w}.
## @end deftypefn

function mu = wmean(X, w)

  n = size(X, 1);

  if nargin < 2, w = ones(n, 1); end

  mu = sum(diag(w) * X) ./ sum(w);

end
