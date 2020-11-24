#!/bin/bash

## input file: Contig Taxid CAZy RGI Antismash
## Example:  bash circle_tax_ring.sh contig_info_overall contig_host
bar=$1
box=$2
out=$3

cut -f1-2 $bar | sort > bar
cut -f1-2 $box | sort > box

if cmp -s bar box ; then
	echo similar file
else
	echo different file
	exit
fi

rm bar box

drawFig () {

	sed 's/,/./g' -i draw_cstm_mtphlan annot.txt
	sed 's/@/177/g' -i annot.txt

	num=$1
	graphlan_annotate.py --annot annot.txt draw_cstm_mtphlan meta_gralan.xml
	graphlan.py meta_gralan.xml cst_mtphlan${num}.png --dpi 300 --size 8

}

ringProcess () {

	fileIn=$1
	groupIn=$2
	scaleFactor=$3
	ringType=$4
	ringNo=$5

	awk -v col="${groupIn}" '{if(NR==1) for(i=1;i<=NF;i++) { if($i~col) { col=i;break} } else print $2,$col}' ${fileIn} | awk '{a[$1]+=$2}END{for(i in a) print i,a[i] }' > ${groupIn}.txt

	seqTot=$(awk '{s+=$2} END {print s}' ${groupIn}.txt)
	seqLar=$(sort -n -k2 ${groupIn}.txt | tail -1 | awk '{print $2}')
	scaleVal=$(echo "scale=5; ${scaleFactor} / (${seqLar}/${tot})" | bc)

	if [[ "${ringType}" == "ring_height" ]]; then

#		printf "ring_label_font_size\t%s\t15\n" "${ringNo}" >> annot.txt
		printf "ring_separator_color\t%s\tGREY\n" "${ringNo}" >> annot.txt
		printf "ring_internal_separator_thickness\t%s\t0.3\n" "${ringNo}" >> annot.txt

		##right legend. decending
		printf "ring_color\t%s\tcolour%s\n" "${ringNo}" "${ringNo}" >> annot.txt

		## annotation on top right
		printf "%s\tclade_marker_color\tcolour%s\n" "${ringNo}. ${group/_/ }" "${ringNo}" >> annot.txt

##		echo -e ring_external_separator_thickness'\t'${ringNo}'\t'0.6 >> annot.txt
		## annotatin on ring
##		echo -e ring_label'\t'${ringNo}'\t'$(echo ${group} | sed 's/_/ /g') >> annot.txt

		awk '$2>0' ${groupIn}.txt | awk -v OFS='\t' -v rng=$"${ringNo}" -v rngTpe="${ringType}" -v seqT="${seqTot}" -v scale="${scaleVal}" '{print $1,rngTpe,rng,scale*$2/seqT}' >> annot.txt

	## ring_alpha is for box type
	elif [[ "${ringType}" == "ring_alpha" ]]; then

#		printf "ring_label_font_size\t%s\t15\n" "${ringNo}" >> annot.txt
		printf "ring_separator_color\t%s\tBLACK\n" "${ringNo}" >> annot.txt
		printf "ring_internal_separator_thickness\t%s\t0.5\n" "${ringNo}" >> annot.txt

		##right legend. decending
		printf "ring_color\t%s\tcolour%s\n" "${ringNo}" "${ringNo}" >> annot.txt

		## annotation on top right
		printf "%s\tclade_marker_color\tcolour%s\n" "${ringNo}. ${group/_/ }" "${ringNo}" >> annot.txt

		echo -e ring_external_separator_thickness'\t'${ringNo}'\t'0.5 >> annot.txt
		## annotatin on ring
##		echo -e ring_label'\t'${ringNo}'\t'$(echo ${group} | sed 's/_/ /g') >> annot.txt

		awk '$2>0' ${groupIn}.txt | awk -v OFS='\t' -v rng=$"${ringNo}" -v rngTpe="${ringType}" '{print $1,rngTpe,rng,1}' >> annot.txt
		## Create pin to rings
		if (( ${ringNo} % 3 == 0 )) ; then
			awk '$2>0' ${groupIn}.txt | awk -v OFS='\t' -v rng=$"${ringNo}" -v rngTpe="${ringType}" '{print $1,"ring_shape",rng,"^"}' >> annot.txt
		elif (( ${ringNo} % 2 != 0 )) ; then
			awk '$2>0' ${groupIn}.txt | awk -v OFS='\t' -v rng=$"${ringNo}" -v rngTpe="${ringType}" '{print $1,"ring_shape",rng,"v"}' >> annot.txt
		fi
#		awk '$2>0' ${groupIn}.txt | awk -v OFS='\t' -v rng=$"${ringNo}" -v rngTpe="${ringType}" -v seqT="${seqTot}" -v scale="${scaleVal}" '{print $1,rngTpe,rng,scale*$2/seqT}' >> annot.txt
	fi
}

prepRingType () {

	## Note the input file in the first place.
	## Box rings
	if [[ "${type}" == "box" ]]; then
		printf "ring_height\t%s\t0.7\n" "${ring}" >> annot.txt
		ringProcess ${box} ${group} 0.7 ring_alpha ${ring}
		rm ${group}.txt
		
	else
	## Bar ring
		printf "ring_width\t%s\t0.5\n" "${ring}" >> annot.txt
		printf "ring_height\t%s\t2.1\n" "${ring}" >> annot.txt

		## print column values based on group 
		ringProcess ${bar} ${group} 2 ring_height ${ring}
		cat  ${group}.txt >> all_rings_tax

		rm ${group}.txt
	fi

}


bareCircle () {

	bash meta_annot.sh
	echo -n > draw_cstm_mtphlan

	for n in {1..7..1}; do
		cut -d, -f 1-$n cnt_species | awk '!seen[$0]++' >> draw_cstm_mtphlan
		## clade label: can be used to correct figure
#		cut -d, -f 1-$n cnt_species | sort | uniq -c | awk '{print $2"\tclade_marker_label\t"$1}' >> annot.txt
		##clade size (species level)
		cut -d, -f 1-$n cnt_species | sort | uniq -c |\
		while read -r nuum grrp; do
			perc=$(echo "scale=5; ${nuum}/$tot * 1000" | bc)
			if [ "${nuum}" -gt "0" ]; then
				echo -e ${grrp}'\t'clade_marker_size'\t'$perc >> annot.txt
			fi
		done
	done 

}

cladeColors () {

	if [[ -s phylum_abundance_color.txt ]]; then
		echo -n > color_p
		cut -d, -f2 cnt_species | sort | uniq -c | sort -nr | sed '/Unknown/d;s/^.*_//g' | head -5 > top_phylums
		fgrep -f top_phylums phylum_abundance_color.txt > phylum_colors.txt
		while read -r phy col; do
			grep -w "p_${phy}" cnt_species | awk -F',' -v OFS=',' -v color="${col}" '!s[$1,$2]++ {print $1,$2" "color}' >> color_p
		done < phylum_colors.txt
		rm top_phylums
#		cp phylum_abundance_color.txt color_p
	else
		##Create base color for phylum using clade annotation (circular ring inside)
		cut -d, -f1-2 cnt_species | sort | uniq -c | sed '/Unknown/d' | sort -nr | awk '$1>50 {print $2,NR";"}' > color_p
		sed 's/4;/\#cc8d27/g;s/3;/\#29cc36/g;s/2;/\#ff3333/g;s/1;/\#00bfff/g' -i color_p
	fi

	awk '{print $1"\tannotation_background_color\t"$2}' color_p >> annot.txt
	sed 's/ .*//g' color_p | awk -F',' '{print $0"\tannotation\t"$2}' | sed 's/._//3g'  >> annot.txt

	cut -d, -f1-3 cnt_species | sort | uniq -c | sed '/Unknown/d' | sort -nr | awk '$1>50 {print $2}' |\
	while IFS="," read -r kig phy cls; do
		printf "%s,%s,%s\tannotation_background_color\t%s\n" ${kig} ${phy} ${cls} $(grep ${phy} color_p | awk '{print $2}') >> annot.txt
		printf "%s,%s,%s\tannotation\t%s\n" ${kig} ${phy} ${cls} ${cls/*_} >> annot.txt
	done
	rm cnt_species

}

ringPrepare () {

	## Ring setting
	## Using box file input
	awk 'BEGIN{FS=OFS="\t"} NR==1{print} NR>1{for (i=1;i<=NF;i++) a[i]+=$i} END {for (i=1;i<=NF;i++) printf a[i] OFS; printf "\n"}' $box | cut -f3- | awk '{ for (i=1; i<=NF; i++) RtoC[i]= (RtoC[i]? RtoC[i] FS $i: $i) } END{ for (i in RtoC) print RtoC[i],"box" }' | sort -n -k2 > ring_cnt

	## Using bar file input
	awk 'BEGIN{FS=OFS="\t"} NR==1{print} NR>1{for (i=1;i<=NF;i++) a[i]+=$i} END {for (i=1;i<=NF;i++) printf a[i] OFS; printf "\n"}' $bar | cut -f3- | awk '{ for (i=1; i<=NF; i++) RtoC[i]= (RtoC[i]? RtoC[i] FS $i: $i) } END{ for (i in RtoC) print RtoC[i],"bar" }' | sort -n -k2 >> ring_cnt

}

ringDraw () {

	## Create the position of the rings
	## NR, No. of contigs, Name, Ring type
	awk '{print NR,$2,$1,$3}' ring_cnt > fin_rings

	lineNum=$(wc -l fin_rings | awk '{print $1}')
	echo -n | tee all_rings_tax 
	while read -r ring tot group type; do
		## The last bar ring will have larger gap aka custom settings
		if [[ "${ring}" != "${lineNum}" ]]; then
			prepRingType
		else
			## The outter ing setting
			## Set up ring width and height
			printf "ring_width\t%s\t0.5\n" "${ring}" >> annot.txt
			printf "ring_height\t%s\t3.1\n" "${ring}" >> annot.txt

			## print column values based on group 
			## Input bar file, ring type, scale facto, ring_height, ring 
			ringProcess ${bar} ${group} 3 ring_height ${ring}
			cat  ${group}.txt >> all_rings_tax

			rm ${group}.txt
		fi
	done < fin_rings

#	rm ring_cnt fin_rings


	## ring color
#	sed 's/colour4/#FB61D7/g;s/colour1/#A58AFF/g;s/colour6/#00B6EB/g;s/colour5/#00C094/g;s/colour3/#53B400/g;s/colour2/#C49A00/g;s/colour7/#F8766D/g' -i annot.txt
        sed 's/colour4/#FB61D7/g;s/colour1/#a1a09f/g;s/colour6/#00B6EB/g;s/colour5/#00C094/g;s/colour3/#404040/g;s/colour2/#737272/g;s/colour7/#F8766D/g' -i annot.txt
	sed 's/1. /I. /g;s/2. /II. /g;s/3. /III. /g;s/4. /1. /g;s/5. /2. /g;s/6. /3. /g' -i annot.txt

}

genusLabel () {

	awk '{print $1}' color_p > phylum
	## Search all taxa conbine different levels to see genus with all hits
	fgrep -f phylum all_rings_tax | awk -F' ' -v OFS='\t' '{x=$1;$1="";a[x]=a[x]$0}END{for(x in a)print x,a[x]}' | sed '/\t0/d;s/\t.*//g;s/,/ /g;s/,._Unknown//g;/g_Unknown/d' > important_symbionts

	## Search and annotate 
	while read -r phyl colr; do
		for n in {2..7..1}; do
			fgrep "${phyl/,/ }" important_symbionts | cut -d' ' -f1-$n | sed '/Unknown/d' | awk -v color="${colr}" '!s[$0]++ {print $0"\tclade_marker_color\t"color}' | tr ' ' ',' >> annot.txt
		done
		fgrep "${phyl/,/ }" important_symbionts | cut -d' ' -f1-7 | sed '/Unknown/d' | sed 's/.* g_/g_/g' | awk -v color="${colr}" -F'_' '{print $0"\tannotation\t*: "$2"\n"$0"\tannotation_background_color\t"color}' >> annot.txt
	done < color_p

#rm phylum color_p important_symbionts all_rings_tax

}

awk '{print $2}' $bar | sed '/^Taxonomy/d' > cnt_species
tot=$(cut -d, -f 1 cnt_species | sort | uniq -c | awk '{SUM+=$1} END {print SUM}')

wc -l cnt_species

bareCircle
cladeColors
ringPrepare
ringDraw
genusLabel

drawFig 4

###awk 'BEGIN {s = 3; e = 5; } { for (i=s; i<=e; i++) printf("%s%s", $(i), i<e ? OFS : "\n"); }' contig_info_overall
###awk '{ for (i=3; i<=5; i++) printf("%s%s", $(i), i<e ? OFS : "\n"); }' contig_info_overall

### Need 2 var as the col turns into column number.
#awk -v txt=CAZy -v col=CAZy '{if(NR==1) for(i=1;i<=NF;i++) { if($i~col) { col=i;break} } else print $1,txt,$col}' contig_info_overall

#awk 'NF>1 { for(i=3;i<=NF;i++) if ($i==0) next }1' contig_info_overall
## take out next to get the line with that value

### Get sum based on taxo
###awk '{a[$2]+=$3;b[$2]+=$4;c[$2]+=$5}END{for(i in a)print i, a[i], b[i], c[i]|"sort"}' contig_origin
