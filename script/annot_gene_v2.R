options(stringsAsFactors = F)
gene_anno <- read.table('script/tair10_gene_anno.tsv', sep='\t', quote='', header = T)

argv <- commandArgs(T)
input <- argv[1]
output <- paste0(input, '_anno.tsv')

#input <- 'OC_fg_8_15_rm_Col0_in_block_rm_Ws'
blocks <- read.table(input, sep = '\t')
blocks$ID <- paste(blocks$V2, blocks$V3, sep = ':')
snp <- read.table(paste0(input, '.tsv'), sep='\t')
snp$ID <- paste(snp$V1, snp$V2, sep = ':')

snp <- merge(blocks, snp, by.x = 10, by.y = 15)[c(2,11:24)]
snp[is.na(snp)] <- ''
colnames(snp) <- c('block',
                   'chromosome', 
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
snp_anno <- merge(snp, gene_anno, by.x = 16, by.y = 1, all.x = T)
snp_anno[is.na(snp_anno)] <- ''
snp_anno <- snp_anno[order(snp_anno$chromosome, snp_anno$position), -1]
write.table(snp_anno, output, row.names = F, quote = F, sep='\t')
