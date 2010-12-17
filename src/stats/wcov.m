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
## @deftypefn{Function File} {q =} wcov(@var{X}, @var{w}, @var{flag})
## Weighted covariance.
##
## Compute the weighted covariance matrix for the columns of the @var{n}
## by @var{p} matrix @var{X}.  The rows of @var{X} are weighted by the
## values given in the @var{n} by 1 weight vector @var{w}.
##
## The @var{flag} argument determines if the (co)variances are biased or
## unbiased.  By default, unbiased (co)variances are computed.  If
## @var{flag} is true then the computed (co)variances are biased.
## @end deftypefn

function q = wcov(X, w, flag)

  n = size(X, 1);

  if nargin < 2, w = ones(n, 1); end
  if nargin < 3, flag = 0; end

  mu = wmean(X, w);
  Xc = X - repmat(mu, n, 1);
  XXw = Xc' * diag(w) * Xc;

  v1 = sum(w);
  v2 = sum(w .^ 2);

  if flag
    ## biased estimate
    q = 1 / v1 * XXw;
  else
    ## unbaised estimate
    q = v1 / (v1^2 - v2) * XXw;
  end

  ## make covariance matrix symmetric
  q = 0.5 * (q + q');

end
