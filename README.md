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

The -p 9311:9306 is opening port 9306 to port 9311 on the host machine. Open whatever port you've told searchd to listen to. Then, with -v we're sharing the **/var/www/html/sphinx directory** with the container's **/etc/sphinxsearch**. This is handy because we can now write the Sphinx configuration file from the host machine.

**/path/to/local/sphinx/conf** is the location of sphinxy.conf (which is the very basic sphinx configuration file I've provided), and **/etc/sphinxsearch/** is where the Sphinx instance in the container will expect to find the configuration file. So, now, when we run indexandsearch.sh, Sphinx should have a configuration to work from.

**persistent index data**
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

###Realtime###
If we defined a realtime index in our configuration file, we could just run **searchd.sh** instead of **indexandsearch.sh** to just get searchd up and running. Although, indexandsearch will work just as well.. It also starts searchd.

###Playing with Distributed Search###
I recently began learning about distributed search with Sphinx. Sometimes it's good to shard your index, or you might want to do agent mirroring for HA/failover. Using docker to learn how to this works was pretty nice. Convenient. I didn't have to worry about creating a unique PID, or a unique path for index/log files, which would be necessary if you were running multiple Sphinx instances locally. Now, I'm trying to figure out how to make this even easier. So, **makelord.sh** was born.

The motivation behind makelord.sh is to detect Sphinx containers, grab the port's they're listening on, and create a configuration file for the final node, "lordsphinx". So, run it on the host machine, it will create a Sphinx configuration file for the master node called **bashsphinx.conf** and then start the last container, lordsphinx, with **indexlord.sh** (which will run Sphinx with bashsphinx.conf and therefore, detect all the distributed indexes!).

###Bye Bye###
These are my first steps with Docker. I've got a lot to learn. Just wanted to share.

