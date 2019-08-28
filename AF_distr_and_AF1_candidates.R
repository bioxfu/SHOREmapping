options(stringsAsFactors = F)
gene_anno <- read.table('script/tair10_gene_anno.tsv', sep='\t', quote='', header = T)

argv <- commandArgs(T)
#input <- 'OC_fg_8_15_rm_parent.tsv'
input <- argv[1]
output <- sub('\\..+', '', input)

snp <- read.table(input, sep = '\t')
snp[is.na(snp)] <- ''
colnames(snp) <- c('chromosome', 
                   'position',
                   'ref_base',
                   'mut_base',
                   'num_reads',
                   'AF',
                   'base_quality',
                   'region',
                   'transcript',
                   'mut_codon_order',
                   'mut_site_in_codon',
                   'nonSynonymous',
                   'ref_aa',
                   'mut_aa')
snp$gene <- sub('\\..+', '', snp$transcript)
snp <- merge(snp, gene_anno, by.x = 15, by.y = 1, all.x = T)
snp[is.na(snp)] <- ''

snp <- snp[snp$base_quality>=30 & snp$num_reads>=2,]

pdf(paste0(output, '_AF_distribution.pdf'), wid=5, hei=8)
par(mfrow=c(3,2))
plot(snp$position[snp$chromosome==1], snp$AF[snp$chromosome==1], xlab = 'Position (Mb)', ylab = 'AF', xaxt='n', main = 'Chr1', cex=0.2)
axis(1, at=seq(0,30000000, 5000000), lab=seq(0,30, 5))
plot(snp$position[snp$chromosome==2], snp$AF[snp$chromosome==2], xlab = 'Position (Mb)', ylab = 'AF', xaxt='n', main = 'Chr2', cex=0.2)
axis(1, at=seq(0,30000000, 5000000), lab=seq(0,30, 5))
plot(snp$position[snp$chromosome==3], snp$AF[snp$chromosome==3], xlab = 'Position (Mb)', ylab = 'AF', xaxt='n', main = 'Chr3', cex=0.2)
axis(1, at=seq(0,30000000, 5000000), lab=seq(0,30, 5))
plot(snp$position[snp$chromosome==4], snp$AF[snp$chromosome==4], xlab = 'Position (Mb)', ylab = 'AF', xaxt='n', main = 'Chr4', cex=0.2)
axis(1, at=seq(0,30000000, 5000000), lab=seq(0,30, 5))
plot(snp$position[snp$chromosome==5], snp$AF[snp$chromosome==5], xlab = 'Position (Mb)', ylab = 'AF', xaxt='n', main = 'Chr5', cex=0.2)
axis(1, at=seq(0,30000000, 5000000), lab=seq(0,30, 5))
dev.off()

candidates <- snp[snp$AF >= 0.9, -1]
candidates <- candidates[order(candidates$chromosome, candidates$position),]
write.table(candidates, paste0(output, '_AF0.9_candidates.tsv'), row.names = F, quote = F, sep='\t')
