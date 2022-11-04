catf <-
  function(x) {
    f <- 
    function(x) {
      f <- 
  function(x) {
    f <- 
  function(x) {
    f <- \(x) x
    g <- \(x) x
    list(f(x), g(x))
  }
    g <- 
  function(x) {
    f <- 
    function(x) {
      g <- 
  function(x) {
    f <- function(x) { t(x) }
    g <- 
  function(x) {
    f <- \(x) x
    g <- \(x) x
    list(f(x), g(x))
  }
    g(f(x)) 
  }
      x[[2]] <- g(x[[2]])
      x
    }
    
    g <- 
  function(x) {
    f <- 
  function(x) {
    f <- 
  function(x) {
    f <- 
  function(x) {
    f <- \(x) x[[2]]
    g <- \(x) x[[1]]
    g(f(x)) 
  }
    g <- \(x) x[[1]]
    list(f(x), g(x))
  }
    g <- 
  function(x) {
    f <- \(x) x[[2]]
    g <- \(x) x[[1]]
    g(f(x)) 
  }
    list(f(x), g(x))
  }
    g <- 
  function(x) {
    f <- 
    function(x) {
      f <- 
  function(x) {
    f <- function(x) { x[[1]] %*% x[[2]] }
    g <- function(x) { solve(x) }
    g(f(x)) 
  }
      x[[1]] <- f(x[[1]])
      x
    }
    
    g <- function(x) { x[[1]] %*% x[[2]] }
    g(f(x)) 
  }
    g(f(x)) 
  }
    g(f(x)) 
  }
    g(f(x)) 
  }
      x[[1]] <- f(x[[1]])
      x
    }
    
    g <- function(x) { x[[1]] %*% x[[2]] }
    g(f(x)) 
  }

X <- matrix(rnorm(100), ncol = 2)
Y <- rnorm(50)

catf(list(X, Y))
lm(Y ~ -1 + X)
