#!/usr/bin/env Rscript
 
library(knitr)
library(rmarkdown)

args = commandArgs(trailingOnly = TRUE)

input = args[1]
output= args[2]

name = sub(".Rmd$", "", basename(input))
output_dir = paste0(dirname(output),"/")

render(input, 
       output_format = html_document(),
       output_dir = paste0(output_dir),
       clean = TRUE, quiet = TRUE)
