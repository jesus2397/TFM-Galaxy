#!/usr/bin/Rscript

pkgs <- c("ggplot2","dplyr","tidyr", "getopt","limma","tibble","phyloseq")
for (pkg in pkgs) suppressPackageStartupMessages(stopifnot(library(pkg, quietly = TRUE, logical.return = TRUE, character.only = TRUE)))

prepareData <- function(file){
  s1 <- read.delim2(file, sep = "\t", header = T, stringsAsFactors = F)
  s1 <- s1 %>% mutate_at( vars(12:15), as.numeric)
  return(s1)
}

condenseData <- function(data){
  s <- list()
  for(i in seq(1:length(data))){
    s[[i]] <- prepareData(data[i])
  }
  unionData <- bind_rows(s)
  unionData_mean <- unionData %>% select(1:7,9) %>% 
    group_by(Primer, Phylum, Class, Order, Family, Genus, Species) %>%
    summarise(Count = mean(Count))
  return(unionData_mean)
}
###########
condenseData <- function(data){
  s <- list()
  for(i in seq(1:length(data))){
    s[[i]] <- prepareData(data[i])
  }
  unionData <- bind_rows(s)
  unionData_mean <- unionData %>% select(1:7,9) %>% 
    group_by(Primer, Phylum, Class, Order, Family, Genus, Species) %>%
    summarise(Count = mean(Count))
  return(unionData_mean)
}
##############

#output <- commandArgs(trailingOnly=TRUE)[1]
inputs <- commandArgs(trailingOnly=TRUE)
# Separate multiple input files into a list of individual files
files <- unlist(strsplit(inputs, ','))

df_mean <- suppressMessages(condenseData(files))
df_mean <- df_mean %>% mutate_at(.vars = vars(Phylum:Species), .funs = gsub, pattern= "^ ", replacement="" )

write.table(df_mean[,c(8,1:7)], "df_mean.txt", quote = F, sep="\t", col.names = T, row.names = F)

y <- "ktImportText -n all -o df_mean.html df_mean.txt"
suppressMessages(system(y, ignore.stdout = T)) 
