from ubuntu:zesty

run \
	apt-get -y update && \
	apt-get -y install git build-essential libboost-all-dev autoconf wget python && \
	git clone https://github.com/opensourcerisk/engine.git ore && \
	cd ore && \
	git submodule init && \
	git submodule update && \
	cd QuantLib && \
	./autogen.sh && \
	./configure  && \
	make -j4 && \
	cd ../QuantExt && \
	./autogen.sh && \
	./configure && \
	make -j4 && \	
	cd ../OREData && \
	./autogen.sh && \
	./configure && \
	make -j4 && \	
	cd ../OREAnalytics && \
	./autogen.sh && \
	./configure && \
	make -j4 && \
	cd ../App && \
	./autogen.sh && \
	./configure && \
	make -j4 

VOLUME /saved
WORKDIR /saved

run \
	cd && \
	wget --no-verbose https://repo.continuum.io/archive/Anaconda2-5.0.1-Linux-x86_64.sh && \
	chmod 0750 Anaconda2-5.0.1-Linux-x86_64.sh && \
	./Anaconda2-5.0.1-Linux-x86_64.sh -b && \
	./anaconda2/bin/conda install -y -c conda-forge matplotlib && \
	./anaconda2/bin/conda install -y -c conda-forge ipywidgets && \
	./anaconda2/bin/conda install -y -c conda-forge jupyter_dashboards && \
	./anaconda2/bin/jupyter-dashboards quick-setup --sys-prefix && \
	./anaconda2/bin/conda install -y -c conda-forge bqplot && \
	./anaconda2/bin/conda install -y -c conda-forge pythreejs
	
ENV LC_NUMERIC=C LANG=en_US LC_ALL=en_US PYTHONPATH=/root/anaconda2

CMD [ "/root/anaconda2/bin/jupyter-notebook", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--no-browser", "--NotebookApp.token='monkey99'" ]

