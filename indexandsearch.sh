#!/bin/bash

/usr/bin/indexer -c /etc/sphinxsearch/sphinxy.conf --all
./searchd.sh

