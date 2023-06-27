#!/usr/bin/Rscript

pkgs <- c("ggplot2","dplyr","tidyr", "getopt","limma","tibble")
for (pkg in pkgs) suppressPackageStartupMessages(stopifnot(library(pkg, quietly = TRUE, logical.return = TRUE, character.only = TRUE)))

### main ####
options = matrix(c("inputfile","f",2,"character","inputnumber","o",2,"character"), byrow = TRUE, ncol = 4)
args=getopt(options)

if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

load(args$inputfile)

ntaxa <- as.numeric(args$inputnumber)

if( is.null(ntaxa) ){ ntaxa <- dim(otu)[1] }
if( ntaxa>dim(otu)[1] ){ ntaxa <- dim(otu)[1] }

conditions <- unique( metadata$condition )
numcond <- length( conditions )
samplesCond <- list()
rowOtu <- rownames(otu)

for(i in seq_len(numcond) ){
  samplesCond[[conditions[i]]] <- metadata$samples[metadata$condition==conditions[i]]
  otu <- otu %>% rowwise %>%
    mutate( "mean_{conditions[i]}" := mean(c_across(samplesCond[[i]]))  )
}
otu$rownames <- rowOtu
otu <- otu %>% rowwise %>%
  mutate(sumMedias = sum(c_across(starts_with("mean")) )) %>%
  arrange(-sumMedias) %>% select(-starts_with("mean_"), -sumMedias )
otu <- otu %>% column_to_rownames(var = "rownames")
otu <- otu[1:ntaxa,]


# ver datos en boxplot
otu <- otu %>% rownames_to_column(var="taxa")
otulong <- otu  %>% 
  pivot_longer(cols = !starts_with("taxa"), names_to = "sample", values_to = "abundance")
otulong <- left_join(otulong, metadata, by = c("sample"="samples"))
p <- otulong %>% ggplot(aes(x=taxa, y=abundance,
                       fill = as.factor(condition),
                       color=as.factor(condition))) +
  geom_boxplot(alpha=0.4, width=0.5, position = position_dodge(width = 0.65))+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        text = element_text(size=16))+
  scale_y_continuous(trans = "log10")+
  ylab("Abundance (log10)")+
  labs(color ="condition", fill = "condition" )

png(filename = "boxplotOtu.png", width = 1200, height = 900)
suppressWarnings(print(p))
#dev.off()

