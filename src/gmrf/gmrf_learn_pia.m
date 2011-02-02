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
## @deftypefn{Function File} {@var{model} =} gmrf_learn_pia(@var{data}, @var{classes}, @var{options})
## Learn a GMRF-based Bayesian classifier with a "known" graph structure (Pathway Informed Analysis).
##
## Estimate maximum likelihood GMRF model parameters for the instances
## given in the @var{n} by @var{p} matrix @var{data} with corresponding
## classes in the @var{n} by 1 vector @var{classes}.  A known graph
## is used as the structure for the GMRF model of both positive and
## negative instances.  This "known" graph structure is typically
## derived from a set of metabolic pathways that describe how the
## input variables (metabolites) react with each other.
##
## @seealso{gmrf_evaluate}
## @end deftypefn

function model = gmrf_learn_pia(data, classes, options)

  p = size(data, 2);

  graph = options.graph;
  weights = options.weights;
  target = options.shrinkage_target;
  maxit = options.maxiterations;
  debug = options.debug;

  graph_check(graph, p);

  structure = graph.structure;
  cliques = graph.cliques;

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

  sigma_pos = wcov_shrink(data_pos, weight_pos, target);
  sigma_neg = wcov_shrink(data_neg, weight_neg, target);

  ## fit empirical covariance matrices to a covariance selection model
  [sigma_pos iterations_pos converged_pos] = cov_speed(sigma_pos, structure, cliques, maxit, debug);
  [sigma_neg iterations_neg converged_neg] = cov_speed(sigma_neg, structure, cliques, maxit, debug);


  model = struct;
  model.mu_pos = mu_pos;
  model.mu_neg = mu_neg;
  model.sigma_pos = sigma_pos;
  model.sigma_neg = sigma_neg;
  model.prior_pos = prior_pos;
  model.prior_neg = prior_neg;
  model.iterations = iterations_pos + iterations_neg;
  model.converged = converged_pos && converged_neg;
  model.evaluate = @gmrf_evaluate;

end
