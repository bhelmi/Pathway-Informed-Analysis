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
## @deftypefn{Function File} {[@var{data}, @var{select}] =} resample(@var{data}, @var{weight}, @var{percent})
## Randomly sample instances of a data set with replacement.
##
## Produce a data set by randomly selecting instances from the @var{n}
## by @var{p} matrix @var{data} with replacement.  The @var{n} by 1
## vector @var{weight} determines the relative probability of selecting
## each instance.  The number of instances in the resulting data set
## contains a number of instances approximately equal to @var{percent}
## percent of @var{n}.
##
## By default each instance in @var{data} is given equal weight and the
## number of sampled instances is equal to @var{n}.
## @end deftypefn

function [data select] = resample(data, weight, percent)

  n = size(data, 1);

  if nargin < 2, weight = ones(n, 1); end
  if nargin < 3, percent = 100.0; end

  ## compute sampling probabilites proprtional to instance weights
  prob = weight ./ sum(weight);

  ## compute number of instances in the new data set
  nsamples = round(n * percent / 100.0);

  cprob = cumsum(prob);
  sample = rand(nsamples, 1);
  select = ones(nsamples, 1);
  for i = 1:n-1
    select = select + (sample > cprob(i));
  end

  data = data(select, :);

end
