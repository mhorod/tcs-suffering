#!/bin/bash

function format_file
{
  echo "Formatting: ${1}"
  latexindent "${1}" > "${1}.tmp" && mv "${1}.tmp" "${1}"
}

if [ $# != 1 ]; then
  echo "Usage: ./format.sh file"
  exit 1;
fi

if [ -d ${1} ]; then
  for file in $(find "${1}" -type f -name '*.tex'); do
    format_file ${file}
  done
else
  format_file ${1};
fi

echo "Cleaning logs"
find . -type f -name 'indent.log' | xargs rm
