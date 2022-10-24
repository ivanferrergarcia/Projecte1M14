FROM ubuntu:20.04

#Feim un update del sistema i instalam el supervisor
RUN apt update -y && apt install supervisor -y

#Instalam el Python 3.10
RUN apt upgrade -y
RUN apt install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt update -y
RUN apt install python3.10 -y
RUN python3.10 --version

#Instalam el servei ssh
RUN apt-get -y install openssh-server  
RUN systemctl enable ssh
RUN service ssh start

#Instalam el servidor apache2
RUN apt install ufw -y
RUN apt install apache2 -y
RUN apt-get install iptables -y
RUN ufw allow 'Apache'

#Instalam el MySQL
RUN apt install mysql-server -y

#Configuració del Supervisord
RUN touch /etc/supervisor/conf.d/supervisord.conf
RUN echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf
RUN echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf

#Configuració del Apache2 amb supervisord
RUN echo "[program:apache2]" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "command= /usr/sbin/apache2ctl -DFOREGROUND" >> /etc/supervisor/conf.d/supervisord.conf

#Configuració del SSH amb supervisord
RUN echo "[program:ssh]" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "command= /usr/sbin/sshd -D" >> /etc/supervisor/conf.d/supervisord.conf

#Configuració del MySQL
RUN echo "[program:mysql]" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "command=/usr/bin/pidproxy /var/run/mysql/mysql.pid /etc/init.d/mysql start" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "autostart=true" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "user=root" >> /etc/supervisor/conf.d/supervisord.conf

EXPOSE 9001 22 80 443 3306
CMD ["/usr/bin/supervisord"]
