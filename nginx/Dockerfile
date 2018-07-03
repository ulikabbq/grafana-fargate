FROM nginx:1.13.9-alpine

RUN rm /etc/nginx/conf.d/default.conf
ADD grafana.template /etc/nginx/conf.d/grafana.template

EXPOSE 80

CMD ["/bin/sh","-c", "envsubst '${SERVER_NAME}' < /etc/nginx/conf.d/grafana.template > /etc/nginx/conf.d/grafana.conf; nginx -g 'daemon off;'"]
