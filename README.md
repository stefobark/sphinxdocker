sphinxdocker
============

###give it a try.###

This is built up from [phusion/baseimage](https://registry.hub.docker.com/u/phusion/baseimage/). To play with it just grab these files, open a terminal and build (or, go [here](https://registry.hub.docker.com/u/stefobark/sphinxdocker/) to get it from docker hub):

```
sudo docker.io build -t sphinx . 
```
###some introduction###
I'm using Ubunutu 14.04, so docker is ```docker.io```-- and I didn't change it.. for you, this may not be the case. **Dockerfile**  adds the Sphinx PPA, installs Sphinx, creates some directories, ADDs our .sh files, and exposes port 9306 It'll run through the steps and should eventually tell you that it was succesfully built. 

Run it like so:
```
sudo docker.io run -p 9311:9306 -v /path/to/local/sphinx/conf:/etc/sphinxsearch/ -d sphinx ./indexandsearch.sh
```

It's opening port 9306 to port 9311 on the host machine and sharing the **/var/www/html/sphinx directory** with the container's **/etc/sphinxsearch**. This is handy because can now write the sphinx configuration file from the host machine.

**/path/to/local/sphinx/conf** is the location of sphinxy.conf (which is the very basic sphinx configuration file I've provided), and **/etc/sphinxsearch/** is where the Sphinx instance in the container will expect to find the configuration file. So, now the container should have a Sphinx configuration to work from.

**persistent index data**
If you want index data to persist through container shutdowns, just add another ```-v /some/directory/:/var/lib/sphinx/data/``` to share a directory on your host machine with the default Sphinx data directory within the container.

###.sh files###
**indexandsearch.sh** runs indexer using **sphinxy.conf** and then runs **searchd.sh** which... starts up searchd.
You might write your own configuration file and point Sphinx to your data source, or edit sphinxy.conf to match your setup. Also, it may be helpful to mention that in **indexandsearch.sh**, I'm telling sphinx to index from /etc/sphinxsearch/sphinxy.conf instead of the default **sphinx.conf** (which you should take a look at). The sphinx.conf file that comes with Sphinx is commented, it's helpful to see configuration options in context, and so its nice to have around (that's why sphinxy.conf was born). Edit **indexandsearch.sh** if you want to use some other name, or just delete the -c option to go with the default location.

###MySQL###
I'm using another container that's running MySQL.
To connect to that MySQL container, I just ran ```sudo docker.io inspect <container id>``` got the IP address, and put that info into sphinxy.conf. Not sure this is optimal. I'm thinking of linking the two containers.. or something. 

###check it out###
Now, make sure it's running:

```sudo docker.io ps```

Then, then you should be able to check Sphinx out with:

```mysql -h 0.0.0.0 -P 9311```

###realtime###
If we defined a realtime index in our configuration file, we could just run **searchd.sh** instead of **indexandsearch.sh** to get searchd up and running.

These are my first steps with Docker. I've got a lot to learn. Just wanted to share.

