FILE=$1
DIR=$2
mkdir $DIR
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder $DIR --snp $FILE --chrom 1 --start 1 --end 30427671 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder $DIR --snp $FILE --chrom 2 --start 1 --end 19698289 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder $DIR --snp $FILE --chrom 3 --start 1 --end 23459830 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder $DIR --snp $FILE --chrom 4 --start 1 --end 18585056 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
SHOREmap annotate --chrsizes reference/chrSizes.txt --folder $DIR --snp $FILE --chrom 5 --start 1 --end 26975502 --genome indexs/TAIR10_chr_all.fas.shore --gff reference/TAIR10_GFF3_genes.gff
cat $DIR/prioritized_snp*|sort -nrk6,6 -k1,1n -k2,2n|grep 'Nonsyn'|cut -f1-7,9-10,12-16 > ${FILE}_Nonsyn.tsv
Rscript script/annot_gene.R ${FILE}_Nonsyn.tsv ${FILE}_Nonsyn_gene.tsv
rm -r $DIR
