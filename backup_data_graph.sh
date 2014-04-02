#!/bin/bash

DATESTR=$(date +"%Y%m%d%H%M%S")
LOCAL_BACKUP_DIR=/home/rails/db_backups/dsi

function fetch_ntriples() {
    FILE_NAME="$LOCAL_BACKUP_DIR/$1"
    GRAPH_URI=$2

    SOURCE_URI=http://46.4.78.148/dsi/data?graph=$GRAPH_URI

    curl -s -H "Accept:text/plain" -f -o $FILE_NAME $SOURCE_URI
    CURL_STATUS=$?

    if [ $CURL_STATUS -ne 0 ]; then
        echo "Failed to fetch URL with curl: $SOURCE_URI"
        echo "Backup Failed to Complete."
        exit 1
    fi

    gzip $FILE_NAME
    echo "Downloaded & Gzipped triples to $FILE_NAME"
}

function upload_to_s3() {
    FNAME=$1
    FILE_NAME="$LOCAL_BACKUP_DIR/$FNAME.gz"
    s3cmd put -P $FILE_NAME s3://digitalsocial-dumps
    S3_STATUS=$?
    if [ $S3_STATUS -ne 0 ]; then
        echo "Failed to put backup on S3"
        echo "Backup Failed to Complete."
        exit 2
    fi
    echo "Copied $FILE_NAME to S3"
}

# For backup purposes
function set_modified_date() {
    query=`printf 'WITH <http://data.digitalsocial.eu/graph/organizations-and-activities/metadata>
DELETE {?ds <http://purl.org/dc/terms/modified> ?mod}
INSERT {?ds <http://purl.org/dc/terms/modified> "%s"^^<http://www.w3.org/2001/XMLSchema#dateTime>}
WHERE { GRAPH <http://data.digitalsocial.eu/graph/organizations-and-activities/metadata> { ?ds a <http://publishmydata.com/def/dataset#Dataset> .
OPTIONAL {?ds <http://purl.org/dc/terms/modified> ?mod} } }' $DATESTR`

    curl -s -f -d "request=$query" http://46.4.78.148/dsi/update > /dev/null
    CURL_STATUS=$?

    if [ $CURL_STATUS -ne 0 ]; then
        echo "Failed to update modified date"
        echo "Backup Failed to Complete."
        exit 3
    fi
    echo "Modification Date Set"
}

function remove_dsi_backup() {
    FNAME=$1
    rm $FNAME
    echo "Removed old local backup: $FNAME"
}

export -f remove_dsi_backup # export the function so we can use it with find

function remove_old_backups() {
    # NOTE the crazy syntax for calling an exported function and
    # passing an arg to find -exec.
    find $LOCAL_BACKUP_DIR -mtime +14 -exec bash -c 'remove_dsi_backup "$0"' {} \;
}

MAIN_DATA_SET="dataset_data_organizations-and-activities_$DATESTR.nt"
ACTIVITY_TYPES="concept-scheme_activity_types_$DATESTR.nt"
ACTIVITY_TECHNOLOGY_METHODS="concept-scheme_activity-technology-methods_$DATESTR.nt"
AREA_OF_SOCIETY="concept-scheme_area-of-society_$DATESTR.nt"

fetch_ntriples $MAIN_DATA_SET  "http%3A%2F%2Fdata.digitalsocial.eu%2Fgraph%2Forganizations-and-activities"
fetch_ntriples $ACTIVITY_TYPES "http%3A%2F%2Fdata.digitalsocial.eu%2Fgraph%2Fconcept-scheme%2Factivity-type"
fetch_ntriples $ACTIVITY_TECHNOLOGY_METHODS "http%3A%2F%2Fdata.digitalsocial.eu%2Fgraph%2Fconcept-scheme%2Ftechnology-method"
fetch_ntriples $AREA_OF_SOCIETY "http%3A%2F%2Fdata.digitalsocial.eu%2Fgraph%2Fconcept-scheme%2Farea-of-society"

upload_to_s3 $MAIN_DATA_SET
upload_to_s3 $ACTIVITY_TYPES
upload_to_s3 $ACTIVITY_TECHNOLOGY_METHODS
upload_to_s3 $AREA_OF_SOCIETY

set_modified_date

remove_old_backups

echo "$DATESTR Backup Complete."
