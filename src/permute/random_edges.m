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
## @deftypefn{Function File} {[@var{data}, @var{classes}, @var{graph}] =} random_edges(@var{data}, @var{classes}, @var{graph})
## Generate random edges.
##
## Randomly generate edges for the graph structure @var{graph}.  This
## is equivalent to generating a random graph with the same number of
## nodes but a uniformly random number of edges.  For a fixed number of
## edges, each edge is included with equal probability.  The instances
## in the @var{n} by @var{p} matrix @var{data} and the corresponding
## class labels in the @var{n} by 1 vector @var{classes} are unchanged.
##
## Bugs: It might be useful to specify the number of edges to use either
## as a fixed number or a percentage of the original number.
##
## @seealso{permutations}
## @end deftypefn

function [data classes graph] = random_edges(data, classes, graph)

  ## generate a random graph with the same number of nodes as the original
  ## but any possible number of edges randomly selected (uniform)
  nnodes = graph.num_nodes;
  nedges = round(rand() + nchoosek(nnodes, 2));
  graph = graph_random(nnodes, nedges);

end
