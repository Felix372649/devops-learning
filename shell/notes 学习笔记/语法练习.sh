#!/bin/bash
#======【99乘法表】======
#
#aaa(){
#for i in {1..9}
#do
#dd=$i 
#	for a in $(seq $dd 9)
#	do
#	cc=$(($dd*$a))
#	echo "$dd X $a 得：$cc"
#	done
#done
#}
#aaa
#======【99乘法表】======
aaa(){
for i in {1..9}
do
dd=$i 
	for ((a=$i;a<=9;a++ ))
	do
	cc=$(($dd*$a))
	echo "$dd X $a 得：$cc"
	done
done
}
aaa

