grep 'transposable_element_gene' /home/xfu/Gmatic5/genome/tair10/tair10.gff |cut -f9|sed 's/ID=//'|sed -r 's/;.+//'|sort|uniq > transposable_element_gene

grep -v -f transposable_element_gene /home/xfu/Gmatic5/genome/tair10/tair10.gff > tair10_fix.gff
