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
## @deftypefn{Function File} {@var{split} =} discretize_equal_freq(@var{data}, @var{k})
## Discretize continuous attributes into intervals with a given width.
##
## Discretize the columns of the @var{n} by @var{p} matrix @var{data} by
## splitting each attribute into @var{k} intervals of equal width.
##
## The method is described in section 6.1 of the paper
##
## Y. Yang and G. I. Webb.  Discretization for Naive-Bayes Learning:
## Managing Discretization Bias and Variance.  Machine Learning,
## 74:39-74, 2009.
##
## @seealso{discretize}
## @end deftypefn

function split = discretize_equal_width(data, k)

  p = size(data, 2);

  split = cell(p, 1);

  for v = 1:p
    values = data(:, v);
    value_min = min(values);
    value_max = max(values);
    
    ## compute the interval width
    w = (value_max - value_min) / k;
    
    split{v} = 1:k-1;
    split{v} = split{v}' * w;
    split{v} = split{v} + value_min;
  end

end
