#!/bin/bash
VERSION="v0.1.0"

show_help() {
    echo "Usage: internsctl [COMMANDS] [OPTIONS]"
    echo "COMMANDS:"
    echo "  --version                           Get Version Information"
    echo "  cpu getinfo                         Get CPU information"
    echo "  memory getinfo                      Get memory information"
    echo "  user create <username>              Create a new user"
    echo "  user list [--sudo-only]             List users (optionally, only those with sudo)"
    echo "  file getinfo <file_name> [OPTIONS]  Get file information"
    echo
    echo "  OPTIONS for file getinfo:"
    echo "      --size, -s                    Get file size"
    echo "      --permissions, -p             Get file permissions"
    echo "      --owner, -o                   Get file owner"
    echo "      --last-modified, -m           Get last modified time"
}

show_version() {
    echo "internsctl $VERSION"
}

cpu_getinfo() {
    lscpu
}

memory_getinfo() {
    free
}

user_create() {
    if [ -z "$1" ]; then
        echo "Error: No username provided."
        exit 1
    fi
    sudo useradd "$1"
    echo "User '$1' created."
}

user_list() {
    if [ "$1" == "--sudo-only" ]; then
        getent group sudo >/dev/null 2>&1 && getent group sudo | awk -F: '{print $4}' || getent group wheel | awk -F: '{print $4}'
    else
        getent passwd | awk -F: '$3 >= 1000 {print $1}'
    fi
}

#./FILE.sh file getinfo <FILENAME> <OPTIONS>
file_getinfo() {
    if [ -z "$2" ]; then
        echo "Error: No file provided."
        exit 1
    fi
    if [ ! -e "$2" ]; then
        echo "Error: File '$2' does not exist."
        exit 1
    fi

    # echo "0" "$0"
    # echo "1" "$1"
    # echo "2" "$2"    
    # echo "3" "$3"
    
    case $3 in
        "--size")
            stat -c %s "$2" ;;
        "-s")
            stat -c %s "$2" ;;
        "--permissions")
            stat -c %A "$2";;
        "-p")
            stat -c %A "$2";;
        "--owner")
            stat -c %U "$2";;
        "-o")
            stat -c %U "$2";;
        "--last-modified")
            stat -c %y "$2";;
        "-m")
            stat -c %y "$2";;
        *)
           echo "File: $(basename "$2")"
           echo "Access: $(stat -c %A "$2")"
           echo "Size(B): $(stat -c %s "$2")"
           echo "Owner: $(stat -c %U "$2")"
           echo "Modify: $(stat -c %y "$2")"
           ;;
    esac
}

invalid_command() {
    echo "Invalid command: $1"
    show_help
    exit 1
}

case "$1" in
    --help) 
        show_help ;;
    --version) 
        show_version ;;
    cpu) 
        shift; cpu_getinfo ;;
    memory) 
        shift; memory_getinfo ;;
    user) 
        shift
        case "$1" in
            create) shift; user_create "$@" ;;
            list) shift; user_list "$@" ;;
            *) invalid_command "$1" ;;
        esac
        ;;
    file) 
        shift; file_getinfo "$@" ;;
    *) 
        invalid_command "$1" ;;
esac
