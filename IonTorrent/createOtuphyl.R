#!/usr/bin/Rscript


options(warn = -1)

pkgs <- c("tidyverse","getopt","phyloseq","gtools","DESeq2")
for (pkg in pkgs) suppressPackageStartupMessages(stopifnot(library(pkg, quietly = TRUE, logical.return = TRUE, character.only = TRUE)))

### main ####
options = matrix(c("rdatafile","r",2,"character",
                   "pvalcutoff","p",2,"character"), byrow = TRUE, ncol = 4)
args=getopt(options)

if (length(args)<2) {
  stop("Rdata files must be supplied", call.=FALSE)
}

load(args$rdatafile)

metadata<- metadata %>% mutate_if(is.factor, as.character)

samplesdf <- data.frame(group = metadata$condition)
rownames(samplesdf) <- metadata$samples

# convertir a phyloseq object
otuphyl <- phyloseq(otu_table(otu, taxa_are_rows = TRUE ), sample_data( samplesdf) )
otuphylNorm <- phyloseq(otu_table(otuNorm, taxa_are_rows = TRUE ), sample_data( samplesdf) )

#convertir a deseq2 con los tratamientos que se quiera
# convertir a deseq type
diagdds12Type = suppressMessages( phyloseq_to_deseq2(otuphyl, ~ group) )
gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
#estimar SizeFactor Edad
geoMeansType = apply(counts(diagdds12Type), 1, gm_mean)
diagdds12Type = estimateSizeFactors(diagdds12Type, geoMeans = geoMeansType)

## Calcular abundancia diferencial
diagdds12Type = DESeq(diagdds12Type, fitType="local", quiet = TRUE)
combinaciones <- combinations( 
  length(unique(metadata$condition)),
  2,
  unique(metadata$condition)  ) %>% as.data.frame()
combinaciones <- cbind("group",combinaciones)

combinaciones <- combinaciones %>% mutate_if(is.factor, as.character)
resType <- list()
for(i in seq_len(dim(combinaciones)[1]) ){
  resType[[i]] = as.data.frame(results( diagdds12Type, contrast = unlist(combinaciones[i,]) ))
  resType[[i]] <- resType[[i]] %>% rownames_to_column("taxa")
  tmp <- resType[[i]] %>% filter(pvalue <= args$pvalcutoff)
  if(dim(tmp)[1]!=0){
    resType[[i]] <- tmp
    resType[[i]]$contraste <- paste(combinaciones[i, 2:3], collapse = "_")
  }else{
    resType[[i]] <- NULL
  }
}
nulos <- which(resType %in% list(NULL))
if(length(nulos)!=0){resType <- resType[-nulos]}
resType <- plyr::ldply(resType,rbind)

save(otuphyl,otuphylNorm, file="otuphyl.Rdata")
save(resType, file="DEresults.Rdata")







