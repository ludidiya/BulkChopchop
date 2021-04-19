#!/home/lld/anaconda3/bin/python

import os
from Bio import SeqIO

# 设置变量
gbff = input("Enter the gbff file name:\n")
synonyms = input("Enter the Synonyms name:\n")
strain = input("Enter the Strain name:\n")

fa_tmp = synonyms+"_"+strain+".fa.tmp"
fa = synonyms+"_"+strain+".fa"
bowtie = synonyms+"_"+strain+".2bit"
bowtieIndex = synonyms+"_"+strain

# 格式转换：gbff文件转换为fasta文件
SeqIO.convert(gbff, "genbank", fa_tmp, "fasta")

# 修改fasta文件中header名字
os.system(r'sed "s/^>.*chromosome />chr/; s/^>.* mitochondrion,/>chrM,/; s/, complete sequence$//; s/, complete genome$//" %s > %s' % (fa_tmp, fa))

# fasta格式转换成2bit文件
# 根据fasta文件生成ebwt文件
os.system('faToTwoBit %s %s && bowtie-build %s %s' % (fa, bowtie, fa, bowtieIndex))

# 删除中间文件，并把生成的文件都放到genome文件夹下
os.system('rm %s %s && mv %s* genome/' % (fa_tmp, fa, bowtieIndex))

# SeqIO.convert("SP_NP10.gb", "genbank", "SP_NP10.fa.tmp", "fasta")
# awk '/^>/{print ">contig" ++i; next}{print}' < SP_NP10.fa.tmp  | grep '>' | head
