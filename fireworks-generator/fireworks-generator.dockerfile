FROM maven:3.6.0-jdk-8 AS builder

RUN mkdir /gitroot
ENV FIREWORKS_SRC_VERSION=master

WORKDIR /gitroot/
RUN git clone https://github.com/reactome-pwp/fireworks-layout.git
WORKDIR /gitroot/fireworks-layout
RUN git checkout $FIREWORKS_SRC_VERSION
RUN mvn clean compile package -DskipTests && ls -lht ./target

# Now, rebase on the Reactome Neo4j image
FROM reactome/reactome-neo4j:R-67 as graphdb

ARG NEO4J_USER=neo4j
ENV NEO4J_USER=$NEO4J_USER
ARG NEO4J_PASSWORD=neo4j-password
ENV NEO4J_PASSWORD=$NEO4J_PASSWORD
ENV NEO4J_AUTH $NEO4J_USER/$NEO4J_PASSWORD
# Neo4j extension script setting
ENV EXTENSION_SCRIPT /data/neo4j-init.sh

COPY --from=builder /gitroot/fireworks-layout/target/fireworks-jar-with-dependencies.jar /fireworks/fireworks.jar
COPY --from=builder /gitroot/fireworks-layout/config /fireworks/config
COPY ./wait-for.sh /wait-for.sh
COPY ./run_fireworks_generator.sh /run_fireworks_generator.sh

RUN chmod a+x /run_fireworks_generator.sh
RUN mkdir /fireworks-json-files
RUN /run_fireworks_generator.sh
