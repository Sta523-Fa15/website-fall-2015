#!/usr/bin/env Rscript

library(knitr)
library(rmarkdown)

args = commandArgs(trailingOnly = TRUE)

input = args[1]
output= args[2]

name = sub(".Rmd$", "", basename(input))
output_dir = paste0(dirname(output),"/")

render(input,
       output_format = html_fragment(),
       output_dir = paste0(output_dir),
       clean = TRUE, quiet = TRUE)


# If front matter exists copy to the new fragment
yaml = rmarkdown:::partition_yaml_front_matter(readLines(input, warn = FALSE))
if (!is.null(yaml$front_matter))
{
    lines = c(yaml$front_matter, "", readLines(output, warn = FALSE))
    writeLines(lines, output, useBytes = TRUE)
}

yaml_vals = rmarkdown:::parse_yaml_front_matter(readLines(input, warn = FALSE))
if (!is.null(yaml_vals$slides))
{
    if (yaml_vals$slides == TRUE)
    {
        render(input,
           #output_dir = "./", #"../slides/",
           output_dir = "slides/",
           clean = TRUE, quiet = TRUE)

        #html = paste0(name,".html")
        #x = file.rename(paste0("_knitr/",html), paste0("slides/",html))
    }
}