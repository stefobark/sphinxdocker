#!/bin/bash

/usr/bin/indexer -c /etc/sphinxsearch/bashsphinx.conf --all
./searchd.sh
