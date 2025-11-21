ARG FLINK_IMAGE=ghcr.io/apache/flink-kubernetes-operator:b40c553

FROM ${FLINK_IMAGE}

# https://mvnrepository.com/artifact/org.apache.flink/flink-gs-fs-hadoop/1.20.1
ARG JAR_PATH=https://repo1.maven.org/maven2/org/apache/flink/flink-gs-fs-hadoop/1.20.1/flink-gs-fs-hadoop-1.20.1.jar

USER root

ADD ${JAR_PATH} /opt/flink/plugins/flink-gs-fs-hadoop/flink-gs-fs-hadoop-1.20.1.jar
RUN chmod 644 /opt/flink/plugins/flink-gs-fs-hadoop/flink-gs-fs-hadoop-1.20.1.jar && \
    chown -R flink: /opt/flink/plugins/flink-gs-fs-hadoop

USER flink
