#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
library(rmarkdown)
library(knitr)

eng_text <- function(options) {
	engine_output(options, code = options$code, out = "")
}

knit_engines$set(text = eng_text)
render(args[1], output_format = "all")
