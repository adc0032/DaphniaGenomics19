setwd(/home/bkh0024/DaphniaGenomics19/GenomeOrg/ReferenceGenome/ChromosomeOrg/IndividualChrFiles/coverage_map_data_Jul_12)

library(ggplot2)
num <- c(1,2,3,4,5,6,7,8,9,10,11,12)
for (val in num) {
  dat=read.delim("Cov_Chr_[val].txt")
  ggplot(dat, aes(x=dat, y=nrow(dat))) + geom_point() 
}
