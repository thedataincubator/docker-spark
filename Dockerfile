FROM sequenceiq/hadoop-ubuntu:2.6.0
MAINTAINER The Data Incubator

# Install Spark
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-2.0.0-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-2.0.0-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark
ENV PATH="$SPARK_HOME/bin:${PATH}"

# Configure environment
ENV SHELL /bin/bash
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/$NB_USER
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Create jovyan user with UID=1000 and in the 'users' group
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER

USER $NB_USER

# Setup jovyan home directory
RUN mkdir /home/$NB_USER/work && \
    mkdir /home/$NB_USER/.jupyter && \
    mkdir -p -m 700 /home/$NB_USER/.local/share/jupyter && \
    echo "cacert=/etc/ssl/certs/ca-certificates.crt" > /home/$NB_USER/.curlrc

COPY jupyter_notebook_config.py /home/${NB_USER}/.jupyter/
USER root
RUN chown -R ${NB_USER} /home/${NB_USER}/.jupyter

# Install Pip
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py" && python /tmp/get-pip.py

# Install toree
COPY toree-0.2.0.dev1.tar.gz /tmp/toree-0.2.0.dev1.tar.gz
RUN pip install jupyter
RUN pip install /tmp/toree-0.2.0.dev1.tar.gz
RUN jupyter toree install --spark_opts='--master=local[2] --executor-memory 4g --driver-memory 4g' \
    --kernel_name=apache_toree --interpreters=Scala --spark_home=$SPARK_HOME

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

COPY start-notebook.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/start-notebook.sh

EXPOSE 8888
WORKDIR /home/$NB_USER/work

ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]
# ENTRYPOINT ["jupyter", "notebook", "--no-browser"]
USER $NB_USER