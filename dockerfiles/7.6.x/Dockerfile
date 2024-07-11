ARG COUCHBASE_VERSION

FROM couchbase:enterprise-${COUCHBASE_VERSION}

ENV CB_ADMIN username
ENV CB_ADMIN_PASSWORD password
ENV CB_SERVICES "data,index,query"

COPY ./rootfilesystem/entrypoint2.sh /entrypoint2.sh

CMD ["/entrypoint2.sh"]
