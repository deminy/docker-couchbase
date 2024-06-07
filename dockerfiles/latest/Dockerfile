FROM couchbase:enterprise

ENV CB_ADMIN username
ENV CB_ADMIN_PASSWORD password
ENV CB_CLUSTER_RAM_SIZE 256
ENV CB_BUCKETS test
ENV CB_SERVICES "data,index,query"

COPY ./rootfilesystem /

CMD ["/entrypoint2.sh"]
