#!/usr/bin/env bash
# @see https://docs.couchbase.com/server/5.5/install/install-ports.html Network and Firewall Requirements

set -e

CB_CLUSTER="127.0.0.1:8091"
CB_CLI="/opt/couchbase/bin/couchbase-cli"

if [[ -z "$CB_BUCKETS" ]] && [[ -z "$CB_BUCKET" ]] ; then
    CB_BUCKETS=test
fi
if [[ -z "$CB_BUCKETS" ]] && [[ ! -z "$CB_BUCKET" ]] ; then
    # Environment variable CB_BUCKET was used when the image supports only one bucket, as in Couchbase image 7.2.1 and
    # below.
    #
    # Starting from Couchbase image 7.2.2, environment variable CB_BUCKET is deprecated. Please use environment variable
    # CB_BUCKETS instead.
    CB_BUCKETS="$CB_BUCKET"
    unset CB_BUCKET
fi
# Remove extra spaces before/after commas and leading/trailing spaces
CLEANED_CB_BUCKET_NAMES=$(echo "$CB_BUCKETS" | sed 's/ *, */,/g' | sed 's/^ *//;s/ *$//')
# Convert the cleaned string to an array, removing empty items
IFS=',' read -ra ARRAY_CLEANED_CB_BUCKET_NAMES <<< "$CLEANED_CB_BUCKET_NAMES"
CB_BUCKET_NAMES=()
for CB_BUCKET_NAME in "${ARRAY_CLEANED_CB_BUCKET_NAMES[@]}"; do # Iterate through the array
    CB_BUCKET_NAME=$(echo "$CB_BUCKET_NAME" | sed 's/^ *//;s/ *$//') # Trim leading and trailing spaces from each item
    if [[ -n "$CB_BUCKET_NAME" ]]; then # Check if the item is not empty
        CB_BUCKET_NAMES+=("$CB_BUCKET_NAME")
    fi
done
if [[ ${#CB_BUCKET_NAMES[@]} -eq 0 ]] ; then
    echo "ERROR: Environment variable CB_BUCKETS or CB_BUCKET doesn't have valid bucket name(s) properly defined."
    exit 1
fi

if [[ -z "$CB_CLUSTER_RAM_SIZE" ]] && [[ -z "$CB_BUCKET_RAM_SIZE" ]] ; then
    CB_CLUSTER_RAM_SIZE=256
fi
if [[ -z $CB_CLUSTER_RAM_SIZE ]] && [[ ! -z $CB_BUCKET_RAM_SIZE ]] ; then
    # Environment variable CB_BUCKET_RAM_SIZE was used when the image supports only one bucket, as in Couchbase image
    # 7.2.1 and below.
    #
    # Starting from Couchbase image 7.2.2, environment variable CB_BUCKET_RAM_SIZE is deprecated. Please use environment
    # variable CB_CLUSTER_RAM_SIZE instead.
    CB_CLUSTER_RAM_SIZE=$((CB_BUCKET_RAM_SIZE * ${#CB_BUCKET_NAMES[@]}))
else
    CB_BUCKET_RAM_SIZE=$((CB_CLUSTER_RAM_SIZE / ${#CB_BUCKET_NAMES[@]}))
fi
if (( CB_BUCKET_RAM_SIZE < 100 )) ; then
    echo "Error: RAM quota for each bucket in Couchbase cannot be less than 100 MiB."
    exit 1
fi

if [[ -z "$CB_ADMIN" ]] || [[ -z "$CB_ADMIN_PASSWORD" ]] || [[ -z "$CB_SERVICES" ]] ; then
    echo "ERROR: Please define the following environment variable(s) before running this container:
             CB_ADMIN
             CB_ADMIN_PASSWORD
             CB_SERVICES"
    exit 1
fi

/entrypoint.sh couchbase-server &

while ! curl -sf --output /dev/null http://$CB_CLUSTER ; do
    sleep 2
done

set -x

# @see https://docs.couchbase.com/server/6.6/cli/cbcli/couchbase-cli-server-list.html
if [[ -z `$CB_CLI server-list -c $CB_CLUSTER -u $CB_ADMIN -p $CB_ADMIN_PASSWORD | grep $CB_CLUSTER` ]] ; then
    # @see https://docs.couchbase.com/server/6.6/cli/cbcli/couchbase-cli-cluster-init.html
     $CB_CLI cluster-init                        \
         --cluster          $CB_CLUSTER          \
         --cluster-username $CB_ADMIN            \
         --cluster-password $CB_ADMIN_PASSWORD   \
         --cluster-ramsize  $CB_CLUSTER_RAM_SIZE \
         --services         $CB_SERVICES
else
    echo Skipping auto configuration looks like there is a cluster \"$CB_CLUSTER\" already created.
fi

for CB_BUCKET_NAME in "${CB_BUCKET_NAMES[@]}"; do # Iterate through the array
    # @see https://docs.couchbase.com/server/6.6/cli/cbcli/couchbase-cli-bucket-list.html
    if [[ -z `$CB_CLI bucket-list -c $CB_CLUSTER -u $CB_ADMIN -p $CB_ADMIN_PASSWORD | grep $CB_BUCKET_NAME` ]] ; then
        # @see https://docs.couchbase.com/server/6.6/cli/cbcli/couchbase-cli-bucket-create.html
        $CB_CLI bucket-create                      \
            --cluster          $CB_CLUSTER         \
            --username         $CB_ADMIN           \
            --password         $CB_ADMIN_PASSWORD  \
            --bucket           $CB_BUCKET_NAME     \
            --bucket-type      couchbase           \
            --bucket-ramsize   $CB_BUCKET_RAM_SIZE \
            --compression-mode off                 \
            --enable-flush     1                   \
            --wait
    else
        echo Skipping auto configuration looks like there is a bucket \"$CB_BUCKET_NAME\" already created.
    fi
done

# @see https://serverfault.com/a/972760 The right way to keep docker container started when it used for periodic tasks.
while :; do :; done & kill -STOP $! && wait $!
