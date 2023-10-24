ARG COUCHBASE_VERSION

FROM couchbase:enterprise-${COUCHBASE_VERSION}

ENV CB_ADMIN username
ENV CB_ADMIN_PASSWORD password
ENV CB_BUCKET test
ENV CB_BUCKET_RAM_SIZE 256
ENV CB_SERVICES "data,index,query,fts"

COPY ./rootfilesystem /

CMD ["/entrypoint2.sh"]
