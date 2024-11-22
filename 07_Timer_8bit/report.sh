#!/bin/bash

output="output"

touch report.txt

cnt_p=0
cnt_f=0

echo "_________TIMER 8 BIT_________" > report.txt
echo " " >> report.txt
echo "=============================" >> report.txt

for file in "output"/* 
do 
	while IFS= read -r line 
	do	
		if [[ $line == *"PASS"* ]]	 	
		then 
			cnt_p=$(($cnt_p+1))
			echo "${file}: PASS" >> report.txt
		elif [[ $line == *"FAIL"* ]]
		then 
			cnt_f=$(($cnt_f+1))
			echo "${file}: FAIL" >> report.txt
		fi 
	done < "${file}"
done

total=$(($cnt_p+$cnt_f))
#echo " " >> report.txt
echo "=============================" >> report.txt
echo " " >> report.txt
echo "Total: ${total}" >> report.txt
echo "FAIL: ${cnt_f}" >> report.txt
echo "PASS: ${cnt_p}" >> report.txt
