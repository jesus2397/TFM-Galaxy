#!/usr/bin/Rscript


options(warn = -1)

pkgs <- c("tidyverse","getopt","phyloseq","gtools","DESeq2")
for (pkg in pkgs) suppressPackageStartupMessages(stopifnot(library(pkg, quietly = TRUE, logical.return = TRUE, character.only = TRUE)))

### main ####
options = matrix(c("rdatafile","r",2,"character"), byrow = TRUE, ncol = 4)
args=getopt(options)

if (length(args)<2) {
  stop("Rdata files must be supplied", call.=FALSE)
}

load(args$rdatafile)

# resType %>%
#   mutate(across(baseMean:padj,round,3 ) ) %>% 
#   DT::datatable( rownames = F, caption = "Tabla resultados por grupos de severidad")
write.table(resType,"taxade.txt", sep="\t", row.names=FALSE, col.names=TRUE, quote=FALSE )
