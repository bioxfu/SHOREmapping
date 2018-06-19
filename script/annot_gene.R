options(stringsAsFactors = F)
gene_anno <- read.table('/home/xfu/Gmatic5/genome/tair10/tair10_gene_anno.tsv', sep='\t', quote='', header = T)

argv <- commandArgs(T)
input <- argv[1]
output <- argv[2]
output2 <- argv[3]

snp <- read.table(input, sep='\t')
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
snp_anno <- merge(snp, gene_anno, by.x = 15, by.y = 1, all.x = T)
snp_anno[is.na(snp_anno)] <- ''

#snp_anno_filt <- snp_anno[snp_anno$num_reads>=10 & snp_anno$nonSynonymous=="Nonsyn" & snp_anno$region=='CDS' & snp_anno$AF==1, ]
snp_anno_filt <- snp_anno[snp_anno$nonSynonymous=="Nonsyn", ]

write.table(snp_anno, output, row.names = F, quote = F, sep='\t')
write.table(snp_anno_filt, output2, row.names = F, quote = F, sep='\t')
