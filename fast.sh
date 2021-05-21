#!/usr/bin/env bash

TARGET_DIR="target"
SRC_DIR="src"

WORKING_DIR=$(pwd)
UP_TRAVERSAL=3

usage() {
        echo -e "\e[1m================ Help ================\e[0m"
        echo "Usage: $0 <command>"
        echo "Commands:"
        echo -e "    \e[1mcmake\e[0m   runs cmake in target dir"
        echo -e "    \e[1mbuild\e[0m   runs cmake --build target"
        echo -e "    \e[1mstatus\e[0m  prints some status information"
        echo -e "    \e[1mclean\e[0m   rm -rf ./target"
        echo -e "    \e[1m<bin>\e[0m   executes <bin> in target dir"
        echo -e "    \e[1mhelp\e[0m    show this screen"
        exit 2
}

info() {
        echo -e "\e[32mINFO\e[0m: $1"
}

error() {
        echo -e "\e[31mERR\e[0m : $1"
}

for ((i = 0; i <= $UP_TRAVERSAL; i++)); do
        if [[ -f "$WORKING_DIR/CMakeLists.txt" ]]; then
                break
        fi
        if [[ $i == $UP_TRAVERSAL ]]; then
                error "CMakeLists.txt does not exist in the upper $UP_TRAVERSAL dir(s)"
                usage
        fi
        WORKING_DIR=$(realpath "$WORKING_DIR/..")
done

info "Found CMakeLists.txt in $WORKING_DIR"
cd $WORKING_DIR

case $1 in
cmake)
        mkdir -p $TARGET_DIR
        cd $TARGET_DIR
        cmake ../.
        ;;
build)
        cmake --build $TARGET_DIR
        ;;
status)
        EXECUTABLES=$(find $TARGET_DIR -maxdepth 1 -perm -111 -type f)
        info "Found executables:"
        while IFS= read -r exec; do
                echo "    "$exec
        done <<< "$EXECUTABLES"
        ;;
clean)
        rm -rf $TARGET_DIR
        info "Removed $WORKING_DIR/$TARGET_DIR"
        ;;
help)
        usage
        ;;
*)
        EXECUTABLES=$(find $TARGET_DIR -maxdepth 1 -perm -111 -type f)
        while IFS= read -r exec; do
                if [[ $exec == "$TARGET_DIR/$1" ]]; then
                        info "Executing: $exec"
                        $exec
                        exit 0
                fi
        done <<< "$EXECUTABLES"

        cmd=$1
        if [[ $1 == "" ]]; then
                cmd="<null>"
        fi
        error "Unknown command: $cmd"
        usage
        ;;
esac

