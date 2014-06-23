sphinxdocker
============

<h3>Give it a try.</h3>

Grab these files, open a terminal, cd to their directory and build:

```shell
sudo docker.io build -t sphinx . 
```

I'm using Ubunutu 14.04, so docker is "docker.io"-- and I didn't change it.. for you, this may not be the case.

It'll run through the steps and should eventually tell you that it was succesfully built. So, let's run it:
```
sudo docker.io run -p 9311:9306 -v /var/www/html/sphinx/:/etc/sphinxsearch/ -d sphinx ./indexandsearch.sh "
```
I'm opening port 9306 to port 9311 on the host machine and sharing the ```/var/www/html/sphinx directory```with the container's ```/etc/sphinxsearch```.

This is where I've put sphinxy.conf, and where Sphinx expects the config file to be by default. Now the container should have a Sphinx configuration to work from.

indexandsearch.sh runs indexer using this config file and then runs searchd.sh which starts up searchd.
You should write your own configuration file and point Sphinx to your data source, or edit this one to match your setup. 

In my case, I'm using another container that's running MySQL.
To connect to that MySQL container, I just ran ```sudo docker.io inspect <container id>``` got the IP address and port, and put that info into sphinxy.conf. In indexandsearch.sh, I'm telling sphinx to index from this file, instead of the default 'sphinx.conf'. Edit indexandsearch if you want to use some other name, or the default.

Now, make sure it's running:

```sudo docker.io ps```

Then, then you should be able to check Sphinx out with:

```mysql -h 0.0.0.0 -P 9311```

These are my first steps with Docker. I've got a lot to learn. Just wanted to share.

