options(stringsAsFactors = F)
gene_anno <- read.table('/home/xfu/Gmatic5/genome/tair10/tair10_gene_anno.tsv', sep='\t', quote='', header = T)

argv <- commandArgs(T)
input <- argv[1]
output <- argv[2]

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

write.table(snp_anno, output, row.names = F, quote = F, sep='\t')
