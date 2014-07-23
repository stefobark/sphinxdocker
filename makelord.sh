#!bin/bash

#find all mirrors, all mirrored nodes will be listening on 93** ... be sure to start node containers on 93**

	mirrors=$(sudo docker.io inspect $(sudo docker.io ps | awk '{if(NR>1)print $1}') | grep HostPort | grep -o '[0-9]*' | grep ^93 | uniq)

#get the bridge, for connecting to the various nodes running in the containers

	bridge=$(sudo docker.io inspect $(sudo docker.io ps | awk '{if(NR>1)print $1}') | grep -m 1 Gateway | grep  -o '[0-9.]*')

#start printing bsphinx.conf, end with 'agent=' and then..

	printf "index dist\n{\ntype=distributed\nagent=" >> bsphinx.conf

#for each node, print the bridge and port separated by a |

	for port in ${mirrors[@]}; do
	printf "%s" "$bridge:$port|" >> bsphinx.conf
	done

#append index name for this set of mirrored agents

	printf "test\n" >> bsphinx.conf

#to add another shard, with another set of agent mirrors, uncomment this and change "grep ^93" to match the starting numbers for this set of mirrors.. make sure that each set of mirrors starts with unique #s

#	shard=$(sudo docker.io inspect $(sudo docker.io ps | awk '{if(NR>1)print $1}') | grep HostPort | grep -o '[0-9]*' | grep ^94 | uniq)
#	shard1=$(sudo docker.io inspect $(sudo docker.io ps | awk '{if(NR>1)print $1}') | grep HostPort | grep -o '[0-9]*' | grep ^94 | uniq)

#... keep adding if necessary.

#if there are more shards, uncomment this stuff and print lines for each new set of mirrored agents. if there are more sets of mirrored agents, copy and paste this block below and change 'shard' to 'shard1' 'shard2' ... or whatever you want to call it.

#	printf "agent=" >> bsphinx.conf

#	for shardport in ${shard[@]}; do
#	printf "%s" "$bridge:$shardport|" >> bsphinx.conf
#	done
#	printf "test\n" >> bsphinx.conf
#append the index name

# set ha_strategy to nodeads, end the index definition section.

	printf "\nha_strategy=nodeads\n}" >> bsphinx.conf

#find lines with 'agent', change the last | to a : because we're going to append the index name that occurs in all these mirrors

	grep agent bsphinx.conf | sed -i 's/\(.*\)|/\1:/' bsphinx.conf

#spit out searchd settings, listen on 9306 for mysql protocol. now mysql -h0 -P9999 to talk to lordsphinx from the command line

	printf "\nsearchd\n{\nlisten=9999:mysql41\nlog=/var/log/sphinx/searchd.log\nquery_log=/var/log/sphinx/query.log\nquery_log_format=sphinxql\nread_timeout=5\nmax_children=30\npid_file=/var/run/sphinx/searchd.pid\nworkers=threads\n}" >> bsphinx.conf

#let's see the conf file, make sure it's what we want.

	grep "." bsphinx.conf
