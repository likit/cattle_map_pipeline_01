source("http://bioconductor.org/biocLite.R")
biocLite("org.Bt.eg.db")

library('edgeR')
# Load raw data
cat("Loading count data..\n")
counts <- read.table('all_cdna_raw_reads_gene_count.txt',
                     sep='\t', header=T, row.names=1)
counts <- counts[, c(3,2,5,4,1,7,6,9,8,11,10)]
y <- DGEList(counts=counts,genes=rownames(counts))

# Low abundance filtering
cat("Filtering low abundance reads...\n")
keep <- rowSums(cpm(y)>1) >= 5
y.filtered <- y[keep, ]
y.filtered$samples$lib.size <- colSums(y.filtered$counts)

# Build design matrix
disease <- factor(rep(c("Nil", "Nil", "Nil", "Nil", "Nil",
                        "Pos", "Pos", "Pos", "Pos", "Pos", "Pos")),
                      levels=c("Nil", "Pos"))
treat <- factor(c(rep(c("No", "Yes"), times=2), c("Yes"),
                  rep(c("No", "Yes"), times=3)), levels=c("No", "Yes"))
subject <- factor(c(1,1,2,2,3,1,1,2,2,3,3))
design <- model.matrix(~disease+disease:subject+disease:treat)

# Estimate Dispersion
y.filtered <- calcNormFactors(y.filtered)
cat("Estimating Common dispersion...\n")
y.filtered <- estimateGLMCommonDisp(y.filtered, design, verbose=T)
cat("Estimating Trended dispersion...\n")
y.filtered <- estimateGLMTrendedDisp(y.filtered,design)
cat("Estimating Tagwise dispersion...\n")
y.filtered <- estimateGLMTagwiseDisp(y.filtered,design)

# Plot BCV
#plotBCV(y.filtered)

# Differential expression analysis
cat("Fitting...\n")
fit <- glmFit(y.filtered, design)
lrt <- glmLRT(fit, coef=2) # diseasePos
lrt$table$Padjust<- p.adjust(lrt$table$PValue[lrt$table$logFC!=0],
                             method="BH")
lrt.sig <- lrt[lrt$table$Padjust<.05,]
write.table(lrt.sig$table, 'diseasePos-degenes.txt',
            sep="\t", quote=F, col.names=T, row.names=T)

#o <- order(lrt$table$PValue)
#cpm(y.filtered)[o[1:10],]
cat("Plotting...\n")
summary(de <- decideTestsDGE(lrt))
detags <- rownames(y.filtered)[as.logical(de)]
plotSmear(lrt, de.tags=detags)
abline(h=c(-1, 1), col="blue")

# Export data to GOseq
cat("Preparing data for goseq...\n")
genes=as.integer(p.adjust(lrt$table$PValue[lrt$table$logFC!=0], method="BH")<.05)
names(genes) = row.names(lrt$table[lrt$table$logFC!=0,])

# GOSeq
library(goseq)
cat("Calculating PWF...\n")
pwf=nullp(genes, "bosTau6", "ensGene")
go.wall=goseq(pwf,"bosTau6","ensGene")
library(reshape2)

library('org.Bt.eg.db')
library(KEGG.db)
# en2eg=as.list(org.Bt.egENSEMBL2EG)
# eg2kegg=as.list(org.Bt.egPATH)
# kegg=lapply(en2eg,grepKEGG,eg2kegg)
# KEGG=goseq(pwf,gene2cat=kegg)
# grepKEGG=function(id,mapkeys){unique(unlist(mapkeys[id],use.names=FALSE))}

KEGG=goseq(pwf,'bosTau6','ensGene',test.cats="KEGG")
KEGG$padjust = p.adjust(KEGG$over_represented_pvalue, method="BH")
KEGG_SIG = KEGG[KEGG$padjust<0.05,]

# Cleaveland plot
# KEGG_SIG$log10padjust=(-1)*log10(KEGG_SIG$padjust)
# nameorder = KEGG_SIG$pathway[sort.list(KEGG_SIG$log10padjust, decreasing=F)]
# KEGG_SIG$pathway = factor(KEGG_SIG$pathway, levels=nameorder)
# xx = as.list(org.Bt.egPATH2EG) # Use Ensemble instead of Entrez
# xx = xx[!is.na(xx)] # remove KEGG IDs that do not match any gene
# degenes = genes[genes>0]
# 
# get_genes_kegg = function(cat, degenes, prefix)
# {
#     m = match(xx[[cat]], degenes$ensembl_id)
#     mm = m[!is.na(m)]
#     d = data.frame(cat, names(degenes[mm]))
#     filename = paste(prefix, cat, sep="_")
#     write.table(d, filename, sep="\t", row.names=F, col.names=F, quote=F)
#     return(d)
# }
# df = lapply(KEGG_SIG$category, get_genes_kegg, degenes,
#             "diseasePos")
# KEGG_SIG$ngenes = sapply(df, nrow)
# 
# ggplot(KEGG_SIG, aes(x=pathway, y=log10padjust, size=ngenes)) +
#     geom_point(colour="grey30") +
#     theme_bw() +
#     theme(panel.grid.major.y = element_blank(),
#         panel.grid.minor.y=element_blank(),
#         panel.grid.major.x=element_line(colour="grey60",
#         linetype="dashed"), axis.text.x=element_text(angle=45, hjust=1)) +
#     scale_size_area(max_size=14) +
#     labs(list(title="Line 6 vs 7 Post Infection", y="log10(adjusted p-value)"))
