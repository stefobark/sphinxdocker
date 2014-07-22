#!bin/bash

#find all mirrors, all mirrored nodes will be listening on 93** ... be sure to start node containers on 93**

	mirrors=$(sudo docker.io inspect $(sudo docker.io ps | awk '{if(NR>1)print $1}') | grep HostPort | grep -o '[0-9]*' | grep ^93 | uniq)

#get the bridge, for connecting to the various nodes running in the containers

	bridge=$(sudo docker.io inspect $(sudo docker.io ps | awk '{if(NR>1)print $1}') | grep -m 1 Gateway | grep  -o '[0-9.]*')

#start printing bashsphinx.conf, end with 'agent=' and then..

	printf "index test\n{\ntype=distributed\nagent=" >> bashsphinx.conf

#for each node, print the bridge and port separated by a |

	for port in ${mirrors[@]}; do
	printf "%s" "$bridge:$port|" >> bashsphinx.conf
	done

#append index name for this set of mirrored agents

	printf "test\n" >> bashsphinx.conf

#to add another shard, with another set of agent mirrors, uncomment this and change "grep ^93" to match the starting numbers for this set of mirrors.. make sure that each set of mirrors starts with unique #s

	shard=$(sudo docker.io inspect $(sudo docker.io ps | awk '{if(NR>1)print $1}') | grep HostPort | grep -o '[0-9]*' | grep ^94 | uniq)
	#shard1=$(sudo docker.io inspect $(sudo docker.io ps | awk '{if(NR>1)print $1}') | grep HostPort | grep -o '[0-9]*' | grep ^94 | uniq)

#... keep adding shards if necessary.

#if there are more shards, uncomment this stuff and print lines for each new set of mirrored agents. if there are more sets of mirrored agents, copy and paste this block below and change 'shard' to 'shard1' 'shard2' ... or whatever you want to call it.

	#printf "agent=" >> bashsphinx.conf

	#for shardport in ${shard[@]}; do
	#printf "%s" "$bridge:$shardport|" >> bashsphinx.conf
	#done
	#printf "test\n" >> bashsphinx.conf

# set ha_strategy to nodeads, end the index definition section.

	printf "ha_strategy=nodeads\n}" >> bashsphinx.conf

#find lines with 'agent', change the last | to a : because we're going to append the index name that occurs in all these mirrors

	grep agent bashsphinx.conf | sed -i 's/\(.*\)|/\1:/' bashsphinx.conf

#spit out searchd settings, listen on 9306 for mysql protocol. now mysql -h0 -P9306 to talk to lordsphinx from the command line

	printf "\nsearchd\n{\nlisten=9999:mysql41\nlog=/var/log/sphinx/searchd.log\nquery_log=/var/log/sphinx/query.log\nquery_log_format=sphinxql\nread_timeout=5\nmax_children=30\npid_file=/var/run/sphinx/searchd.pid\nworkers=threads\n}" >> bashsphinx.conf

#let's see the conf file, make sure it's what we want.

	printf "\n\n\t\t\t:::::::::::::::::::::\n\t\t\t:::bashsphinx.conf:::\n\t\t\t:::::::::::::::::::::\n\n\n"

	grep "." bashsphinx.conf
