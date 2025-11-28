FROM nginx:alpine


RUN rm /etc/nginx/conf.d/*

COPY nginx.conf /etc/nginx/conf.d/default.conf


COPY . /usr/share/nginx/html


EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]