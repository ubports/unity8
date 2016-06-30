#!/bin/sh

SETUP=false
CLEAN=false
NUM_JOBS=$(( `grep -c ^processor /proc/cpuinfo` + 1 ))
CODE_DIR=$( dirname `readlink -f $0` )

usage() {
    echo "usage: build [OPTIONS] [BUILD_TYPE]\n" >&2
    echo "Script to build the shell. If BUILD_TYPE is not specified, it defaults to \"debug\".\n" >&2
    echo "OPTIONS:" >&2
    echo " -s, --setup Setup the build environment and branch Unity" >&2
    echo " -c, --clean Clean the build tree before building" >&2
    echo >&2
    exit 1
}

ARGS=`getopt -n$0 -u -a --longoptions="setup,clean,help" -o "sch" -- "$@"`
[ $? -ne 0 ] && usage
eval set -- "$ARGS"

while [ $# -gt 0 ]
do
    case "$1" in
       -s|--setup)   SETUP=true;;
       -c|--clean)   CLEAN=true;;
       -h|--help)    usage;;
       --)           shift;break;;
    esac
    shift
done

[ $# -gt 1 ] && usage

BUILD_TYPE="debug"
[ $# -eq 1 ] && BUILD_TYPE="$1"

install_dependencies() {
    sudo apt-get update || exit 4
    echo "Installing Unity 8 dependencies.."
    sudo apt-get install devscripts \
                         equivs \
                         gsettings-desktop-schemas \
                         gsettings-ubuntu-schemas \
                         pay-service \
                         qmenumodel-qml \
                         qml-module-qtquick-layouts \
                         qml-module-qtquick-xmllistmodel \
                         qml-module-ubuntu-components \
                         qml-module-ubuntu-thumbnailer0.1 \
                         qtdeclarative5-gsettings1.0 \
                         qtdeclarative5-ubuntu-settings-components \
                         qtdeclarative5-ubuntu-telephony0.1 \
                         qtdeclarative5-unity-notifications-plugin \
                         qml-module-ubuntu-connectivity \
                         ubuntu-mobile-icons \
                         ubuntu-system-settings \
                         unity-plugin-scopes \
                         xvfb \
        || exit 5
}

mk_build_deps() {
    if [ ! -f control -o $CODE_DIR/debian/control -nt control ]; then
        sed 's/\:native//g' $CODE_DIR/debian/control > control
        mk-build-deps --install --root-cmd sudo control
    fi
}

if [ -f "/usr/bin/ccache" ] ; then
  if [ "x$CC" = "x" ]; then
    export CC='ccache gcc'
  fi
  if [ "x$CXX" = "x" ] ; then
    export CXX='ccache g++'
  fi
fi

if [ -f "/usr/bin/ninja" ] ; then
  GENERATOR="-G Ninja"
  # Ninja does not need -j, it parallelizes automatically.
  BUILD_COMMAND="ninja"
else
  GENERATOR=
  BUILD_COMMAND="make -j$NUM_JOBS"
fi

if $SETUP; then
    install_dependencies
else
    if $CLEAN; then rm -rf builddir; fi
    mkdir -p builddir
    cd builddir
    mk_build_deps
    cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE $CODE_DIR ${GENERATOR} || exit 6
    ${BUILD_COMMAND} || exit 7
fi
