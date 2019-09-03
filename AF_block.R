options(stringsAsFactors = F)

argv <- commandArgs(T)
input <- argv[1]
output <- paste0(input, '_block.bed')

#input <- 'OC_fg_8_15_rm_Col0'
snp <- read.table(input, sep = '\t')[c(2, 3, 8)]
colnames(snp) <- c('chromosome', 'position', 'AF')

result <- NULL
for (i in 1:5) {
  snp_chrN <- snp[snp$chromosome==i,]
  x <- rep(0, nrow(snp_chrN))
  x[snp_chrN$AF >= 0.9] <- 1
  x1 <- c(0, x) 
  x2 <- c(x, 0)
  y <- x2 - x1
  blocks <- data.frame(start_idx = which(y == 1), end_idx = which(y == -1)-1)
  blocks$num <- blocks$end_idx - blocks$start_idx + 1
  blocks$start <- snp_chrN$position[blocks$start_idx] - 1
  blocks$end <- snp_chrN$position[blocks$end_idx]
  blocks$length <- blocks$end - blocks$start
  blocks$chr <- rep(i, nrow(blocks))
  result <- rbind(result, blocks)
}

result_filt <- result[result$length > 5000 & result$num > 2, c('chr', 'start', 'end', 'num')]
result_filt$ID <- paste0(result_filt$chr, ':', result_filt$start, '-', result_filt$end, ':', result_filt$num)

write.table(result_filt, output, col.names = F, row.names = F, sep = '\t', quote = F)

