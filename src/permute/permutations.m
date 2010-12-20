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
## @deftypefn{Function File} permutations(@var{data}, @var{classes}, @var{graph}, @var{permute}, @var{learn}, @var{nperm}, @var{options})
## Perform permutation experiments.
##
## Evaluate the learning algorithm @var{learn} on a permuted data set
## determined by the permutation function @var{permute}.  This function
## alters @var{data}, @var{classes} and/or @var{graph} by permuting
## class labels, nodes, edges, etc.  This program performs @var{nperm}
## repetitions and prints some statistics summarizing the results.
##
## Bugs: This program currently only handles classification experiments
## and it assumes that all instance weights are equal.
## @end deftypefn

## PERMUTATIONS generate random permutations and evaluate learning algorithms

function permutations(data, classes, graph, permute, learn, nperm, options)

  n = size(data, 1);

  weights = ones(n, 1);

  ## determine base accuracy before permutation
  predicted = cross_validate(data, classes, learn, options, weights, graph);
  threshold = 100.0 * sum(predicted == classes) / n;

  correct = nan(nperm, 1);
  percent = nan(nperm, 1);
  outcome = zeros(n + 1, 1);
  nbetter = 0;

  for i = 1:nperm
    ## apply the selected permutation: classes, instances, nodes, etc.
    [pdata pclasses pgraph] = permute(data, classes, graph);
    
    ## evaluate learning with the permutation
    predicted = cross_validate(pdata, pclasses, learn, options, weights, pgraph);
    correct(i) = sum(predicted == pclasses);
    percent(i) = 100.0 * correct(i) / n;

    ## count results better than non-permuted case
    if percent(i) > threshold
      nbetter = nbetter + 1;
    end

    ## increment outcome frequency
    outcome(correct(i) + 1) = outcome(correct(i) + 1) + 1;
  end

  fprintf("correct %.2f sd %.2f ", mean(correct), std(correct));
  fprintf("percent %.2f sd %.2f ", mean(percent), std(percent));
  fprintf("threshold %.2f better %d\n", threshold, nbetter);
  fprintf("frequency:");
  fprintf(" %d", outcome);
  fprintf("\n");

end
