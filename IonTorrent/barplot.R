#!/usr/bin/Rscript

pkgs <- c("ggplot2","dplyr","tidyr", "getopt","limma","tibble","phyloseq")
for (pkg in pkgs) suppressPackageStartupMessages(stopifnot(library(pkg, quietly = TRUE, logical.return = TRUE, character.only = TRUE)))

options = matrix(c("otuphylfile","o",2,"character"), byrow = TRUE, ncol = 4)
args=getopt(options)

if (length(args)==0) {
  stop("Two files must be supplied (Otu file, metadata files)", call.=FALSE)
}


load(args$otuphylfile)

p <-suppressMessages( psmelt(otuphylNorm) %>%
  group_by(OTU, group) %>%
  summarise(Abundance = mean(Abundance)))
p$Abundance <- p$Abundance*100
p <- suppressMessages(p %>% mutate(menor01 = ifelse(Abundance<1, 1, 0)) %>%
  mutate(newOTU = ifelse(menor01 == 1, "ETC<1%", OTU) ) %>%
  group_by(newOTU, group) %>% summarise(Abundance2 = sum(Abundance)))
names(p) <- c("OTU","group","Abundance")


colores <- c('#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf')
colorRamps <- scales::colour_ramp(colores)
coloresRamp <- colorRamps(seq(0,1,length=length(unique(p$OTU)) ))
#scales::show_col(coloresRamp)

p <- p %>% ggplot(aes_string(x = "group", y="Abundance", fill="OTU")) +
  geom_bar(stat = "identity", position = "stack",
           color = "black", show.legend = T, width = 0.5, size=0.01 ) +
  scale_fill_manual(values= coloresRamp ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 0),
        legend.position = "right",
        text = element_text(size=15),
        legend.key.size = unit(0.5, "cm") )+
  #scale_y_continuous(trans = "log2")+
  ylab("Abundance (%)")+
  guides(fill = guide_legend(ncol=1))

png(filename = "barplot.png", width = 1200, height = 900)
print(p)