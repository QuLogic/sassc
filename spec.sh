#!/bin/bash

BASE=$(dirname $0)

searchpath=${1:-.}

errors=()
diffs=()
worked=0
spec_count=0

echo -e "Running tests in ${searchpath} ...\n\n"

for input_file in `find $searchpath -name 'input.*'`; do
    ((spec_count++))
    spec_dir=$(dirname $input_file)

    sassc_file="$spec_dir/sassc_output.css"
    expected_file="$spec_dir/expected_output.css"
    error_file="$spec_dir/sassc_errors.txt"

    $BASE/bin/sassc ${input_file} > ${sassc_file} 2> $error_file

    sassc_output=`cat $sassc_file`
    expected_output=`cat $expected_file`
    sassc_error=`cat $error_file`

    if [ "$expected_output" != "$sassc_output" ]; then
      echo -n "F"
      errors+=("Failed test ${spec_dir}\n$sassc_error")
      diffs+=("`diff -rub ${expected_file} ${sassc_file}`")
    else
      ((worked++))
      echo -n "."
    fi

    rm "${sassc_file}"
    rm "${error_file}"
done

echo -e "\n\n${worked}/${spec_count} Specs Passed!"

if [ ${#errors[*]} -gt 0 ]; then
  echo -e "\n================================\nTEST FAILURES!\n\n"
  i=0
  while [ $i -lt ${#errors[*]} ]; do
    echo -e "\n----- ERRORS ------\n"
    echo -e "${errors[$i]}"
    echo -e "\n-----  DIFF  ------\n"
    echo -e "${diffs[$i]}"
    ((i++))
  done
  echo
  exit 1
else
  echo "YOUWIN!"
  exit 0
fi

