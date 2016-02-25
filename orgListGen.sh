#!/bin/sh
curl http://osl.umbc.edu/orgs/list/ | grep orgs/detail -A 6 | perl -ne'BEGIN {$/ = "--\n"}' -e'm{detail/(\d*)"}; print $1, "\t";' -e'm{-name">(.*)\s*</span>$}m; print $1, "\t";' -e'm{-cat">(.*)</span>$}m; print $1, "\n";' | sort -s -n -k 1,1
