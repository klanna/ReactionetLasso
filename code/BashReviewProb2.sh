#!/bin/bash 
pname=$1

for rep in {1..5}
do
	ModelName=ARS$rep\rep100kDT14sp14tp$pname\bn
	for pval in 0.01 0.05 0.1 0.25 0.5 0.75 0.95 0
	do
		echo nohup ./ReactionetLasso.py -m $ModelName -p $pval -o 2 -g splines2 \&
	done
done

