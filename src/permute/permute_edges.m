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
## @deftypefn{Function File} {[@var{data}, @var{classes}, @var{graph}] =} permute_edges(@var{data}, @var{classes}, @var{graph})
## Permute edges.
##
## Randomly permute the edges in the graph structure @var{graph}.  This
## is equivalent to generating a random graph with the same number of
## nodes and the same number of edges where each edge is given uniform
## probability of inclusion.  The instances in the @var{n} by @var{p}
## matrix @var{data} and the corresponding class labels in the @var{n}
## by 1 vector @var{classes} are unchanged.
##
## @seealso{permutations}
## @end deftypefn

function [data classes graph] = permute_edges(data, classes, graph)

  ## generate a random graph with the same size as the original
  nnodes = graph.num_nodes;
  nedges = graph.num_edges;
  graph = graph_random(nnodes, nedges);

end
