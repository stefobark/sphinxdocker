FROM stefo/sphinx:test

RUN apt-get update
RUN apt-get -y install software-properties-common
RUN apt-get update
RUN add-apt-repository -y ppa:builds/sphinxsearch-beta
RUN apt-get update
RUN apt-get -y install sphinxsearch
RUN mkdir /var/lib/sphinx
RUN mkdir /var/lib/sphinx/data
RUN mkdir /var/log/sphinx
RUN mkdir /var/run/sphinx
ADD indexandsearch.sh /
RUN chmod a+x indexandsearch.sh
ADD searchd.sh /
RUN chmod a+x searchd.sh

EXPOSE 9306
