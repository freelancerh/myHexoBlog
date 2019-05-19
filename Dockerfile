FROM node

COPY . /usr/src/app
WORKDIR /usr/src/app

RUN npm install -g hexo
RUN npm install
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone
EXPOSE 4000
CMD hexo server