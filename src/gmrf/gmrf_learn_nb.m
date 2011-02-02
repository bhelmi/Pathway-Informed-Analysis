## Copyright 2011 Thomas Eastman
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{model} =} gmrf_learn_nb(@var{data}, @var{classes}, @var{options})
## Learn a GMRF-based Bayesian classifier with an empty graph structure (Naive Bayes).
##
## Estimate maximum likelihood GMRF model parameters for the instances
## given in the @var{n} by @var{p} matrix @var{data} with corresponding
## classes in the @var{n} by 1 vector @var{classes}.  An empty graph
## is used as the structure for the GMRF model of both positive and
## negative instances.  Note that this is equivalent to Naive Bayes
## for Gaussian input variables.
##
## @seealso{gmrf_evaluate}
## @end deftypefn

function model = gmrf_learn_nb(data, classes, options)

  weights = options.weights;

  pos = classes == 1;
  neg = classes == 0;

  data_pos = data(pos, :);
  data_neg = data(neg, :);

  weight_pos = weights(pos);
  weight_neg = weights(neg);

  prior_pos = sum(weight_pos) / sum(weights);
  prior_neg = sum(weight_neg) / sum(weights);

  mu_pos = wmean(data_pos, weight_pos);
  mu_neg = wmean(data_neg, weight_neg);

  sigma_pos = diag(wvar(data_pos, weight_pos));
  sigma_neg = diag(wvar(data_neg, weight_neg));


  model = struct;
  model.mu_pos = mu_pos;
  model.mu_neg = mu_neg;
  model.sigma_pos = sigma_pos;
  model.sigma_neg = sigma_neg;
  model.prior_pos = prior_pos;
  model.prior_neg = prior_neg;
  model.iterations = 0;
  model.converged = 1;
  model.evaluate = @gmrf_evaluate;

end
