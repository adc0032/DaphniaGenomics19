#!/usr/bin/env Rscript

#############################################################################################################################################
#############################################################################################################################################
#############################################################################################################################################
#Author:Stephen A. Sefick
#This is an R script to calculate some different statistics related to depth and quality of vcf_files.
#Of course, this is not very specific and can be ported easily to other applications.

#This is not the most efficient script...; however, the R part is not the inefficient part
#the cat part is the inefficient part
#note tested with small fruitfly genome; your results may vary

#typical use case:
#vcftools --site-depth --vcf your.vcf --out site_depth
#vcftools --site-quality --vcf your.vcf --out site_quality

#outputs site_depth.ldepth and site_quality.lqual
#then pipe this output to the script

#cat site_quality.lqual | vcf_cutoff_stats.R > vcf_quality_summary.txt
#cat site_depth.ldepth | vcf_cutoff_stats.R > vcf_depth_summary.txt


#############################################################################################################################################
#############################################################################################################################################
#############################################################################################################################################


#read input from standard in
f <- readLines(file("stdin"))

#make table
f <- read.table(textConnection(f), header=TRUE)

#only want the numberical data
a <- f[,3]

#free up some memory
rm(f)

#collect results
out <- data.frame(mean=mean(a), sd=sd(a), median=median(a), quantile=as.numeric(quantile(a, probs=c(0.25))), min=min(a), max=max(a))

#write to stdout
out
