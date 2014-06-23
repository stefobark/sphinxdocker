sphinxdocker
============

<h3>give it a try.</h3>

This is 'Sphinx-in-a-box". It's built up from <a href="https://registry.hub.docker.com/u/phusion/baseimage/">phusion/baseimage</a> -- an optimized Ubuntu image. To play with it just grab these files, open a terminal, cd to their directory and build:

```
sudo docker.io build -t sphinx . 
```
<h3>some introduction</h3>
I'm using Ubunutu 14.04, so docker is ```docker.io```-- and I didn't change it.. for you, this may not be the case.

```Dockerfile``` adds the Sphinx PPA, installs Sphinx, creates some directories, ADDs our .sh files, and exposes port 9306 

It'll run through the steps and should eventually tell you that it was succesfully built. So, let's run it:
```
sudo docker.io run -p 9311:9306 -v /var/www/html/sphinx/:/etc/sphinxsearch/ -d sphinx ./indexandsearch.sh
```

I'm opening port 9306 to port 9311 on the host machine and sharing the ```/var/www/html/sphinx directory``` with the container's ```/etc/sphinxsearch```. 

```/var/www/html/sphinx``` is where I've put sphinxy.conf, and ```/etc/sphinxsearch/``` is where Sphinx expects the config file to be by default. Now the container should have a Sphinx configuration to work from.

<h3>persistent index data</h3>
If you want index data to persist through container shutdowns, just add another ```-v /some/directory/:/var/lib/sphinx/data/``` to share some directory on your host machine with the default Sphinx index data directory within the container. There's an answer <a href="http://stackoverflow.com/questions/18496940/how-to-deal-with-persistent-storage-e-g-databases-in-docker">here</a> that points to some nice resources on how to use another container to store data, instead of doing this-- storing it on the host machine.

<h3>.sh files</h3>
```indexandsearch.sh``` runs indexer using this config file and then runs ```searchd.sh``` which starts up searchd.
You should write your own configuration file and point Sphinx to your data source, or edit this one to match your setup. 

<h3>MySQL</h3>
I'm using another container that's running MySQL.
To connect to that MySQL container, I just ran ```sudo docker.io inspect <container id>``` got the IP address and port, and put that info into sphinxy.conf. Not sure this is optimal. I'm thinking of linking the two containers. In ```indexandsearch.sh```, I'm telling sphinx to index from this file, instead of the default ```sphinx.conf```. Edit ```indexandsearch.sh``` if you want to use some other name, or the default.

Now, make sure it's running:

```sudo docker.io ps```

Then, then you should be able to check Sphinx out with:

```mysql -h 0.0.0.0 -P 9311```

<h3>realtime</h3>
If we defined a realtime index in our configuration file, we could just run ```searchd.sh``` instead of ```indexandsearch.sh``` to get searchd up and running.

These are my first steps with Docker. I've got a lot to learn. Just wanted to share.

