#!/bin/bash

/usr/bin/indexer -c /etc/sphinxsearch/sphinxy.conf test
./searchd.sh

