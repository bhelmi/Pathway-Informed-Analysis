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
## @deftypefn{Function File} {@var{M} =} rspdmatrix(@var{n})
## Random symmetric positive definite matrix.
##
## Generate a random @var{n} by @var{n} matrix that is symmetric and
## positive definite.
##
## This program implements the "eigen" method of the clusterGeneration
## package from R.  See
## http://cran.r-project.org/web/packages/clusterGeneration/index.html
## for details.
## @end deftypefn

function M = rspdmatrix(n)

  X = randn(n);

  [Q R] = qr(X);
  S = diag(sign(diag(R)));
  Q = Q * S;

  eigenvals = rand(n, 1) * 9 + 1;
  eigenvals = diag(eigenvals);

  M = Q * eigenvals * Q';

end
