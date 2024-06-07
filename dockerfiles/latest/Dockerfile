FROM couchbase:enterprise

ENV CB_ADMIN username
ENV CB_ADMIN_PASSWORD password
ENV CB_SERVICES "data,index,query"

COPY ./rootfilesystem /

CMD ["/entrypoint2.sh"]
