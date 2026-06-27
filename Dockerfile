FROM cubejs/cube:latest

WORKDIR /cube/conf

COPY cube/cube /cube/conf/

EXPOSE 4000
