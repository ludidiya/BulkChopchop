import sys

plasmid_file = sys.argv[1]
gRNA_start = sys.argv[2]
gRNA_end = sys.argv[3]
gRNA = sys.argv[4]
output_file = sys.argv[5]


from Bio import SeqIO
from Bio.Seq import Seq
plasmid = SeqIO.read(plasmid_file, "gb")
plasmid_seq_mutable = plasmid.seq.tomutable()
plasmid_seq_mutable[int(gRNA_start)-1:int(gRNA_end)] = gRNA
plasmid.seq = plasmid_seq_mutable
SeqIO.write(plasmid, output_file, "gb")
