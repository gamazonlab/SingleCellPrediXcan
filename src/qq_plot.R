library('ggplot2')

gwas  = read.table('data/CRP_st_Whole_Blood.csv', header=T, sep=",")

cgenes = read.table('data/community_genes.txt', header=F)

t = subset(gwas, gwas$gene_name %in% cgenes[,1])
nt  = subset(gwas, !gwas$gene_name %in% cgenes[,1])

# https://slowkow.com/notes/ggplot2-qqplot/
ps = t$pvalue
qs = nt$pvalue
ci = 0.95

n  <- length(ps)
df <- data.frame(
  observed = -log10(sort(ps)),
  expected = -log10(ppoints(n)),
  clower   = -log10(qbeta(p = (1 - ci) / 2, shape1 = 1:n, shape2 = n:1)),
  cupper   = -log10(qbeta(p = (1 + ci) / 2, shape1 = 1:n, shape2 = n:1))
)
log10Pe <- expression(paste("Expected -log"[10], plain(P)))
log10Po <- expression(paste("Observed -log"[10], plain(P)))


m  <- length(qs)
gf <- data.frame(
  observed = -log10(sort(qs)),
  expected = -log10(ppoints(m)),
  clower   = -log10(qbeta(p = (1 - ci) / 2, shape1 = 1:m, shape2 = m:1)),
  cupper   = -log10(qbeta(p = (1 + ci) / 2, shape1 = 1:m, shape2 = m:1))
)
#  log10Pe <- expression(paste("Expected -log"[10], plain(P)))
#  log10Po <- expression(paste("Observed -log"[10], plain(P)))



qqp =   ggplot(gf) +
  geom_ribbon(
    mapping = aes(x = expected, ymin = clower, ymax = cupper),
    alpha = 0.1
  ) +
  geom_point(data=df, aes(expected, observed), col="red", shape = 2, size = 2) + 
  geom_point(data=gf,  aes(expected, observed), col="blue", shape = 2, size = 2) + 
  geom_abline(intercept = 0, slope = 1, alpha = 0.5) +
  # geom_line(aes(expected, cupper), linetype = 2, size = 0.5) +
  # geom_line(aes(expected, clower), linetype = 2, size = 0.5) +
  xlab(log10Pe) +
  ylab(log10Po) +   theme_bw(base_size = 22) +
  theme(
    axis.ticks = element_line(size = 0.5),
    panel.grid = element_blank(), panel.border = element_blank(), 
    #     panel.grid = element_line(size = 0.5, color = "grey80"), 
    panel.background = element_blank()  ) +
  xlim(c(0,5)) + ylim(c(0,140))  + theme( axis.line = element_line(colour = "grey90", size = 2, linetype = "solid")) + labs(tag = expression(bold("A")))


# legend("top", legend = c("Communities", "Complement"), pch = 2, col = c("red", "blue"), cex=1.6)

#### Q-values

library(qvalue)
ps.qval = qvalue(ps)
qs.qval = qvalue(qs)
1-ps.qval$pi0
# [1] 0.4529955
1-qs.qval$pi0
# [1] 0.3735661