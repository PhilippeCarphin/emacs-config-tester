#!/usr/bin/env -S bash -o errexit -o nounset

PS4='+ \033[35m${BASH_SOURCE[0]}\033[36m:\033[1;37m${FUNCNAME:+${FUNCNAME[0]}}\033[22;36m:\033[32m${LINENO}\033[36m:\033[0m'
set -x

this_dir=$(cd -P $(dirname $0) && pwd)

rm -rf ${this_dir}/test_dir
mkdir ${this_dir}/test_dir

cp ${this_dir}/init.el ${this_dir}/test_dir/init.el

${this_dir}/ecd.sh ${this_dir}/test_dir -s

${this_dir}/ecd.sh ${this_dir}/test_dir -t ${this_dir}/init.el

${this_dir}/ecd.sh ${this_dir}/test_dir --eval "(kill-emacs)"
