FROM maven:3.3.3-jdk-8

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y git npm && \
  apt-get clean all

RUN npm install -g bower grunt

RUN git clone https://github.com/IshmeetKaur/zeppelin.git /usr/local/zeppelin
WORKDIR /usr/local/zeppelin
RUN git checkout pysparkmatplotlib

RUN mvn clean package -Pspark-1.6 -Phadoop-2.6 -DskipTests

RUN rm -rf /var/lib/apt/lists/* && \
  apt-get update && \
  apt-get install -y gettext && \
  apt-get install -y sudo && \
  apt-get clean all

RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.6.2-bin-hadoop2.6.tgz | tar -xz -C /usr/local
RUN mv /usr/local/spark* /usr/local/spark

RUN rm -rf conf

COPY conf.templates conf.templates

VOLUME ["/usr/local/zeppelin/notebooks"]
VOLUME ["/usr/local/zeppelin/conf"]
VOLUME ["/hive"]

EXPOSE 8080

COPY start-zeppelin.sh bin

ENTRYPOINT ["bin/start-zeppelin.sh"]
