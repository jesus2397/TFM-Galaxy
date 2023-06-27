#!/usr/bin/Rscript

pkgs <- c("tidyverse","getopt","limma")
for (pkg in pkgs) suppressPackageStartupMessages(stopifnot(library(pkg, quietly = TRUE, logical.return = TRUE, character.only = TRUE)))

##normalizar otu
normOtu <- function(otu,metadata){
  norm <- apply(otu, 2, sum)
  norm <- diag(1/norm)
  otuNorm <- as.matrix(otu) %*% norm
  attr(otuNorm,"dimnames")[[2]] <- as.character(metadata$samples)
  return(otuNorm)
}

### main ####
options = matrix(c("otufile","o",2,"character","metadata","m",2,"character"), byrow = TRUE, ncol = 4)
args=getopt(options)
  
if (length(args)<2) {
  stop("Two files must be supplied (Otu file, metadata files)", call.=FALSE)
}

otu <- as.matrix(read.delim(args$otufile, row.names=1))
otu <- as.data.frame(otu)
metadata <- read.delim(args$metadata, row.names = NULL)
otuNorm <- normOtu(otu, metadata)

if( !all(metadata$samples %in% names(otu) )){
  stop("Samples in metadata are not consistent with samples in otu table")
}else{
  fileOut <- paste0( gsub("\\.txt","", args$otufile), ".rdata"  )
  save(otu,metadata,otuNorm, file="data.RData") }

