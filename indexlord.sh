#!/bin/bash

/usr/bin/indexer -c /etc/sphinxsearch/bsphinx.conf dist
/usr/bin/searchd -c /etc/sphinxsearch/bsphinx.conf
