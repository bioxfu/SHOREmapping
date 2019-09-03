FILE=$1
DIR=${FILE}_anno
mkdir $DIR
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder $DIR --snp $FILE --chrom 1 --start 1 --end 30427671 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder $DIR --snp $FILE --chrom 2 --start 1 --end 19698289 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder $DIR --snp $FILE --chrom 3 --start 1 --end 23459830 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder $DIR --snp $FILE --chrom 4 --start 1 --end 18585056 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder $DIR --snp $FILE --chrom 5 --start 1 --end 26975502 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
cat $DIR/prioritized_snp*|cut -f1-7,9-10,12-16|awk '{print $0"\t\t\t\t\t\t"}'|cut -f1-14 > ${FILE}.tsv
rm -r $DIR
