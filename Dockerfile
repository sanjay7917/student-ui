FROM ubuntu
COPY aws_k8s_setup.sh /tmp
RUN chmod +x /tmp/aws_k8s_setup.sh
RUN sh /tmp/aws_k8s_setup.sh
RUN rm -rvf aws_k8s_setup.sh
