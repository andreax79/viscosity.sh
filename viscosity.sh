#!/usr/bin/env bash
# Copyright (c) 2016, Andrea Bonomi <andrea.bonomi@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
# OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
# CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

display_usage() {
    echo -e "Usage:\n$0 [-q] <command> [arg]\n"
    echo -e "Options:"
    echo -e "-q                                Suppress headers\n"
    echo -e "Commands:"
    echo -e "connect <connection name>         Open the given connection"
    echo -e "connect all                       Open all the connections"
    echo -e "disconnect <connection name>      Close the given connection"
    echo -e "disconnect all                    Close all the connections"
    echo -e "ls                                List all the configured connections"
    echo -e "status                            Display ongoing connections"
    exit 2
}

while [[ $# > 0 ]]; do
    key="$1"
    case $key in
        -q|--quiet)
            QUIET="yes"
        ;;
        -h|--help)
            display_usage
            QUIET="yes"
        ;;
        *)
            REMAINS="$REMAINS \"$1\""
        ;;
    esac
    shift
done
eval set -- $REMAINS

cmd="$1"
arg="$2"

case $cmd in
    status|connections)
        if [ -z "$QUIET" ]; then
           echo "Connection name"
           echo "---------------"
        fi
        osascript -e 'tell application "Viscosity"
          set connames to name of connections where state is equal to "Connected"
          return connames
        end tell
        ' | tr , '\n' | sed 's/^ *//;s/ *$//' | sort
        ;;
    ls|list)
        if [ -z "$QUIET" ]; then
           echo "Connection name"
           echo "---------------"
        fi
        osascript -e 'tell application "Viscosity"
          set connames to name of connections
          return connames
        end tell
        ' | tr , '\n' | sed 's/^ *//;s/ *$//' | sort
        ;;
    connect|connect-all)
        if [ "$arg" == "all" ]; then
            osascript -e 'tell application "Viscosity" to connectall'
        else
            osascript -e "tell application \"Viscosity\" to connect \"$arg\""
        fi
        if [ -z "$QUIET" ]; then
            echo "Connecting $arg"
        fi
        ;;
    disconnect|connect-all)
        if [ "$arg" == "all" ]; then
            osascript -e 'tell application "Viscosity" to disconnectall'
        else
            osascript -e "tell application \"Viscosity\" to disconnect \"$arg\""
        fi
        if [ -z "$QUIET" ]; then
            echo "Disconnecting $arg"
        fi
        ;;
    *)
        display_usage
        ;;
esac

