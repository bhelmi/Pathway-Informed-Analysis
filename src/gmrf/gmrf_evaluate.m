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
## @deftypefn{Function File} {[@var{predict}, @var{score}] =} gmrf_evaluate(@var{data}, @var{model}, @var{options})
## Evaluate a GMRF-based Bayesian classifier.
##
## Classify the instances in the @var{n} by @var{p} matrix @var{data}
## given the GMRF model parameters in @var{model} for positive and
## negative instances.  The @var{n} by 1 vector @var{predict} indicates
## the predicted class of each instance and confidence values can be
## derived from the @var{n} by 1 vector @var{score}.
## @end deftypefn

function [predict score] = gmrf_evaluate(data, model, options)

  n = size(data, 1);

  score = nan(n, 1);

  for i = 1:n
    ## determine the set of observed variables
    observed = ~isnan(data(i, :));
    instance = data(i, observed);
    
    ## determine parameters of marginal distribution for observed variables
    marg_sigma_pos = model.sigma_pos(observed, observed);
    marg_sigma_neg = model.sigma_neg(observed, observed);
    marg_mu_pos = model.mu_pos(observed);
    marg_mu_neg = model.mu_neg(observed);
    
    ## compute posterior log-probabilities for each class
    posterior_pos = normal_log_density(instance, marg_mu_pos, marg_sigma_pos) + log(model.prior_pos);
    posterior_neg = normal_log_density(instance, marg_mu_neg, marg_sigma_neg) + log(model.prior_neg);
    
    ## equal posteriors are highly unlikely and typically indicate a bug
    assert(posterior_pos ~= posterior_neg);
    
    score(i) = posterior_pos - posterior_neg;
  end

  predict = score > 0.0;

end
