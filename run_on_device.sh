#!/bin/bash
CODE_DIR=shell
USER=phablet
USER_ID=32011
PACKAGE=unity8
BINARY=unity8
TARGET_IP=127.0.0.1
TARGET_SSH_PORT=2222
TARGET_DEBUG_PORT=3768
RUN_OPTIONS=-qmljsdebugger=port:$TARGET_DEBUG_PORT
SETUP=false
GDB=false
PINLOCK=false
KEYLOCK=false
NUM_JOBS='$(( `grep -c ^processor /proc/cpuinfo` + 1 ))'
FLIPPED=false
SSH_WAS_STARTED=0
SSH_STARTED=0
PASSWORD=""
PASSFILE=""

usage() {
    echo "usage: run_on_device -a SUDO_PASSWORD [OPTIONS]"
    echo
    echo "Script to setup a build environment for the shell and sync build and run it on the device"
    echo
    echo "OPTIONS:"
    echo "  -a The sudo password to use"
    echo "  -s Setup the build environment"
    echo "  -g Run with gdb"
    echo "  -p Enable a PIN lock screen when running"
    echo "  -k Enable a Keyboard lock screen when running"
    echo ""
    echo "IMPORTANT:"
    echo " * Make sure to have networking setup on the device beforehand."
    echo " * Execute that script from a directory containing unity8 code."
    exit 1
}

start_ssh() {
    if [ $SSH_STARTED -eq 0 ]; then
        adb_sudo initctl start ssh
        SSH_STARTED=1
    fi
}

exec_with_ssh() {
    start_ssh
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t $USER@$TARGET_IP -p $TARGET_SSH_PORT sudo -u $USER -i bash -ic \"$@\"
}

adb_sudo() {
    adb shell "SUDO_ASKPASS=${PASSFILE} sudo --askpass $@"
}

install_ssh_key() {
    HOME_DIR="/home/phablet"
    adb push ~/.ssh/id_rsa.pub $HOME_DIR/.ssh/authorized_keys
    adb shell chmod 700 $HOME_DIR/.ssh
    adb shell chmod 600 $HOME_DIR/.ssh/authorized_keys
}

setup_adb_forwarding() {
    adb forward tcp:$TARGET_SSH_PORT tcp:22
    adb forward tcp:$TARGET_DEBUG_PORT tcp:$TARGET_DEBUG_PORT
}

install_dependencies() {
    adb_sudo apt-get update
    adb_sudo apt-get -y --force-yes install build-essential rsync bzr ccache gdb ninja-build devscripts equivs unity-plugin-scopes
}

sync_code() {
    [ -e .bzr ] && bzr export --uncommitted --format=dir /tmp/$CODE_DIR
    [ -e .git ] && git checkout-index -a -f --prefix=/tmp/$CODE_DIR/
    start_ssh
    rsync -crlOzv --delete --exclude builddir -e "ssh -p $TARGET_SSH_PORT -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" /tmp/$CODE_DIR/ $USER@$TARGET_IP:$CODE_DIR/
    rm -rf /tmp/$CODE_DIR
}

build() {
    exec_with_ssh PATH=/usr/lib/ccache:$PATH "cd $CODE_DIR/ && PATH=/usr/lib/ccache:$PATH ./build.sh"
}

run() {
    ARGS="--nomousetouch"
    if $GDB; then
        ARGS="$ARGS --gdb"
    fi
    if $PINLOCK; then
        ARGS="$ARGS -p"
    fi
    if $KEYLOCK; then
        ARGS="$ARGS -k"
    fi

    exec_with_ssh "stop unity8"
    exec_with_ssh "start maliit-server"
    exec_with_ssh "cd $CODE_DIR/ && ./run.sh $ARGS -- $RUN_OPTIONS"
    exec_with_ssh "stop maliit-server"
    exec_with_ssh "start unity8"
}

while getopts "a:sgpkh" OPTION; do
    case "$OPTION" in
       a|password) PASSWORD=$OPTARG;;
       s|setup)   SETUP=true;;
       g|gdb)     GDB=true;;
       p|pinlock)     PINLOCK=true;;
       k|keylock)     KEYLOCK=true;;
       h|help)    usage;;
       ?)         echo;usage;;
    esac
done

shift $((OPTIND - 1))

if [ -z "${PASSWORD}" ]; then
    echo "ERROR: You need to provide a sudo password..."
    echo
    usage
fi

PASSFILE=$( adb shell "FILE=\`mktemp\`
                       echo \"#!/bin/sh\" > \$FILE
                       echo \"echo \\\"${PASSWORD}\\\"\" >> \$FILE
                       chmod +x \$FILE
                       echo \$FILE" | tr -d '\r' )

setup_adb_forwarding

status_output=$(adb_sudo initctl status ssh)
if [[ $status_output == "ssh start/running, process "* ]]; then
    SSH_WAS_STARTED=1
fi
SSH_STARTED=$SSH_WAS_STARTED

if $SETUP; then
    echo "Setting up environment for building shell.."
    install_ssh_key
    install_dependencies
    sync_code
else
    echo "Transferring code.."
    sync_code
    echo "Building.."
    build
    echo "Running.."
    run
fi

adb shell "rm ${PASSFILE}"

if [ $SSH_WAS_STARTED -eq 0 ]; then
    adb_sudo initctl stop ssh
fi
