sphinxdocker
============

###Give it a Try.###

This is built up from [phusion/baseimage](https://registry.hub.docker.com/u/phusion/baseimage/) (but I'm not really taking advantage of the things it offers... yet).

To play with it just grab these files, open a terminal and build (or, go [here](https://registry.hub.docker.com/u/stefobark/sphinxdocker/) to get it from docker hub):

```
sudo docker.io build -t sphinx . 
```
###Some Introduction###
**Dockerfile**  adds the Sphinx PPA, installs Sphinx, creates some directories, ADDs our .sh files, and exposes port 9306. It'll take a bit to run through the steps but after some time, it should confirm a successful build. 

Run Sphinx in a 'detached' container (daemonized) like so:
```
sudo docker.io run -p 9311:9306 -v /path/to/local/sphinx/conf:/etc/sphinxsearch/ -d sphinx ./indexandsearch.sh
```

The -p 9311:9306 is opening port 9306 to port 9311 on the host machine. Open whatever port you've told searchd to listen to. Then, with -v we're sharing the **/path/to/local/sphinx directory** (which might be the directory you're using for these docker files) with the container's **/etc/sphinxsearch**. This is handy because we can now write the Sphinx configuration file from the host machine.

* **/path/to/local/sphinx/conf** is the location of sphinxy.conf (which is the very basic sphinx configuration file I've provided)
* **/etc/sphinxsearch/** is where the Sphinx instance in the container will expect to find the configuration file. So, now, when we run indexandsearch.sh, Sphinx should have a configuration to work from.

###Persistent Index Data###
If you want index data to persist through container shutdowns, just add another ```-v /some/directory/:/var/lib/sphinx/data/``` to share a directory on your host machine with the default Sphinx data directory within the container.

###.sh Files###
**indexandsearch.sh** runs indexer using **sphinxy.conf** and then runs **searchd.sh** which... starts up searchd.
You might write your own configuration file and point Sphinx to your data source, or edit sphinxy.conf to match your setup. 

Also, it may be helpful to mention that in **indexandsearch.sh**, I'm telling sphinx to index from /etc/sphinxsearch/sphinxy.conf instead of the default **sphinx.conf** (which you should take a look at if you want to see an expanded Sphinx configuration with a bunch of helpful comments about the various options.. or just go read the docs).

###MySQL###
I'm using another container that's running MySQL. To connect to that MySQL container, I just ran ```sudo docker.io inspect <container id>``` got the Gateway address, and put that info into sphinxy.conf. You may also link containers. There's a bunch more fun stuff you can do with environment variables and such.

###Check it Out###
Now, let's make sure it's running:

```sudo docker.io ps```

Then, you should be able to check the Sphinx inside the container with:

```mysql -h0 -P9311```


###Realtime Indexing###
If we defined a realtime index in our configuration file, we could just run **searchd.sh** instead of **indexandsearch.sh** to just get searchd up and running. Although, indexandsearch will work just as well.. It also starts searchd.

###Playing with Distributed Search###
Sometimes it's good to shard your index, or you might want to do agent mirroring for HA/failover. For me, using docker to learn how this works was pretty nice. Convenient. I didn't have to worry about creating a unique PID, or a unique path for index/log files, which would be necessary if you were running multiple Sphinx instances on one machine. 

I started a bunch of Sphinx containers off of one image... many containers with unique names. To edit where searchd listens, and what will be indexed, for each container, I just edited sphinxy.conf before starting it:
```
sudo docker.io run -p 9306:9306 -v /path/to/local/sphinx/conf:/etc/sphinxsearch/ --name sphinx1 -d stefobark/sphinx ./indexandsearch.sh
sudo docker.io run -p 9307:9307 -v /path/to/local/sphinx/conf:/etc/sphinxsearch/ --name sphinx2 -d stefobark/sphinx ./indexandsearch.sh
sudo docker.io run -p 9406:9406 -v /path/to/local/sphinx/conf:/etc/sphinxsearch/ --name sphinx3 -d stefobark/sphinx ./indexandsearch.sh
sudo docker.io run -p 9407:9407 -v /path/to/local/sphinx/conf:/etc/sphinxsearch/ --name sphinx4 -d stefobark/sphinx ./indexandsearch.sh
```

I'm sharding index data. Containers that have ports starting with 93 are all mirrors of each other, they contain the first 100 docs from our datasource. Those listening on 940* are also mirrors of each other, they hold the next 100 docs.

From here, I start up 'lordsphinx':
```
sudo docker.io run -p 9999:9999 -v /path/to/local/sphinx/conf:/etc/sphinxsearch/ --name lordsphinx -d stefobark/sphinx ./lordsearchd.sh
```

It holds the 'distributed' index type, which maps to the other instances of Sphinx. 

Now, I'm trying to figure out how to make this even easier. So, **makelord.sh** was born.

The motivation behind makelord.sh is to detect existing Sphinx containers, grab the port's they're listening on, and create a configuration file that the master node can use. So, running makelord.sh on the host machine will create a Sphinx configuration file for the master node called **bsphinx.conf**. After this file is generated, start the last container, lordsphinx, with **lordsearchd.sh** (which will run Sphinx with bashsphinx.conf). Just an experiment. More messing around to do here.

###Bye Bye###
These are my first steps with Docker. I've got a lot to learn. Just wanted to share.

