#!/bin/bash
output_dir="output"
touch report.txt
cnt_p=0
cnt_f=0

echo "Timer 8 bit" >> report.txt
echo "============================" >> report.txt

for file in "${output_dir}"/*; do
    while IFS= read -r line; do
        # Loại bỏ ký tự CR và so sánh với "PASS" và "FAIL"
#        clean_line="${line//[$'\r']}"
        filename=$(basename "$file")

        # Ghi vào file report
#        echo "${filename}: ${line}" >> report.txt

        if [[ $line == *"PASS"* ]]; then
            cnt_p=$((cnt_p + 1))
		echo "${filename}: PASS" >> report.txt
        elif [[ $line == *"FAIL"* ]]; then
            cnt_f=$((cnt_f + 1))
		echo "${filename}: FAIL" >> report.txt
        fi
    done < "${file}"
done

echo "=============================" >> report.txt
total=$((cnt_p + cnt_f))
echo "total: ${total}" >> report.txt
echo "PASS: ${cnt_p}" >> report.txt
echo "FAIL: ${cnt_f}" >> report.txt

