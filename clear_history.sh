#!/usr/bin/env bash
# Author: Clarence Mills
# Clear command line history

# Clear command line history for bash shell
[ -f ~/.bash_history ]; cat /dev/null > ~/.bash_hitory && history -c
