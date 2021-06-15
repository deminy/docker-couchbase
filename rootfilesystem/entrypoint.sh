#!/usr/bin/env bash
# @see https://docs.couchbase.com/server/5.5/install/install-ports.html Network and Firewall Requirements

set -xm

untilsuccess() {
    "$@"
    while [[ $? -ne 0 ]] ; do
        echo Waiting for Couchbase to initilize...
        sleep 1
        echo Retrying...
        "$@"
    done
}

CB_CLUSTER="127.0.0.1:8091"
CB_CLI="/opt/couchbase/bin/couchbase-cli"

if [[ -z $CB_ADMIN ]] || [[ -z $CB_ADMIN_PASSWORD ]] || [[ -z $CB_BUCKET ]] || [[ -z $CB_BUCKET_RAM_SIZE ]] ; then
    echo "No couchbase variables defined skipping automatic configuration!! Please Define the following:
             CB_ADMIN
             CB_ADMIN_PASSWORD
             CB_BUCKET
             CB_BUCKET_RAM_SIZE"
fi

runsvdir-start &

set +e
untilsuccess curl -s $CB_CLUSTER > /dev/null
set -e

# @see https://docs.couchbase.com/server/5.5/cli/cbcli/couchbase-cli-server-list.html
if [[ -z `$CB_CLI server-list -c $CB_CLUSTER -u $CB_ADMIN -p $CB_ADMIN_PASSWORD | grep $CB_CLUSTER` ]] ; then
    # @see https://docs.couchbase.com/server/5.5/cli/cbcli/couchbase-cli-cluster-init.html
     untilsuccess $CB_CLI cluster-init          \
         --cluster          $CB_CLUSTER         \
         --cluster-username $CB_ADMIN           \
         --cluster-password $CB_ADMIN_PASSWORD  \
         --cluster-ramsize  $CB_BUCKET_RAM_SIZE \
         --services         $CB_SERVICES
else
    echo Skipping auto configuration looks like there is a cluster \"$CB_CLUSTER\" already created.
fi

# @see https://docs.couchbase.com/server/5.5/cli/cbcli/couchbase-cli-bucket-list.html
if [[ -z `$CB_CLI bucket-list -c $CB_CLUSTER -u $CB_ADMIN -p $CB_ADMIN_PASSWORD | grep $CB_BUCKET` ]] ; then
    # @see https://docs.couchbase.com/server/6.5/cli/cbcli/couchbase-cli-bucket-create.html
    untilsuccess $CB_CLI bucket-create         \
        --cluster          $CB_CLUSTER         \
        --username         $CB_ADMIN           \
        --password         $CB_ADMIN_PASSWORD  \
        --bucket           $CB_BUCKET          \
        --bucket-type      couchbase           \
        --bucket-ramsize   $CB_BUCKET_RAM_SIZE \
        --compression-mode off                 \
        --enable-flush     1
else
    echo Skipping auto configuration looks like there is a bucket \"$CB_BUCKET\" already created.
fi

fg 1
