FROM ubuntu
COPY aws_k8s_setup.sh /tmp
RUN chmod +x /tmp/aws_k8s_setup.sh
RUN sh /tmp/aws_k8s_setup.sh
RUN rm -rvf aws_k8s_setup.sh
COPY k8s_manifest /tmp
WORKDIR /tmp/k8s_manifest

# FROM tomcat 
# RUN rm -rvf /usr/local/tomcat/webapps
# RUN mv /usr/local/tomcat/webapps.dist /usr/local/tomcat/webapps
# COPY target/studentapp-2.2-SNAPSHOT.war /usr/local/tomcat/webapps
# RUN mv /usr/local/tomcat/webapps/studentapp-2.2-SNAPSHOT.war /usr/local/tomcat/webapps/student.war
# ENTRYPOINT ["sh", "/usr/local/tomcat/bin/startup.sh"]

