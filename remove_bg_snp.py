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
			if int(lst[5]) >= 30 and int(lst[6]) >=10 and float(lst[7]) >= 0.9:
				print(line.strip())
