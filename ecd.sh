#!/bin/bash

# First argument is a directory that will be used as the user-emacs-directory
# If second argument is -s, then start the emacs daemon
#
user_emacs_directory=$(cd $1 && pwd)
shift

if ! [ -e ${user_emacs_directory}/init.el ] ; then
    echo "ERROR: No init.el in user_emacs_directory ($1 must be the path of an emacs config dir)"
    exit 1
fi

# Be careful if your shell startup sets a different TMPDIR (for example
#     export TMPDIR=/tmp/${USER}/$$ # They do this at my work :(
#     mkdir -p $TMPDIR
# because your emacsclient in a different shell will have a different value of
# TMPDIR and won't be able to find the socket.
#
# Or we can use an absolute filename.  It is important that the directory have
# the right permissions.  When socket doesn't contain a slash, emacs creates
# $TMPDIR/emacs$(id -u) with 700 permissions.  If socket contains a slash and is
# not inside a 700 directory, emacs will complain and not start the server.
this_dir=$(cd -P $(dirname $0) && pwd)
socket_dir=${this_dir}/emacs-sockets
mkdir -p ${socket_dir}
chmod 700 ${socket_dir}
socket_name=$(basename $user_emacs_directory)-socket
socket=${socket_dir}/${socket_name}

# Intercept for certain first arguments
case $1 in
    -s)
        emacs --daemon=$socket \
              -q \
              --eval "(setq user-emacs-directory \"${user_emacs_directory}/\")" \
              --eval "(setq user-init-file \"${user_emacs_directory}/init.el\")" \
              --eval "(setq package-user-dir \"${user_emacs_directory}/elpa\")" \
              -l $user_emacs_directory/init.el \
              --eval "(message \"'ecd.sh ${user_emacs_directory} -s'(emacs --daemon): Everything was loaded\")"
        exit 0
        ;;
esac

emacsclient -s $socket "$@"
