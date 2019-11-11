FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y

RUN apt-get install nginx -y

RUN apt-get install curl -y

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get install nodejs -y

RUN apt-get install -y vim-tiny

EXPOSE 80


COPY ./website/ /website/

COPY /default /etc/nginx/sites-enabled/


WORKDIR /website/

RUN npm install


CMD ["/bin/bash", "-c", "/etc/init.d/nginx start & npm run start" ]