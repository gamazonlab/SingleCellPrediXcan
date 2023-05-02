# This script further specifically does the GC for the schizophrenia associated genes using FPP30 cell models.
# load library
library(data.table)
library(foreach)
library(doParallel)
library(tidyverse)
library(broom)

# read in the GReX files 
fpp11 <- fread("/data/g_***/FPP11_eur.csv", h=T)
fpp30 <- fread("/data/g_***/FPP30_eur.csv", h=T)

# chage to data frames
fpp11 <- as.data.frame(fpp11)
fpp30 <- as.data.frame(fpp30)

# relabel rownames
row.names(fpp11) <- fpp11$FID
row.names(fpp30) <- fpp30$FID

# remove first three columns
fpp11 <- fpp11[,-c(1,2,3)]
fpp30 <- fpp30[,-c(1,2,3)]

# find shared genes b/n two datasets
shared <- intersect(names(fpp11), names(fpp30))
fpp11s <- fpp11[,shared]
fpp30s <- fpp30[,shared]

# calculate granger's causality as a bivariate regression 

# step 1 - write a function that calculates multiple regression 
tf <- t(fpp11)
f <- function(inputg){
  perfor <- as.data.frame(tf[,1:3])
  perfor$genes <- names(fpp11)
  for (i in 1:length(names(fpp11))) {
    model <- lm(fpp30s[,inputg] ~ as.matrix(fpp11[,i]) + fpp11[,inputg])
    jj <-  summary(model)
    other_gene_coef <- jj$coefficients[2]
    previous_inputg_coef <- jj$coefficients[3]
    perfor[i,"gene2__t1_coef"] <- other_gene_coef
    perfor[i, "gene1_t1_coef"]  <- previous_inputg_coef
    y <-fpp30s[,inputg]
    x <- fpp11[,i]
    z <- fpp11s[,inputg]
    perfor[i, "gene2_t1_beta"] <-  other_gene_coef*(sd(x)/sd(y)) # standardizing the coefficient
    perfor[i, "gene1_t1_beta"] <-  previous_inputg_coef*(sd(x)/sd(z)) 
    perfor[i,"gene1_day11"] <- perfor[i,"genes"]
    perfor[i,"gene2_day30"] <- inputg
    perfor[i,"F-stat"] <- jj$fstatistic[1]
    g <- glance(model)
    perfor[i, "F-stat_pval"] <- g$p.value
  }
  perfor = perfor[,-c(1,2,3,4)]
  na.omit(perfor)
}

# read in the scz_twas at the day 30 
scz <- fread("/data/g_***/PGC3_SCZ_cell_type/FPP30_assn.csv", h=T)
s <- subset(scz, scz$pvalue <= 3.511236e-05)
sub <- intersect(s$gene, names(fpp30s))

# apply to all genes
genes <- sub
genes <- as.list(genes)
t <- lapply(genes, f)
lml<- plyr::ldply(t, rbind)
lml2 <- as.matrix(lml)
write.csv(lml2, "./bi_var_da30_52.csv", row.names=F, quote=F)
