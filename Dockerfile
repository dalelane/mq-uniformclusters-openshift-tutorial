FROM ibmjava:jre
RUN mkdir /opt/app
COPY mq-jms-ccdt/target/mq-jms-ccdt-0.0.2.jar /opt/app
