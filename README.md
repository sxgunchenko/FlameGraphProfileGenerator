# FlameGraphProfileGenerator

This script is intended to generate flame graph profile info using Linux'
perf tool and **FlameGraph** utility by Brendan Gregg (see
<https://github.com/brendangregg/FlameGraph> for more info)


# Usage

```
sudo ./FlameGraphProfile.sh [options] executable-file [executable-args]
```
\* sudo is needed here because of perf is used


# Options

    --help | -h        Print this message
    --fg-path | -p     Set path to FlameGraph utility
    --width | -w       Set output graph canvas width
    --keep-tmp | -k    Keep (true) or clean (false) temporary files on exit
    --output | -o      Output file name (if not provided will be
                       generated from executable file)
