FROM quay.io/operator-framework/ansible-operator:v1.9.0

COPY requirements.yml ${HOME}/requirements.yml
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible

USER root

RUN yum clean all && rm -rf /var/cache/yum/* \
 && yum install -y python38-psycopg2 \
 && yum clean all \
 && rm -rf /var/cache/yum 
 
USER 1001

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
