#!/bin/bash
cat /dev/null > annot.txt
echo -e total_plotted_degrees'\t'360 > annot.txt
echo -e start_rotation'\t'@ >> annot.txt

echo -e branch_thickness'\t'1.6 >> annot.txt
##for moving bracket back 
echo -e branch_bracket_depth'\t'.4 >> annot.txt
##curve the branch. closer to 0 more circular
echo -e branch_bracket_width'\t'0.1  >> annot.txt

##annotation on the left
echo -e annotation_legend_font_size'\t'17  >> annot.txt
echo -e annotation_background_alpha'\t'0.1  >> annot.txt
## clade ring font size
echo -e annotation_font_size'\t'12 >> annot.txt
##width of the annotation ring def 0.1
echo -e annotation_background_width'\t'0.13 >> annot.txt
##space between clade and annotation (label)
echo -e annotation_background_separation'\t'0.003 >> annot.txt
##space between label and ring
echo -e annotation_background_offset'\t'0.003 >> annot.txt

## legend right font size
echo -e class_legend_font_size'\t'14 >> annot.txt
echo -e class_legend_marker_size'\t'3.5 >> annot.txt

echo -e clade_marker_size'\t'40 >> annot.txt
echo -e clade_marker_edge_color'\t'#000000  >> annot.txt
echo -e clade_marker_edge_width'\t'0.5 >> annot.txt
echo -e clade_marker_font_size'\t'8  >> annot.txt
echo -e clade_marker_font_color'\t'black  >> annot.txt
echo -e clade_marker_color'\t'white >> annot.txt
#echo -e annotation_background_width'\t'1 >> annot.txt

##echo -e clade_separation'\t'1 >> annot.txt
#echo -e internal_labels_rotation'\t'270 >> annot.txt
#echo -e internal_label'\t'1'\t'Kingdom >> annot.txt
#echo -e internal_label'\t'2'\t'Phyla >> annot.txt
#echo -e internal_label'\t'3'\t'Classes >> annot.txt
#echo -e internal_label'\t'4'\t'Orders >> annot.txt
#echo -e internal_label'\t'5'\t'Families >> annot.txt
#echo -e internal_label'\t'6'\t'Genera >> annot.txt
#echo -e internal_label'\t'7'\t'Species >> annot.txt

#for i in {1..10..1}; do
#	echo -e internal_label_font_size'\t'$i'\t'13 >> annot.txt
#done


##strain annotation * name on map. *:* left annot, *:(name) name on map with custom label; 
##name(not same as map) clade_marker_color & clade_marker_size (colour and size of annotation)
##clade clade_marker_color color path
##strain class put strain in class. edit with class_legend above. edit color with clade_marker_color
##can do class annotation_backgroud_color

