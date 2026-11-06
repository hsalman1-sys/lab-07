
#!/bin/bash

overall=0

for n in 1 2 3 4
do
    input_dir="Testcase$n"
    output_dir="Testcase${n}Diff"

    testcase_ok=1
    expected_count=0

    for file1 in "$input_dir"/*.1.txt
    do
        if [ -f "$file1" ]
        then
            file2="${file1%.1.txt}.2.txt"

            if [ -f "$file2" ]
            then
                filename="${file1##*/}"
                filename="${filename%.1.txt}"
                output_file="$output_dir/${filename}Diff.txt"

                if cmp -s "$file1" "$file2"
                then
                    if [ -f "$output_file" ]
                    then
                        testcase_ok=0
                        echo "Unexpected file: $output_file" >&2
                    fi
                else
                    expected_count=$((expected_count + 1))

                    if [ ! -f "$output_file" ]
                    then
                        testcase_ok=0
                        echo "Missing file: $output_file" >&2
                    else
                        if ! diff -u <(diff -u "$file1" "$file2" | tail -n +3) <(tail -n +3 "$output_file") > /dev/null
                        then
                            testcase_ok=0
                            echo "Incorrect contents: $output_file" >&2
                        fi
                    fi
                fi
            fi
        fi
    done

    if [ "$expected_count" -eq 0 ]
    then
        if [ -d "$output_dir" ]
        then
            testcase_ok=0
            echo "Unexpected directory: $output_dir" >&2
        fi
    else
        if [ ! -d "$output_dir" ]
        then
            testcase_ok=0
            echo "Missing directory: $output_dir" >&2
        else
            actual_count=$(find "$output_dir" -mindepth 1 -maxdepth 1 | wc -l)

            if [ "$actual_count" -ne "$expected_count" ]
            then
                testcase_ok=0
                echo "Incorrect number of files: $output_dir" >&2
            fi
        fi
    fi

    if [ "$testcase_ok" -eq 1 ]
    then
        echo "Testcase$n: PASS"
    else
        echo "Testcase$n: FAIL"
        overall=1
    fi
done

exit "$overall"
