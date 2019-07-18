#! /usr/bin/Rscript

##Set WD & Environment
setwd("~/DaphniaGenomics19/GenomeOrg/ReferenceGenome/")
library(ggplot2)

##Load Data
tdepth <- read.table("chr.12.depthfin", header = TRUE)

##Plotting points of coverage. Required offseting presence values for other assemblies and relabeling
p <- ggplot()+
  geom_point(data = tdepth[which(tdepth$PA42>0),], aes(x = Pos, y = PA42), color = "cyan") +
  geom_point(data = tdepth[which(tdepth$BA411>0),], aes(x = Pos, y = BA411), color = "pink") +
  geom_point(data = tdepth[which(tdepth$WI6>0),], aes(x = Pos, y = WI6), color = "green") +
  scale_y_continuous("Assembly", breaks = seq(0.6,1,0.2), labels = c("0.6"="WI6", "0.8"="BA411", "1"="PA42"))+
  scale_x_continuous("Position (Kbp)", breaks = seq(min(tdepth$Pos),max(tdepth$Pos), 200000))
p <- p + theme_bw()
##exporting as png
ggsave("chr.12.plot.png", plot = p, device = "png")
