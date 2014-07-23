#!/bin/bash

searchd -c /etc/sphinxsearch/bsphinx.conf --nodetach "$@"
