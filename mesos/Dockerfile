FROM magneticio/vamp-base:0.8.0

ENV LD_LIBRARY_PATH /usr/local/lib

RUN apt-get update && \
    apt-get install -y autoconf libtool build-essential git python-dev python-boto libcurl4-nss-dev libsasl2-dev maven libapr1-dev libsvn-dev && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/mesos-master && \
    echo in_memory | sudo dd of=/etc/mesos-master/registry && \
    cd /usr/local && \
    git clone http://git-wip-us.apache.org/repos/asf/mesos.git mesos && \
    cd /usr/local/mesos && \
    git checkout tags/0.25.0 && \
    ./bootstrap && \
    mkdir build && cd build && ../configure && \
    make -j 4 V=0 && make install && ldconfig && \
    rm -Rf /usr/local/mesos
