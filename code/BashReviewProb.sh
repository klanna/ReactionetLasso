#!/bin/bash 
pname=$1
pval=$2

for rep in {1..5}
do
	ModelName=ARS$rep\rep100kDT14sp14tp$pname\bn
	echo nohup ./ReactionetLasso.py -m $ModelName -p $pval -o 2 -g splines2 \&
done

