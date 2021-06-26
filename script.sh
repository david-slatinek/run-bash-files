#!/bin/bash
#Run sh files found at [path] with {flags}

help() {
	echo "NAME"
	echo -e "\tRun Bash Files"
	echo -e "\tRuns all sh files found at [path]"
	echo -e "\tIf only specific files are required to run, check -r flag\n"

	echo -e "SYNOPSIS"
	echo -e "\tbash script.sh [path] <flags>"
	echo -e "\tchmod +x script.sh => ./script.sh [path] <flags>"

	echo -e "\nFLAGS"
	echo "-h"
	echo -e "\tPrint help"

	echo "-r [regex]"
	echo -e "\tRun only files whose name matches with [regex]"

	echo "-R"
	echo -e "\tEnable recursive mode"

	echo "-q"
	echo -e "\tQuiet mode. Redirects file output to /dev/null"

	echo "-p"
	echo -e "\tBefore running a file, print path and filename"

	echo "-f"
	echo -e "\tPrint path and filename without running the file"

	echo "-s"
	echo -e "\tPrint statistics"

	printf '%s\n' "-e"
	echo -e "\tPrint errors when running files"
}

run() {
	path=$1

	if [[ $2 = true ]]; then
		regex=".*/$3"
	else
		regex=".*/*.sh"
	fi

	if [[ $4 = true ]]; then
		files=$(find "$path" -type f -regex "$regex")
	else
		files=$(find "$path" -maxdepth 1 -type f -regex "$regex")
	fi

	if [[ $7 = true ]]; then
		printf "%s\n" "$files"
		exit 0
	fi

	local -i numberOfSuccessful=0
	local -i numberOfErrors=0

	for file in $files; do
		if [[ $6 = true ]]; then
			echo "Executing $file"
		fi

		if [[ $5 = true ]]; then
			bash "$file" >/dev/null
		else
			bash "$file"
		fi

		if [[ $? -eq 0 ]]; then
			((numberOfSuccessful++))
		else
			((numberOfErrors++))
			if [[ $9 = true ]]; then
				echo "Error when running $file"
			fi
		fi

		if [[ $5 = false ]]; then
			printf "\n"
		fi
	done

	if [[ $8 = true ]]; then
		echo -e "\nNumber of scripts: $((numberOfSuccessful + numberOfErrors))"
		echo -e "Successfully executed scripts: $numberOfSuccessful"
		echo -e "Number of errors: $numberOfErrors"
	fi
}

if [[ -z "$*" ]]; then
	help
	exit 0
fi

for i in "$@"; do
	if [[ $i == "-h" ]]; then
		help
		exit 0
	fi
done

path=$1
shift

if [[ ! -e $path ]]; then
	echo "The path does not exist"
	exit 1
elif [[ ! -d $path ]]; then
	echo "The path is not a folder"
	exit 1
fi

r_flag=false
r_arg=false
R_flag=false
q_flag=false
p_flag=false
f_flag=false
s_flag=false
e_flag=false

while getopts "hr:Rqpfse" opt; do
	case $opt in
	h)
		help
		exit 0
		;;
	r)
		r_flag=true
		r_arg="$OPTARG"
		;;
	R)
		R_flag=true
		;;
	q)
		q_flag=true
		;;
	p)
		p_flag=true
		;;
	f)
		f_flag=true
		;;
	s)
		s_flag=true
		;;
	e)
		e_flag=true
		;;
	*)
		exit 1
		;;
	esac
done

run "$path" "$r_flag" "$r_arg" "$R_flag" "$q_flag" "$p_flag" "$f_flag" "$s_flag" "$e_flag"
