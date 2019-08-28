import sys

bg = {}

with open(sys.argv[1]) as f:
	for line in f:
		lst = line.strip().split('\t')
		snp = '|'.join(lst[1:5])
		bg[snp] = 1

with open(sys.argv[2]) as f:
	for line in f:
		lst = line.strip().split('\t')
		snp = '|'.join(lst[1:5])
		if snp not in bg:
			print(line.strip())
