#!/usr/bin/env bash
set -x
export this_dir=$(cd -P $(dirname $0) ; pwd)
export this_tmpdir=${this_dir}/tmpdir
mkdir -p ${this_tmpdir}

# This may not work depending on the length of the path of this repo
#
#     export TMPDIR=${this_tmpdir}
#
# If using a different TMPDIR so Emacs creates sockets somewhere else, then
# that value of TMPDIR must be short enough or else Emacs will hang on the
# "Starting Emacs daemon." part.
#
# It seems to be a "Socket name too long" thing even though it doesn't say so
# when launching the daemon.  If we forget that launching the daemon didn't
# work and we do `TMPDIR=${this_tmpdir} emacsclient -s basic-socket -t .`, then
# emacsclient fails with the message 
#
#     "Socket name # ${TMPDIR}/emacs1234/basic-socket too long"
#
# This stops happening if I move everything directly in my HOME which makes the
# paths shorter.

main(){
    for arg in "$@" ; do
        if [[ "${arg}" == -h ]] ; then
            print_help
            exit 0
        fi
    done
    dir=${1%%/} ; shift
    action=$1 ; shift
    socket_name=$(basename "${dir}")-socket
    test_dir=${this_tmpdir}/$(basename ${dir})

    case "${action}" in
        -s)
            if [[ -d "${test_dir}" ]] || [[ -f "${test_dir}" ]] ; then
                echo "Cannot create test directory: Already exists"
            fi
            cp -R "${dir}" "${test_dir}"
            emacs --daemon=${socket_name} --init-directory "${test_dir}" "$@" ;;

        -e) cp -R "${dir}" "${test_dir}"
            emacs --init-directory "${test_dir}" "$@"
            ask_delete_dir "${test_dir}" ;;

        -c) emacsclient -s ${socket_name} "$@" ;;

        -k) emacsclient -s ${socket_name} -t -c -e '(save-buffers-kill-emacs)'
            ask_delete_dir "${test_dir}" ;;
    esac

    # Some of the configs I test do stuff with the cursor so this should
    # reset it to normal in xterm compatible terminal emulators and do nothing
    # in terminal emulators that don't support it.
    printf "\033]112\007\033[2 q"
}

ask_delete_dir(){
    local dir="$1"
    if ! [[ -d "${test_dir}" ]] ; then
        echo "Warning ${test_dir} is not a directory"
        return 1
    fi

    read -p "Remove directory $(realpath $dir)? [y/n]" answer
    if [[ ${answer} == y ]] ; then
        rm -rf $(realpath $dir)
    fi
}

print_help(){
    cat <<-EOF
Test emacs with a copy of DIRECTORY.  The copy is named testing-${DIRECTORY}.
The copy is made to test package installation.
	daemon:      $0 DIRECTORY -s
	emacs:       $0 DIRECTORY -e [EMACS_ARGS ...]
	emacsclient: $0 DIRECTORY -c [EMACSCLINET_ARGS ...]
	stop         $0 DIRECTORY -k
EOF
}

main "$@"
