
#!/usr/bin/Rscript

pkgs <- c("ggplot2","dplyr","tidyr", "getopt","limma","tibble","phyloseq")
for (pkg in pkgs) suppressPackageStartupMessages(stopifnot(library(pkg, quietly = TRUE, logical.return = TRUE, character.only = TRUE)))

options = matrix(c("otuphylfile","o",2,"character","metadata","m",2,"character"), byrow = TRUE, ncol = 4)
args=getopt(options)

if (length(args)==0) {
  stop("Two files must be supplied (Otu file, metadata files)", call.=FALSE)
}

load(args$otuphylfile)
metadata <- read.table(args$metadata, header = T , sep="\t")
otug <- otuphyl

# sampleg_df <- data.frame( group=factor(c(0,1) ))
# rownames(sampleg_df) <- c("mean0", "mean1")

otugTable <- otu_table(otug)
otugTable <- otugTable[rowSums(otugTable==0) <=100,]

alphas <- suppressWarnings( suppressMessages(estimate_richness( otu_table(otugTable), measures = c("Chao1","Shannon","InvSimpson") )))
alphas <- alphas %>%
  rownames_to_column(var = "Sample")

alphas <- alphas %>% select(-se.chao1) %>% pivot_longer(cols = c(Chao1,Shannon,InvSimpson)) %>% arrange(name,Sample)

alphas <- left_join(alphas, metadata, by = c("Sample"="samples"))






ttestchao <- aov(value~condition, data = alphas[alphas$name=="Chao1",])
cat("Alpha diversity Chao1")
summary(ttestchao)
ttestInvSimpson <- aov(value~condition, data = alphas[alphas$name=="InvSimpson",])
cat("Alpha diversity InvSimpson")
summary(ttestInvSimpson)
ttestshannon <- aov(value~condition, data = alphas[alphas$name=="Shannon",])
cat("Alpha diversity Shannon")
summary(ttestshannon)

