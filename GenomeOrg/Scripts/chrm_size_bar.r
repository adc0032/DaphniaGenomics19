####Chromsome Size Schematic####
###Created: 6/26/19; By: Amanda D. Clark###
###Modified: ###


##Set WD & Environment
setwd("~/Desktop/PA42_Genome/")
library(ggplot2)

##read in file and restructure for plotting
dat <- read.csv("our_chr_size_srt.csv")
dat #run to make sure tbl imported correctly with headers and columns (2) =dataframe of scaffold ids and lengths
class(dat)
dat$chromosome <- factor(dat$chromosome, levels = (factor(dat$chromosome)))


##plots
#base plot with data
plot(dat$chr_size~dat$chromosome)

#barplot with data
barplot(dat$chr_size, beside=TRUE, ylim=range(pretty(c(0, dat$chr_size))), names.arg = c("chr_10", "chr_7", "chr_2", "chr_8", "chr_3", "chr_9", "chr_5", "chr_12",
                                                                                         "chr_1", "chr_6", "chr_4", "chr_11"))
#ggplot2 with data