FROM tomcat:7.0
RUN apt-get update && apt-get install -y \
    netcat \
  && rm -rf /var/lib/apt/lists/*
# COPY ./webapps/*.war /usr/local/tomcat/webapps/
