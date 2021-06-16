#!/bin/bash

if [[ `which ssconvert` ]]; then
    if (($#>0)); then
	Name=${1%.*}
	Name=${Name##*/}
	echo "Model name: «${Name}»"
	LC_ALL="C" ssconvert -S \
              --export-type=Gnumeric_stf:stf_assistant \
	      --export-options="quoting-mode=never separator='	' locale=C" ${1} "%s.tsv"
    else
	echo "Usage: $0 spreadsheet_file.{gnumeric,ods,xlsx}"
	echo "   Creates one tsv file for each sheet in the input file."
	echo "   Cells must not contain line breaks."
	echo "   Beware of locale and language issues, like numbers with commas and localized TRUE/FALSE"
    fi
else
    echo "gnumeric's «ssconvert» not found"
fi
