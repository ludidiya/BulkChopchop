#!/bin/bash

WORKDIR="/home/lld/MyProject/BulkChopChop_YTJ"
Cas9_CRISPR="/home/lld/MyProject/BulkChopChop_YTJ/result/Cas9/CRISPR"
Cas9_CRISPRi="/home/lld/MyProject/BulkChopChop_YTJ/result/Cas9/CRISPRi"
Cpf1_CRISPR="/home/lld/MyProject/BulkChopChop_YTJ/result/Cpf1/CRISPR"
Cpf1_CRISPRi="/home/lld/MyProject/BulkChopChop_YTJ/result/Cpf1/CRISPRi"

# -z: 判断字符串是否为空
[ ! -z $CONDA_DEFAULT_ENV ] && [ $CONDA_DEFAULT_ENV == "chopchop-pip" ] || source activate chopchop-pip

fzf-down () {
    fzf --cycle --reverse --height 50% "$@" --border
}

# 设置参数chopchop运行参数和结果设置
echo -e "\033[31m---------- Set Up CRISPR Parameters ---------- \033[0m"

echo "Choose a genome: "
NP10="NP10: Streptomyces sp. NP10 contig00001, whole genome shotgun sequence."
SV_10712="SV_10712: Streptomyces venezuelae ATCC 10712 chromosome, complete genome."
sacCer3_R64="sacCer3_R64: Saccharomyces cerevisiae S288C chromosome I, complete sequence."
genome=("$(echo -e "$NP10\\n$SV_10712\\n$sacCer3_R64" | fzf-down --ansi)")
echo -e "\033[32m$genome\033[0m"

echo "Design for: "
CRISPR="CRISPR"
CRISPRi="CRISPRi"
CRISPR_Both="CRISPR and CRISPRi"
purpose=("$(echo -e "$CRISPR\\n$CRISPRi\\n$CRISPR_Both" | fzf-down --ansi)")
echo -e "\033[32m$purpose\033[0m"

echo "Select a gene list file for Bulk gRNA design:"
IFS=$'\n' file=("$(ls *.txt | fzf-down --ansi)")
echo -e "\033[32m$file\033[0m"
unset IFS

echo "Input UpStream Flanking Region of TSS (bp)."
read -p "Defualt is 20 bp: " UpStream
UpStream=${UpStream:-20}
echo -e "TSS UpStream flanking region is: \033[32m$UpStream (bp)\033[0m."

echo "Input DownStream Flanking Region of TSS (bp)."
read -p "Defualt is 50 bp: " DownStream
DownStream=${DownStream:-50}
echo -e "TSS DownStream flanking region is: \033[32m$DownStream (bp)\033[0m."

echo "Chose a CRISPR model below: "
Cpf1="Cpf1: KIM_2018(Algorithm) TTN(PAM), 24 bp(Guide size)"
Cas9="Cas9: DOENCH_2016(Algorithm), NGG(PAM), 20 bp(Guide size)"
CRISPR_Model=("$(echo -e "$Cas9 \\n$Cpf1" | fzf-down --ansi)")
echo -e "\033[32m$CRISPR_Model\033[0m"

read -p "Type the 5′ primer: " FiveP
echo -e "5′ primer: \033[32m$FiveP\033[0m"

read -p "Type the 3′ primer: " ThreeP
echo -e "3′ primer: \033[32m$ThreeP\033[0m"


echo "Save the top N result(s) from CHOPCHOP:"
read -p "Defualt is 3: " ResultNum
ResultNum=${ResultNum:-3}
echo -e "Save the top \033[32m$ResultNum\033[0m result(s)."

# 设置gRNA质粒图谱参数
echo -e "\033[31m---------- Set Up Parameters build Plasmids for gRNA results ---------- \033[0m"
echo "Select a plasmid to insert the gRNA:"
IFS=$'\n' plasmid=("$(ls *.gb | fzf-down --ansi)")
echo -e "\033[32m$plasmid\033[0m"
unset IFS

read -p "Absolute start position of the replacement sequence: " gRNA_start
echo -e "Start position: \033[32m$gRNA_start\033[0m"

read -p "Absolute end position of the replacement sequence: " gRNA_end
echo -e "End position: \033[32m$gRNA_end\033[0m"

# 判断所选基因组
if [[ "$genome" == NP10* ]]; then
	genome="NP10"
elif [[ "$genome" == SV_10712* ]]; then
	genome="SV_10712"
else 
	genome="sacCer3_R64"
fi

# 判断字符串是否以“Cas9”开头
if [[ "$CRISPR_Model" == Cas9* ]]; then
	CRISPR_Model=1 # Cas9
else
	CRISPR_Model=3 # Cpf1
fi

# 创建空文件整合多基因的结果
# rm -rf $WORKDIR/CRISPR_Cas9_result.txt
# rm -rf $WORKDIR/CRISPR_Cpf1_result.txt
# rm -rf $WORKDIR/CRISPRi_Cas9_result.txt
# rm -rf $WORKDIR/CRISPRi_Cpf1_result.txt

# touch CRISPR_Cas9_result.txt
# touch CRISPRi_Cas9_result.txt
echo "" > $Cas9_CRISPR/CRISPR_Cas9_result.txt
echo "" > $Cas9_CRISPRi/CRISPRi_Cas9_result.txt
echo -e "# rank\\tTargetSeq\\tlocation\\tSeqNoPAM\\tStrand\\tGC%\\tSelf-comp\\tMM0\\tMM1\\tMM2\\tMM3\\tEfficiency" >> $Cas9_CRISPR/CRISPR_Cas9_result.txt
echo -e "# rank\\tTargetSeq\\tlocation\\tSeqNoPAM\\tStrand\\tGC%\\tSelf-comp\\tMM0\\tMM1\\tMM2\\tMM3\\tEfficiency" >> $Cas9_CRISPRi/CRISPRi_Cas9_result.txt

# touch CRISPR_Cpf1_result.txt
# touch CRISPRi_Cpf1_result.txt
echo "" > $Cpf1_CRISPR/CRISPR_Cpf1_result.txt
echo "" > $Cpf1_CRISPRi/CRISPRi_Cpf1_result.txt
echo -e "# rank\\tTargetSeq\\tlocation\\tSeqNoPAM\\tStrand\\tGC%\\tSelf-comp\\tMM0\\tMM1\\tMM2\\tMM3\\tEfficiency" >> $Cpf1_CRISPR/CRISPR_Cpf1_result.txt
echo -e "# rank\\tTargetSeq\\tlocation\\tSeqNoPAM\\tStrand\\tGC%\\tSelf-comp\\tMM0\\tMM1\\tMM2\\tMM3\\tEfficiency" >> $Cpf1_CRISPRi/CRISPRi_Cpf1_result.txt

echo "" > $Cas9_CRISPR/CRISPR_Cas9_gp.txt
echo "" > $Cas9_CRISPRi/CRISPRi_Cas9_gp.txt
echo "" > $Cpf1_CRISPR/CRISPR_Cpf1_gp.txt
echo "" > $Cpf1_CRISPRi/CRISPRi_Cpf1_gp.txt

# run chopchop
echo -e "\033[31m---------- Run CHOPCHOP ---------- \033[0m"
while read geneName start end strand len
do
	# 判断基因的方向，并计算TSS附近区域
	if [[ "$strand" == - ]]; then
		let startNew=end-DownStream
		let endNew=end+UpStream
	else
		let startNew=start-UpStream
		let endNew=start+DownStream
	fi
	target=$startNew-$endNew
	# echo $target
	# 判断选择的CRISPR编辑模式，使用不同的chopchop参数运行chopchop脚本
	if [[ "$CRISPR_Model" == 1 ]]; then
		# Cas9
		echo "Run chopchop Cas9 Mode for $geneName:$target..."
		resultFile=$geneName.cas9.txt
		$HOME/Tools/chopchop/chopchop.py --targets chr:$target -T 1 -M NGG --maxMismatches 3 -g 20 --scoringMethod DOENCH_2016 -G $genome -o tmp/ > tmp/$resultFile 2> tmp/python.err
		# Cas9 CRISPR
		echo -e "\\n>$geneName:$start-$end\\t$strand" >> $Cas9_CRISPR/CRISPR_Cas9_result.txt
		echo -e "\\n>$geneName:$start-$end\\t$strand" >> $Cas9_CRISPR/CRISPR_Cas9_gp.txt
		awk 'BEGIN{OFS=FS="\t";}{print $1,$2,$3,substr($2,1,length($2)-3),$4,$5,$6,$7,$8,$9,$10,$11}' <(cat tmp/$resultFile | tail -n +2 | head -n $ResultNum) >> $Cas9_CRISPR/CRISPR_Cas9_result.txt
		# # get gRNA without PAM
		# n=0
		# for gRNA in `awk '{print substr($2,1,length($2)-3)}' <(cat tmp/$resultFile | tail -n +2 | head -n $ResultNum)`
		# do
		# 	n=$(($n+1))
		# 	output="p-""$geneName""-""$n"".gb"
		# 	python $WORKDIR/InsertSpacer.py "$plasmid" "$gRNA_start" "$gRNA_end" "$gRNA" "$output"
		# done
		# P5-gRNA-P3
		awk '{print tolower(FiveP)substr($2,1,length($2)-3)tolower(ThreeP)}' FiveP=$FiveP ThreeP=$ThreeP <(cat tmp/$resultFile | tail -n +2 | head -n $ResultNum) >> $Cas9_CRISPR/CRISPR_Cas9_gp.txt

		# Cas9 CRISPRi
		echo -e "\\n>$geneName:$start-$end\\t$strand" >> $Cas9_CRISPRi/CRISPRi_Cas9_result.txt
		echo -e "\\n>$geneName:$start-$end\\t$strand" >> $Cas9_CRISPRi/CRISPRi_Cas9_gp.txt
		# echo -e "\\n>$geneName:$start-$end\\t$strand"
		if [[ "$strand" == + ]]; then
			awk 'BEGIN{OFS=FS="\t";}{print $1,$2,$3,substr($2,1,length($2)-3),$4,$5,$6,$7,$8,$9,$10,$11}' <(cat tmp/$resultFile | tail -n +2 | grep -v "+" | head -n $ResultNum) >> $Cas9_CRISPRi/CRISPRi_Cas9_result.txt
			# P5-gRNA-P3
			awk '{print tolower(FiveP)substr($2,1,length($2)-3)tolower(ThreeP)}' FiveP=$FiveP ThreeP=$ThreeP <(cat tmp/$resultFile | tail -n +2 | head -n $ResultNum) >> $Cas9_CRISPRi/CRISPRi_Cas9_gp.txt
		else
			awk 'BEGIN{OFS=FS="\t";}{print $1,$2,$3,substr($2,1,length($2)-3),$4,$5,$6,$7,$8,$9,$10,$11}' <(cat tmp/$resultFile | tail -n +2 | grep -v "-" | head -n $ResultNum) >> $Cas9_CRISPRi/CRISPRi_Cas9_result.txt
			# P5-gRNA-P3
			awk '{print tolower(FiveP)substr($2,1,length($2)-3)tolower(ThreeP)}' FiveP=$FiveP ThreeP=$ThreeP <(cat tmp/$resultFile | tail -n +2 | head -n $ResultNum) >> $Cas9_CRISPRi/CRISPRi_Cas9_gp.txt
		fi
		rm -rf tmp/$resultFile

	else
		# Cpf1
		echo "Run chopchop Cpf1 Mode for $geneName:$target..."
		resultFile=$geneName.cpf1.txt
		$HOME/Tools/chopchop/chopchop.py --targets chr:$target -T 3 -M  TTN --maxMismatches 3 -g 24 --scoringMethod KIM_2018 -G $genome  -o tmp > tmp/$resultFile 2>  tmp/python.err
		# Cpf1 CRISPR
		echo -e "\\n>$geneName:$start-$end\\t$strand" >> $Cpf1_CRISPR/CRISPR_Cpf1_result.txt
		echo -e "\\n>$geneName:$start-$end\\t$strand" >> $Cpf1_CRISPR/CRISPR_Cpf1_gp.txt
		# chopchop没有设置碱基的Ambiguous substitutions，CPF1的PAM序列想设置成TTV，所以需要从结果中过滤删除TTT的gRNA
		awk 'BEGIN{OFS=FS="\t";}{print $1,$2,$3,substr($2,4,length($2)),$4,$5,$6,$8,$9,$10,$11,$7}' <(cat tmp/$resultFile | grep -v "\tTTT" | tail -n +2 | head -n $ResultNum) >> $Cpf1_CRISPR/CRISPR_Cpf1_result.txt
		# P5-gRNA-P3
		for PgRNAori in `awk '{print tolower(FiveP)substr($2,4,length($2))tolower(ThreeP)}' FiveP=$FiveP ThreeP=$ThreeP <(cat tmp/$resultFile | grep -v "\tTTT" | tail -n +2 | head -n $ResultNum)`
		do
			# echo $PgRNAori
			# get reverse complement sequence
			pgRNA_RC=("$(python $WORKDIR/Seq_RC.py "$PgRNAori")")
			echo $pgRNA_RC >> $Cpf1_CRISPR/CRISPR_Cpf1_gp.txt
		done

		n=0
		for gRNA in `awk '{print substr($2,4,length($2))}' <(cat tmp/$resultFile | grep -v "\tTTT" | tail -n +2 | head -n $ResultNum)`
		do
			n=$(($n+1))
			output=$Cpf1_CRISPR/p-ddcpf1-$geneName-$n.gb
			python $WORKDIR/InsertSpacer.py "$plasmid" "$gRNA_start" "$gRNA_end" "$gRNA" "$output"
		done

		# Cpf1 CRISPRi
		echo -e "\\n>$geneName:$start-$end\\t$strand" >> $Cpf1_CRISPRi/CRISPRi_Cpf1_result.txt
		echo -e "\\n>$geneName:$start-$end\\t$strand" >> $Cpf1_CRISPRi/CRISPRi_Cpf1_gp.txt
		if [[ "$strand" == - ]]; then
			awk 'BEGIN{OFS=FS="\t";}{print $1,$2,$3,substr($2,4,length($2)),$4,$5,$6,$8,$9,$10,$11,$7}' <(cat tmp/$resultFile | grep -v "\tTTT" | tail -n +2 | grep -v "+" | head -n $ResultNum) >> $Cpf1_CRISPRi/CRISPRi_Cpf1_result.txt
			for PgRNAori in `awk '{print tolower(FiveP)substr($2,4,length($2))tolower(ThreeP)}' FiveP=$FiveP ThreeP=$ThreeP <(cat tmp/$resultFile | grep -v "\tTTT" | tail -n +2 | grep -v "+" | head -n $ResultNum)`
			do
				pgRNA_RC=("$(python $WORKDIR/Seq_RC.py "$PgRNAori")")
				echo $pgRNA_RC >> $Cpf1_CRISPRi/CRISPRi_Cpf1_gp.txt
			done

			n=0
			for gRNA in `awk '{print substr($2,4,length($2))}' <(cat tmp/$resultFile | grep -v "\tTTT" | tail -n +2 | grep -v "+" | head -n $ResultNum)`
			do
				n=$(($n+1))
				output=$Cpf1_CRISPRi/p-ddcpf1-$geneName-$n.gb
				python $WORKDIR/InsertSpacer.py "$plasmid" "$gRNA_start" "$gRNA_end" "$gRNA" "$output"
			done
		else
			awk 'BEGIN{OFS=FS="\t";}{print $1,$2,$3,substr($2,4,length($2)),$4,$5,$6,$8,$9,$10,$11,$7}' <(cat tmp/$resultFile | grep -v "\tTTT" | tail -n +2 | grep -v "-" | head -n $ResultNum) >> $Cpf1_CRISPRi/CRISPRi_Cpf1_result.txt
			for PgRNAori in `awk '{print tolower(FiveP)substr($2,4,length($2))tolower(ThreeP)}' FiveP=$FiveP ThreeP=$ThreeP <(cat tmp/$resultFile | grep -v "\tTTT" | tail -n +2 | grep -v "-" | head -n $ResultNum)`
			do
				pgRNA_RC=("$(python $WORKDIR/Seq_RC.py "$PgRNAori")")
				echo $pgRNA_RC >> $Cpf1_CRISPRi/CRISPRi_Cpf1_gp.txt
			done

			n=0
			for gRNA in `awk '{print substr($2,4,length($2))}' <(cat tmp/$resultFile | grep -v "\tTTT" | tail -n +2 | grep -v "-" | head -n $ResultNum)`
			do
				n=$(($n+1))
				output=$Cpf1_CRISPRi/p-ddcpf1-$geneName-$n.gb
				python $WORKDIR/InsertSpacer.py "$plasmid" "$gRNA_start" "$gRNA_end" "$gRNA" "$output"
			done
		fi

		# rm -rf tmp/$resultFile
	fi
done < $file

echo -e "\033[32m---------- DONE! ---------- \033[0m"
# if [[ "$CRISPR_Model" == 1 ]]; then
#   echo -e "\033[32mSee result in:\\n CRISPR_Cas9_result.txt\\n CRISPRi_Cas9_result.txt\033[0m"
# else
# 	echo -e "\033[32mSee result in:\\n CRISPR_Cpf1_result.txt\\n CRISPRi_Cpf1_result.txt\033[0m"
# fi
# echo -e "\033[32mThanks for using! (^｡^)\033[0m"

