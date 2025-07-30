# ~/~ begin <<md/paper.md#runs/extract_insolation.R>>[init]
#| file: runs/extract_insolation.R

if (!require("palinsol")) {
    install.packages("palinsol", repos = "https://cran.r-project.org")
}

library(palinsol)
time_start <- 5e5  
time_end <- 0      
time_step <- 2e2  
times <- seq(time_end, time_start, time_step)
param_la04 = t(sapply(times, function(t) astro(t, solution = la04, degree = TRUE)))
orbit <- list()
insolation <- list()
lat_degree = 25

for (t in 1:length(times)) {
  orbit[[t]] <- list(
    eps = param_la04[t,1] * pi / 180, 
    ecc = param_la04[t,2], 
    varpi = (param_la04[t,3] - 180) * pi / 180
  )
  
  insolation[[t]] <- Insol(
    orbit[[t]], 
    long = pi / 2, 
    lat = lat_degree * pi / 180, 
    S0 = 1361, 
    H = NULL
  )
}

insolation = inso_values <- unlist(insolation)
# ~/~ end
