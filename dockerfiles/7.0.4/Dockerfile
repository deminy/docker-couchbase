FROM couchbase/server:enterprise-7.0.4

ENV CB_ADMIN username
ENV CB_ADMIN_PASSWORD password
ENV CB_BUCKET test
ENV CB_BUCKET_RAM_SIZE 256
ENV CB_SERVICES "data,index,query,fts"

COPY ./rootfilesystem /

CMD ["/entrypoint2.sh"]
