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
# file: examples/equality_test.sh
# This shell script only uses one bashism -> process substituition
# The rest is posix compliant

usage() {
	echo "Usage: $0"
	echo
	echo 'Options:'
	echo ' -h, --help                                         Print this help page'
	echo ' -f, --fail-on-first                                Exits on the first failed unit test (default: false)'
	echo ' -m, --metas, --goals        <Metas>                List of comma separated goal numbers (default: 1,2,3)'
	echo ' -b, --binary, --compiler    <Compiler Path>        Path to the go compiler (default: ./bin/deigoc)'
	echo ' -t, --test-dir              <Test Dir Base Path>   Path to base of tests (default: ./tests)'
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
	echo "$0 --metas=1,2 --fail-on-first"
	echo "$0 --fail-on-first | less"
	exit 1
}

fail_on_first=false
metas=1,2,3
compiler=./bin/deigoc
test_dir=./tests

passed=0
passed_tests=
failed=0
failed_tests=

options='hfm:b:t:'
long_options='help,fail-on-first,metas:,goals:,binary:,compiler:,test-dir:'
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

testMessage() {
	if [ "$?" -eq 0 ]
	then
		printf '\033[32m[PASSED]\033[0m: %s\n' "$1"
		passed=$((passed + 1))
		passed_tests="$passed_tests $1"
		return 0
	else
		printf '\033[31m[FAILED]\033[0m: %s\n' "$1"
		failed=$((failed + 1))
		failed_tests="$failed_tests $1"
		return 1
	fi
}

diff() {
	bash -c 'diff --brief '"$1"' <('"$compiler"' < '"$2"') >/dev/null'

	if ! testMessage "$2"
	then
		bash -c 'diff --color=always --side-by-side <('"$compiler"' < '"$2"') '"$1"''
		$fail_on_first && exit 1
	fi
}

unit_test() {
	meta_n="$1"
	test_name="$2"
	file_base="$test_dir"/"meta$meta_n"/"$test_name"
	diff "$file_base.out" "$file_base.dgo"
}

finish() {
	echo
	printf 'Total tests done: %d\n' "$((passed + failed))"
	printf '\033[032mPASSED:\033[0m %d\n' "$passed"
	for t in $passed_tests
	do
		printf '  \033[32m\033[0m %s\n' "$t"
	done

	printf '\033[031mFAILED:\033[0m %d\n' "$failed"
	for t in $failed_tests
	do
		printf '  \033[31m✗\033[0m %s\n' "$t"
	done
}


for meta in $(seq 1 3)
do
	echo "$metas" | grep --quiet "$meta" || continue
	test_meta_dir="$test_dir/meta$meta"
	[ ! -d "$test_meta_dir" ] && continue

	for t in $(find "$test_meta_dir" -type f -printf '%f\n' | grep --only-matching '^[^\.]\+\.dgo' | sort --unique | cut --delimiter='.' --fields=1)
	do
		unit_test "$meta" "$t"
	done
done

test $failed = 0
