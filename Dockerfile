# ./mvnw clean package
#sudo docker build -f Dockerfile . -t webgoat/webgoat
#sudo docker run -it -p 127.0.0.1:8080:8080 -p 127.0.0.1:9090:9090 -e TZ=Australia/Sydney webgoat/webgoat
#sudo docker run -it --name webgoat_mc --rm -d -p 80:8080 -p 9090:9090 -e WEBGOAT_HOST=0.0.0.0 -e TZ=Australia/Sydney webgoat/webgoat

FROM docker.io/eclipse-temurin:17-jdk-focal

RUN useradd -ms /bin/bash webgoat
RUN chgrp -R 0 /home/webgoat
RUN chmod -R g=u /home/webgoat
RUN mkdir /home/webgoat/cs-client

USER webgoat

COPY --chown=webgoat target/webgoat-*.jar /home/webgoat/webgoat.jar
COPY --chown=webgoat target/webgoat-*.jar /home/webgoat/webgoat.jar
COPY --chown=webgoat contrast/contrast-agent*.jar /home/webgoat/cs-client/contrast-agent.jar
COPY --chown=webgoat contrast/contrast_security.yaml /home/webgoat/cs-client/contrast_security.yaml

ENV CONTRAST_OPTS "-javaagent:/home/webgoat/cs-client/contrast-agent.jar \
-Dcontrast.config.path=/home/webgoat/cs-client/contrast_security.yaml"

ENV JAVA_TOOL_OPTIONS $CONTRAST_OPTS \
-DcontactEmail=fatdunky@gmail.com,contactName=Mark \
-Dcontrast.application.group=APP_GROUP

EXPOSE 8080
EXPOSE 9090

WORKDIR /home/webgoat

ENTRYPOINT [ "java", \
   "-Duser.home=/home/webgoat", \
   "-Dfile.encoding=UTF-8", \
   "--add-opens", "java.base/java.lang=ALL-UNNAMED", \
   "--add-opens", "java.base/java.util=ALL-UNNAMED", \
   "--add-opens", "java.base/java.lang.reflect=ALL-UNNAMED", \
   "--add-opens", "java.base/java.text=ALL-UNNAMED", \
   "--add-opens", "java.desktop/java.beans=ALL-UNNAMED", \
   "--add-opens", "java.desktop/java.awt.font=ALL-UNNAMED", \
   "--add-opens", "java.base/sun.nio.ch=ALL-UNNAMED", \
   "--add-opens", "java.base/java.io=ALL-UNNAMED", \
   "--add-opens", "java.base/java.util=ALL-UNNAMED", \
   "-Drunning.in.docker=true", \
   "-Dwebgoat.host=0.0.0.0", \
   "-Dwebwolf.host=0.0.0.0", \
   "-Dwebgoat.port=8080", \
   "-Dwebwolf.port=9090", \
   "-jar", "webgoat.jar" ]
