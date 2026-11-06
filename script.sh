
#!/bin/bash

for n in 1 2 3 4
do
    input_dir="Testcase$n"
    output_dir="Testcase${n}Diff"

    rm -rf "$output_dir"

    for file1 in "$input_dir"/*.1.txt
    do
        if [ -f "$file1" ]
        then
            file2="${file1%.1.txt}.2.txt"

            if [ -f "$file2" ]
            then
                filename="${file1##*/}"
                filename="${filename%.1.txt}"

                temp_file=$(mktemp)

                diff -u "$file1" "$file2" > "$temp_file"
                result=$?

                if [ "$result" -eq 1 ]
                then
                    mkdir -p "$output_dir"
                    mv "$temp_file" "$output_dir/${filename}Diff.txt"
                else
                    rm "$temp_file"
                fi
            fi
        fi
    done
done
