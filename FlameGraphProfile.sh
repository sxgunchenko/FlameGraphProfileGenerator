#!/bin/sh

# path to Flame Graph utility
FLAMEGRAPH_PATH="./FlameGraph"
# if set temporary files will not be cleaned up on exit
KEEP_TEMP_FILES=false
# output graph width
OUTPUT_WIDTH=1200
# output file name
OUTPUT_FILE_NAME=""


usage()
{
    message=\
"\
    This script is intended to generate flame graph profile info using Linux'
    perf tool and FlameGraph utility by Brendan Gregg (see
    <https://github.com/brendangregg/FlameGraph> for more info)

    Usage: sudo ./FlameGraphProfile.sh [options] executable-file [executable-args]

    Options:
        --help | -h        Print this message
        --fg-path | -p     Set path to FlameGraph utility
        --width | -w       Set output graph canvas width
        --keep-tmp | -k    Keep (true) or clean (false) temporary files on exit
        --output | -o      Output file name (if not provided will be
                           generated from executable file)
\
"

    echo "$message"
}


# parse arguments
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        --help | -h)
            usage
            exit
            ;;
        --fg-path | -p)
            FLAMEGRAPH_PATH=$VALUE; ;;
        --width | -w)
            OUTPUT_WIDTH=$VALUE; ;;
        --keep-tmp | -k)
            KEEP_TEMP_FILES=$VALUE; ;;
        --output | -o)
            OUTPUT_FILE_NAME=$VALUE; ;;
        --* | -*)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
        *)
            break ;;
    esac
    shift
done


# generate output file name from command name, if it was not specified
if [ "" = "$OUTPUT_FILE_NAME" ]; then
    OUTPUT_FILE_NAME=$(basename "$1")
fi


# catch SIGINT from user
trap 'echo "$1 was interrupted"' INT

# run the program to be profiled
"$@"

# cancel signal trap
trap - INT


# generate stuff
echo "Generating output..."

echo "Making trace output from perf data..."
perf script > out.perf
echo "Trace output done"

echo "Collapsing stack traces..."
"$FLAMEGRAPH_PATH"/stackcollapse-perf.pl out.perf > out.folded
echo "Collapse done"

echo "Making flame graph..."
"$FLAMEGRAPH_PATH"/flamegraph.pl --hash --width="$OUTPUT_WIDTH" out.folded > "$OUTPUT_FILE_NAME".svg
echo "Flame graph done"

if [ "$KEEP_TEMP_FILES" = false ]; then
    echo "Cleaning temporary files..."
    rm out.perf out.folded > /dev/null
    echo "Cleaning done"
fi
