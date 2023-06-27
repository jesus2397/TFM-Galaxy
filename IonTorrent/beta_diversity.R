#!/usr/bin/Rscript

pkgs <- c("ggplot2","dplyr","tidyr", "getopt","limma","tibble","phyloseq","vegan")
for (pkg in pkgs) suppressPackageStartupMessages(stopifnot(library(pkg, quietly = TRUE, logical.return = TRUE, character.only = TRUE)))

options = matrix(c("otuphylfile","o",2,"character","metadata","m",2,"character"), byrow = TRUE, ncol = 4)
args=getopt(options)

if (length(args)==0) {
  stop("Two files must be supplied (Otu file, metadata files)", call.=FALSE)
}


load(args$otuphylfile)
metadata <- read.table(args$metadata, header = T , sep="\t")

otug <- otuphyl
otugTable <- otu_table(otug)
otugTable <- otugTable[rowSums(otugTable==0) <=100,]

distancia <- vegdist(t(otugTable ), method = "bray", binary = TRUE)
beta <- betadiver(t(otugTable), "z")

mds <- metaMDS(distancia, k = 2)
mdspoints <- as.data.frame(mds$points) %>% rownames_to_column(var = "Sample")
mdspoints <- left_join(mdspoints,metadata, by = c("Sample"="samples"))

mdspoints <- mdspoints %>% ggplot(aes(x=MDS1, y=MDS2, color=condition))+
  geom_point( size = 3)+
  geom_hline(yintercept = 0, colour= "gray50", linetype = "dashed")+
  geom_vline(xintercept = 0, colour= "gray50", linetype = "dashed")+
  theme_bw()

png(filename = "beta_diversity.png", width = 1200, height = 900)
print(mdspoints)

