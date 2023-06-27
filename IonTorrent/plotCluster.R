#!/usr/bin/Rscript

pkgs <- c("ggplot2","dplyr","tidyr", "getopt","limma","tibble","ape")
for (pkg in pkgs) suppressPackageStartupMessages(stopifnot(library(pkg, quietly = TRUE, logical.return = TRUE, character.only = TRUE)))

### main ####
options = matrix(c("inputfile","f",2,"character"), byrow = TRUE, ncol = 4)
args=getopt(options)

if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

load(args$inputfile)

# dendrograma
otudist <- dist(t(otu))
otuclust <- hclust(otudist, method = "ward.D2")
png(filename = "ClustPlotOtu.png", width = 1200, height = 900)
suppressWarnings(
  plot.phylo( as.phylo(otuclust), cex=0.9, 
            tip.color =  as.numeric(as.factor(metadata$condition) ) )
)
