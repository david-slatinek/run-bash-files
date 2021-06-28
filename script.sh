#!/bin/bash
#Run sh files found at [path] with {flags}

help() {
	echo "NAME"
	echo -e "\tRun Bash Files"
	echo -e "\tRuns all sh files found at [path]"
	echo -e "\tIf only specific files are required to run, check -r flag\n"

	echo -e "SYNOPSIS"
	echo -e "\tbash script.sh <flags> [path]"
	echo -e "\tchmod +x script.sh => ./script.sh <flags> [path]"

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
	echo -e "\tPrint path and filename before running the file"

	echo "-f"
	echo -e "\tPrint path and filename without running the file"

	echo "-s"
	echo -e "\tPrint statistics"

	printf '%s\n' "-e"
	echo -e "\tPrint errors when running files"
}

run() {
	path=$1

	# -r flag => regex
	if [[ $2 = true ]]; then
		# Custom regex
		regex=".*/$3"
	else
		# All .sh files
		regex=".*/*.sh"
	fi

	# -R flag => recursive
	# Finds all files in a specified directory
	if [[ $4 = true ]]; then
		# Recursive mode
		files=$(find "$path" -type f -regex "$regex")
	else
		# Only specified directory
		files=$(find "$path" -maxdepth 1 -type f -regex "$regex")
	fi

	# -f flag => print path and filename without running the file
	if [[ $7 = true ]]; then
		printf "%s\n" "$files"
		exit 0
	fi

	local -i numberOfSuccessful=0
	local -i numberOfErrors=0

	for file in $files; do
		# -p flag => print path and filename before running the file
		if [[ $6 = true ]]; then
			echo "Executing $file"
		fi

		# -q flag => quiet mode
		if [[ $5 = true ]]; then
			bash "$file" >/dev/null
		else
			bash "$file"
		fi

		# The last file ran successfully
		if [[ $? -eq 0 ]]; then
			((numberOfSuccessful++))
		else
			# The last file didn't run successfully
			((numberOfErrors++))
			# -e flag => print errors
			if [[ $9 = true ]]; then
				echo "Error when running $file"
			fi
		fi

		# -q flag => quiet mode
		if [[ $5 = false ]]; then
			printf "\n"
		fi
	done

	# -s flag => print statistics
	if [[ $8 = true ]]; then
		echo -e "\nNumber of scripts: $((numberOfSuccessful + numberOfErrors))"
		echo -e "Successfully executed scripts: $numberOfSuccessful"
		echo -e "Number of errors: $numberOfErrors"
	fi
}

# Flags were not given or path was not specified
if [[ -z "$*" ]]; then
	help
	exit 0
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
		printf "\n"
		help
		exit 1
		;;
	esac
done

shift $((OPTIND - 1))
path=$1

if [[ ! -e $path ]]; then
	echo "The path does not exist or was not specified"
	exit 1
elif [[ ! -d $path ]]; then
	echo "The path is not a folder"
	exit 1
fi

run "$path" "$r_flag" "$r_arg" "$R_flag" "$q_flag" "$p_flag" "$f_flag" "$s_flag" "$e_flag"
