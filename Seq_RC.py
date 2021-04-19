import sys

seq = sys.argv[1]

from Bio.Seq import Seq
my_seq = Seq(seq)
print(my_seq.reverse_complement())
