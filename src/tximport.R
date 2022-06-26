# R begins here
source('https://bioconductor.org/biocLite.R')
biocLite('tximport')
install.packages('readr')

library(tximport)
library(readr)

#The RNAseq data from HipSci is a transcript abundance data format  but we have to aggregate the transcript level counts to gene-level counts for our downstream analysis. 
#Inorder to do this, we use tximport . More info about "tximport package"  can be found here: https://bioconductor.org/packages/3.7/bioc/vignettes/tximport/inst/doc/tximport.html#use-with-downstream-bioconductor-dge-packages


setwd('~/Downloads/hipsci')
my.files <- list.files(recursive=T, pattern = '.tsv')


#tx2gene is an annotation file 
tx2gene <- read.table('~/Downloads/hipsci/tx2gene.txt', header = T)

txi <- tximport(my.files, type = "kallisto", tx2gene = tx2gene, txOut = FALSE, countsFromAbundance = "lengthScaledTPM"))
counts <- as.data.frame(txi$counts)

write.table(counts, 'txiCounts.txt', qu = F, row = T, sep = '\t')
