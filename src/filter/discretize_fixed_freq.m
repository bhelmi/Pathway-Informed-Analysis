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
## @deftypefn{Function File} {@var{split} =} discretize_fixed_freq(@var{data}, @var{m})
## Discretize continuous attributes into intervals with a given number of values.
##
## Discretize the columns of the @var{n} by @var{p} matrix @var{data} by
## splitting each attribute such that each interval contains
## approximately @var{m} values.
##
## The method is described in section 7.2 of the paper
##
## Y. Yang and G. I. Webb.  Discretization for Naive-Bayes Learning:
## Managing Discretization Bias and Variance.  Machine Learning,
## 74:39-74, 2009.
##
## @seealso{discretize}
## @end deftypefn

function split = discretize_fixed_freq(data, m)

  p = size(data, 2);

  split = cell(p, 1);

  for v = 1:p
    ## get unique values for current variable of the data set.
    ## assume that there are not many duplicates. thus the effect
    ## of producing the discretization without considering the
    ## duplicates is minimized.
    values = data(:, v);
    values = unique(values);
    
    n = size(values, 1);
    
    ## interval number
    t = round(n / m);
    
    ## update interval frequency
    s = floor(n / t);
    
    ## number of intervals that must accomodate an extra instance
    nextra = mod(n, s);
    
    ## number of instances in each interval
    interval_size = s * ones(t, 1);
    interval_size(1:nextra) = interval_size(1:nextra) + 1;
    
    ## compute quantitative split points as the midpoints between
    ## extreme values in adjacent intervals
    split_index = 0;
    split{v} = zeros(t-1,1);
    for i = 1:t-1
      split_index = split_index + interval_size(i);
      split{v}(i) = 0.5 * (values(split_index) + values(split_index+1));
    end
  end

end
