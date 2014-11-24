set style data boxes
set style fill solid
set boxwidth 0.5
set term png
set output "box_plot.png"
set xlabel "OTUs"
set ylabel "Number of OTUs"
set xtics rotate
#set xtics font ", 3" 
set terminal png size 2400,1600
plot COL=2 filename using COL:xticlabels(1)
replot
#pause -1