# Version: 0.0.1
FROM ubuntu:trusty

MAINTAINER Xing Fu "bio.xfu@gmail.com"

RUN apt-get update; \
    apt-get install -y libboost-filesystem-dev libboost-iostreams-dev libboost-thread-dev libgsl0-dev zlib1g-dev liblzma-dev build-essential wget libmotif4 libxt-dev libgl1-mesa-glx r-base r-base-dev; \
    apt-get clean; \
    apt-get autoremove; \
    wget ftp://ftp.gwdg.de/pub/grafik/dislin/linux/i586_64/dislin-11.1.linux.i586_64.deb; \
    dpkg -i dislin-11.1.linux.i586_64.deb; \
    rm dislin-11.1.linux.i586_64.deb

RUN wget https://excellmedia.dl.sourceforge.net/project/shore/Release_0.9/shore-0.9.3.tar.gz; \
    tar zxf shore-0.9.3.tar.gz; \
    cd shore-0.9.3; \
    ./configure; \
    make; \
    cp shore /usr/local/bin

RUN mkdir SHOREmap_v3.6; \
    wget http://bioinfo.mpipz.mpg.de/shoremap/SHOREmap_v3.6.tar.gz; \
    gzip -d zxf SHOREmap_v3.6.tar.gz; \
    tar xvf SHOREmap_v3.6.tar -C SHOREmap_v3.6; \
    cd SHOREmap_v3.6; \
    make; \
    cp SHOREmap /usr/local/bin

RUN wget https://jaist.dl.sourceforge.net/project/bio-bwa/bwa-0.7.17.tar.bz2; \
    tar jxf bwa-0.7.17.tar.bz2; \
    cd bwa-0.7.17; \
    make; \
    cp bwa /usr/local/bin

VOLUME ["/data"]

WORKDIR /data

CMD ["/bin/bash"]
