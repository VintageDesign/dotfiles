#!/bin/bash

# Usage: Run `. ros.sh` or `source ros.sh` rather than `./ros.sh` to prevent it from running
# in a subshell. The purpose of this script is to modify the calling environment!

source "/opt/ros/bouncy/setup.bash"
source "$HOME/Documents/school/workspace/install/setup.bash"

# I'm not entirly sure if this is necessary
export RMW_IMPLEMENTATION=rmw_opensplice_cpp
