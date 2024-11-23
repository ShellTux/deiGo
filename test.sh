#!/bin/sh
############################################################################
# Project                                        _      _  ____
#                                             __| | ___(_)/ ___| ___
#                                            / _` |/ _ \ | |  _ / _ \
#                                           | (_| |  __/ | |_| | (_) |
#                                            \__,_|\___|_|\____|\___/
#
#
#
# Author: Luís Góis
#
# This software is licensed as described in the file LICENSE, which
# you should have received as part of this distribution.
#
# You may opt to use, copy, modify, merge, publish, distribute and/or sell
# copies of the Software, and permit persons to whom the Software is
# furnished to do so, under the terms of the LICENSE file.
#
# This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
# KIND, either express or implied.
#
############################################################################

usage() {
	echo "Usage: $0"
	echo
	echo 'Options:'
	echo ' -h, --help                                         Print this help page'
	echo ' -f, --fail-on-first                                Exits on the first failed unit test (default: false)'
	echo ' -m, --metas, --goals        <Metas>                List of comma separated goal numbers (default: 1,2,3)'
	echo ' -b, --binary, --compiler    <Compiler Path>        Path to the go compiler (default: ./bin/deigoc)'
	echo ' -t, --test-dir              <Test Dir Base Path>   Path to base of tests (default: ./tests)'
	echo ' -C, --color                 <never|always|auto>    Enable Color output (default: auto)'
	echo ' -s, --summary                                      Brief summary printing only the list of passing and failing tests'
	echo
	echo 'Test Directory Structure:'
	echo '<Test Dir Base Path>'
	echo '├── meta1'
	echo '│   ├── example1.dgo'
	echo '│   └── example1.out'
	echo '├── meta2'
	echo '│   ├── example2.dgo'
	echo '│   └── example2.out'
	echo '└── meta3'
	echo '    ├── example3.dgo'
	echo '    └── example3.out'
	echo
	echo Examples:
	echo "$0 --metas=1 --color=always | less --pattern='FAILED'"
	echo "$0 --metas=1,2 --fail-on-first"
	echo "$0 --fail-on-first | less"
	exit 1
}

color=auto
compiler=./bin/deigoc
fail_on_first=false
flags='lts'
metas=1,2,3
summary=false
temp_file=/tmp/deigo-temp
test_dir=./tests

passed=0
passed_tests=
failed=0
failed_tests=

options='hfm:b:t:C:s'
long_options='help,fail-on-first,metas:,goals:,binary:,compiler:,test-dir:,color:,summary'
TEMP=$(getopt \
	--options $options \
	--long  $long_options \
	--name "$(basename "$0")" -- "$@")

# shellcheck disable=SC2181
if [ $? -ne 0 ]
then
	echo 'Terminating...' >&2
	exit 1
fi

# Note the quotes around "$TEMP": they are essential!
eval set -- "$TEMP"
unset TEMP

while true
do
	case "$1" in
		-h | --help)
			usage
			;;
		-f | --fail-on-first)
			fail_on_first=true
			shift
			continue
			;;
		-m | --metas | --goals)
			metas="$2"
			shift 2
			continue
			;;
		-b | --binary | --compiler)
			compiler="$2"
			shift 2
			continue
			;;
		-t | --test-dir)
			test_dir="$2"
			shift 2
			continue
			;;
		-C | --color)
			color="$2"
			shift 2
			continue
			;;
		-s | --summary)
			summary=true
			shift
			continue
			;;
		--)
			shift
			break
			;;
		*) # Option not dealt with
			echo 'Internal error!' >&2
			exit 1
			;;
	esac
done

trap finish EXIT

color_text() {
	code="$1"
	shift
	text="$*"

	case "$color" in
		never) printf '%s' "$text" ;;
		auto) test -t 1 && printf '\033[%dm%s\033[0m' "$code" "$text" || printf '%s' "$text"  ;;
		always) printf '\033[%dm%s\033[0m' "$code" "$text" ;;
	esac
}

testMessage() {
	if [ "$?" -eq 0 ]
	then
		passed=$((passed + 1))
		passed_tests="$passed_tests $1"
		if ! $summary
		then
			color_text 32 '[PASSED]'
			printf ': %s\n' "$1"
		fi
		return 0
	else
		failed=$((failed + 1))
		failed_tests="$failed_tests $1"
		if ! $summary
		then
			color_text 31 '[FAILED]'
			printf ': %s\n' "$1"
		fi
		return 1
	fi
}

diff_posix() {
	diff_args=
	for arg
	do
		if (echo "$arg" | grep --quiet --extended-regexp --only-matching '^(-{1,2}[a-zA-Z]+)')
		then
			diff_args="$diff_args $arg"
			shift
		fi
	done

	"$compiler" -"$flag" < "$1" > "$temp_file"

	# shellcheck disable=SC2086
	command diff $diff_args "$temp_file" "$2"
}

diff() {
	diff_posix --brief "$1" "$2" >/dev/null

	if ! testMessage "$1" && ! $summary
	then
		diff_posix --color="$color" --side-by-side "$1" "$2"
		$fail_on_first && exit 1
	fi
}

unit_test() {
	meta_n="$1"
	test_name="$2"
	file_base="$test_dir"/"meta$meta_n"/"$test_name"
	diff "$file_base.dgo" "$file_base.out"
}

finish() {
	! $summary && echo

	if [ "$passed" -gt 0 ]
	then
		printf 'Total tests done: %d\n' "$((passed + failed))"
		color_text 32 'PASSED:'
		printf ' %d\n' "$passed"
		for t in $passed_tests
		do
			printf '  '
			color_text 32 
			printf ' %s\n' "$t"
		done
	fi

	if [ "$failed" -gt 0 ]
	then
		color_text 31 'FAILED:'
		printf ' %d\n' "$failed"
		for t in $failed_tests
		do
			printf '  '
			color_text 31 ✗
			printf ' %s\n' "$t"
		done
	fi
}

flag=

for meta in $(seq 1 3)
do
	echo "$metas" | grep --quiet "$meta" || continue
	test_meta_dir="$test_dir/meta$meta"
	[ ! -d "$test_meta_dir" ] && continue

	flag="$(echo "$flags" | cut --characters="$meta")"

	for t in $(find "$test_meta_dir" -type f -printf '%f\n' \
		| grep --only-matching '^[^\.]\+\.dgo' \
		| sort --unique \
		| cut --delimiter='.' --fields=1)
	do
		unit_test "$meta" "$t"
	done
done

test $failed = 0
