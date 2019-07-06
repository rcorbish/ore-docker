
FROM ubuntu:cosmic


RUN \
	apt-get -y update && \
	apt-get -y install git build-essential libboost-all-dev autoconf wget python3 && \
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

#
# This is where notebooks are stored
# probably you should start the container and map this externally
# docker run -v my-local-drive:/notebooks
VOLUME /notebooks
WORKDIR /notebooks

#
# Setup anaconda - we want python 3.6 so use anaconda 3 
#
RUN \
	cd && \
	wget --no-verbose https://repo.continuum.io/archive/Anaconda3-5.3.0-Linux-x86_64.sh && \
	chmod 0750 Anaconda3-5.3.0-Linux-x86_64.sh && \
	./Anaconda3-5.3.0-Linux-x86_64.sh -b && \
	./anaconda3/bin/conda install -y -c conda-forge matplotlib && \
	./anaconda3/bin/conda install -y -c conda-forge ipywidgets && \
	./anaconda3/bin/conda install -y -c conda-forge jupyter_dashboards && \
	./anaconda3/bin/jupyter-dashboards quick-setup --sys-prefix && \
	./anaconda3/bin/jupyter notebook  --generate-config && \
	rm Anaconda3-5.3.0-Linux-x86_64.sh

#
# Download some sample files from ORE github
# Need to replace the shared Input dir with a local one
#
RUN \
	mkdir -p /root/example/Input && \
	cd /root/example/Input && \
	wget --no-verbose https://github.com/OpenSourceRisk/Engine/raw/master/Examples/Example_1/Input/netting.xml && \
	wget --no-verbose https://github.com/OpenSourceRisk/Engine/raw/master/Examples/Example_1/Input/ore.xml && \
	wget --no-verbose https://github.com/OpenSourceRisk/Engine/raw/master/Examples/Example_1/Input/portfolio_swap.xml && \
	wget --no-verbose https://github.com/OpenSourceRisk/Engine/raw/master/Examples/Example_1/Input/simulation.xml && \
	sed -i -e "s/..\/..\/Input\///" ore.xml && \
#
# Common files used for examples
#
	wget --no-verbose https://github.com/OpenSourceRisk/Engine/raw/master/Examples/Input/conventions.xml && \
	wget --no-verbose https://github.com/OpenSourceRisk/Engine/raw/master/Examples/Input/curveconfig.xml && \
	wget --no-verbose https://github.com/OpenSourceRisk/Engine/raw/master/Examples/Input/fixings_20160205.txt && \
	wget --no-verbose https://github.com/OpenSourceRisk/Engine/raw/master/Examples/Input/market_20160205_flat.txt && \
	wget --no-verbose https://github.com/OpenSourceRisk/Engine/raw/master/Examples/Input/market_20160205.txt && \
	wget --no-verbose https://github.com/OpenSourceRisk/Engine/raw/master/Examples/Input/pricingengine.xml && \
	wget --no-verbose https://github.com/OpenSourceRisk/Engine/raw/master/Examples/Input/todaysmarket.xml 

#
# Setup jupyter config
# It supports https and a custom css
#
ADD jupyter_notebook_config.py /root/.jupyter/
ADD run_jupyter.sh /root/
ADD mycert.pem /root/.jupyter/
ADD custom.css /root/.jupyter/custom/
ADD ore_jupyter_dashboard.ipynb /root/example/

# ORE install instructions says this is needed so just do it
ENV LC_NUMERIC=C LANG=en_US LC_ALL=en_US PYTHONPATH=/root/anaconda3

# By default the password to the notebook is this
# By running the container with a parameter the password can be changed e.g.
# 	docker run rcorbish/ore new-passwd
CMD [ "monkeys" ]

#
# Comment this to switch main program - e.g. if you want to run a shell to debug
#
ENTRYPOINT [ "/root/run_jupyter.sh" ]

