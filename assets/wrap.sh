#!/usr/bin/env bash
LEN=$(head -n1 $1 | wc -c)
echo world width is $(echo "$LEN / 2" | bc -l)
sed -e "s/^/{/" -e "s/$/},/" $1
