FROM tomcat
RUN rm -rvf /usr/local/tomcat/webapps
RUN mv /usr/local/tomcat/webapps.dist /usr/local/tomcat/webapps
COPY student.war /usr/local/tomcat/webapps/
RUN sed -i 's/8080/8000/g' /usr/local/tomcat/conf/server.xml
CMD /usr/local/tomcat/bin/startup.sh; sleep inf
