FROM sequenceiq/hadoop-ubuntu:2.6.0
MAINTAINER The Data Incubator

# Install Spark
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-2.0.0-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-2.0.0-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark
ENV PATH="$SPARK_HOME/bin:${PATH}"

# Install Pip
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py" && python /tmp/get-pip.py

# INstall toree
COPY toree-0.2.0.dev1.tar.gz /tmp/toree-0.2.0.dev1.tar.gz
RUN pip install jupyter
RUN pip install /tmp/toree-0.2.0.dev1.tar.gz
RUN jupyter toree install --spark_opts='--master=local[2] --executor-memory 4g --driver-memory 4g' \
    --kernel_name=apache_toree --interpreters=Scala --spark_home=$SPARK_HOME

EXPOSE 8888
