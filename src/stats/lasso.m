% Copyright 2010 Thomas Eastman
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% -*- texinfo -*-
% @deftypefn{Function File} {[@var{beta_0}, @var{beta}, @var{iterations}, @var{converged}] =} lasso(@var{X}, @var{y}, @var{lambda}, @var{verbose}, @var{maxiterations}, @var{epsilon})
% L1 regularized linear regression (Lasso).
% @end deftypefn

%
% Implementation of the pathwise algorithm described in the paper
%
%  J. Friedman, T. Hastie, H. Höfling and R. Tibshirani. Pathwise Coordinate Optimization.
%  The Annals of Applied Statistics, 1(2):302-332, 2007.
%
function [beta_0 beta iteration converged] = lasso(X, y, lambda, verbose, maxiterations, epsilon)

  if nargin < 4, verbose = 0; end
  if nargin < 5, maxiterations = 100000; end
  if nargin < 6, epsilon = 1e-10; end

  n = size(X, 1);
  p = size(X, 2);

  % standardize the data
  [m b] = standardize(X, 1);
  X = transform(X, m, b);

  % model intercept (note that E[X_ij] = 0 after standardization)
  beta_0 = mean(y);

  % start with the Ridge regression solution
  beta = (X' * X + lambda * eye(p)) \ (X' * y);
  %beta = zeros(p, 1);

  % cache summations
  XX = X' * X;
  Xy = X' * y;

  converged = 0;
  for iteration = 1:maxiterations
    beta_old = beta;

    for j = 1:p
      S0 = 1/n * (Xy(j) - XX(j, :) * beta + XX(j, j) * beta(j));
      if S0 > lambda
        beta(j) = S0 - lambda;
      elseif S0 < - lambda
        beta(j) = S0 + lambda;
      else
        beta(j) = 0.0;
      end
    end
    
    if verbose
      fprintf('iteration %d: beta ', iteration);
      fprintf('%.6f ', beta(1:end-1));
      fprintf('%.6f\n', beta(end));
    end

    % check for convergence
    if all(abs(beta - beta_old) < epsilon)
      converged = 1;
      break
    end
  end

  % transform the coefficients into the original scale of the data
  beta_0 = beta_0 + sum(beta .* b');
  beta = beta .* m';

  if verbose
    fprintf('final coefficients: %.6f :', beta_0);
    fprintf(' %.6f', beta);
    fprintf('\n');
  end

end
