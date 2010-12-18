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

## convert quantitative data to discrete data given interval split points
discretize <- function(data, split)
{
  ninstances <- nrow(data);
  nvariables <- ncol(data);

  for(i in 1:ninstances){
    for(v in 1:nvariables){
      data[i, v] <- sum(data[i, v] > split[[v]]) + 1;
    }
  }

  return(data)
}

## discretize quantitative data using Z scores
discretize.z.scores <- function(data, threshold)
{
  nvariables <- ncol(data)

  split <- list()

  for(v in 1:nvariables){
    values <- data[, v]
    sigma <- sd(values)
    mu <- mean(values)
    
    ## divide the range of values into three intervals
    split[[v]] = c(-threshold, threshold) * sigma + mu
  }

  return(split)
}

## discretize quantitative data using equal width discretization
discretize.equal.width <- function(data, k)
{
  nvariables <- ncol(data)
  ninstances <- nrow(data)

  split <- list()

  for(v in 1:nvariables){
    values <- data[, v]
    value.min <- min(values)
    value.max <- max(values)

    ## interval width
    w <- (value.max - value.min) / k

    split[[v]] <- seq(1, k-1) * w + value.min
  }

  return(split)
}

## discretize quantitative data using equal frequency discretization
discretize.equal.freq <- function(data, k)
{
  nvariables <- ncol(data)
  
  split <- list()
  
  for(v in 1:nvariables){
    ## get unique values for current variable of the data set.
    ## assume that there are not many duplicates. thus the effect
    ## of producing the discretization without considering the
    ## duplicates is minimized.
    values <- data[, v]
    values <- unique(values)
    values <- sort(values)
    
    n <- length(values)
    
    ## interval frequency
    s <- floor(n / k);
    
    ## number of intervals that must accomodate an extra instance
    nextra <- n %% s;

    ## number of instances in each interval
    interval.size <- rep(s, times=k)
    if(nextra > 0){
      interval.size[1:nextra] <- interval.size[1:nextra] + 1;
    }
    
    ## compute quantitative split points as the midpoints between
    ## extreme values in adjacent intervals
    split.index <- 0
    split[[v]] <- rep(0, times=k-1)
    for(i in seq(1, k-1)){
      split.index <- split.index + interval.size[i];
      split[[v]][i] <- 0.5 * (values[split.index] + values[split.index+1]);
    }
  }
  
  return(split)
}

## discretize quantitative data using fixed frequency discretization
discretize.fixed.freq <- function(data, m)
{
  nvariables <- ncol(data)

  split <- list()

  for(v in 1:nvariables){
    ## get unique values for current variable of the data set.
    ## assume that there are not many duplicates. thus the effect
    ## of producing the discretization without considering the
    ## duplicates is minimized.
    values <- data[, v]
    values <- unique(values)
    values <- sort(values)
    
    n <- length(values)
    
    ## interval number
    t <- round(n / m)
    
    ## update interval frequency
    s <- floor(n / t)
    
    ## number of intervals that must accomodate an extra instance
    nextra <- n %% s

    ## number of instances in each interval
    interval.size <- rep(s, times=t)
    if(nextra > 0){
      interval.size[1:nextra] <- interval.size[1:nextra] + 1
    }
    
    ## compute quantitative split points as the midpoints between
    ## extreme values in adjacent intervals
    split.index <- 0
    split[[v]] <- rep(0, times=t-1)
    for(i in seq(1, t-1)){
      split.index <- split.index + interval.size[i]
      split[[v]][i] <- 0.5 * (values[split.index] + values[split.index+1])
    }
  }

  return(split)
}

## discretize quantitative data using proportional discretization
discretize.proportional <- function(data)
{
  nvariables <- ncol(data)
  
  split <- list()
  
  for(v in 1:nvariables){
    ## get unique values for current variable of the data set.
    ## assume that there are not many duplicates. thus the effect
    ## of producing the discretization without considering the
    ## duplicates is minimized.
    values <- data[, v]
    values <- unique(values)
    values <- sort(values)
    
    n <- length(values)
    
    ## interval number
    t <- sqrt(n)
    t <- floor(t)
    
    ## interval frequency
    s <- t

    ## number of intervals that must accomodate an extra instance
    nextra <- n %% s

    ## number of instances in each interval
    interval.size <- rep(s, times=t)
    interval.size[1:nextra] <- interval.size[1:nextra] + 1

    ## compute quantitative split points as the midpoints between
    ## extreme values in adjacent intervals
    split.index <- 0
    split[[v]] <- rep(0, times=t-1)
    for(i in seq(1, t-1)){
      split.index <- split.index + interval.size[i]
      split[[v]][i] <- 0.5 * (values[split.index] + values[split.index+1])
    }
  }

  return(split)
}
