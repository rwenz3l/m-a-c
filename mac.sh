#!/bin/bash

# Check for args
if [ $# -eq 0 ]; then
    echo "No arguments supplied"
    echo "Usage: mac <src> <target>"
    echo "ENV:"
    echo "    MAC_DB_FILE << Specifies the database file location"
    echo "                   defaults to 'mac.db'"
    exit 1
fi

src="${1}"
target="${2}"

if [ -z "${MAC_DB_FILE}" ]
  then
    MAC_DB_FILE="mac.db"
fi


sqlite3 ${MAC_DB_FILE} """
    CREATE TABLE IF NOT EXISTS files (
        fname string primary key unique,
        fhash string
    );
    """
for f in $(find "${src}" -mindepth 1 -maxdepth 1 | sort); do
    fname="$(basename "${f}")"
    exists=$(sqlite3 ${MAC_DB_FILE} """
        SELECT * from files WHERE fname = '${fname}';
        """)
    if test -z ${exists}; then
        echo "Copy: ${fname}"
        rclone -q copyto "${f}" "${target}/${fname}" && \
        sqlite3 ${MAC_DB_FILE} """
        INSERT INTO files (fname) VALUES ('${fname}');
        """ && \
        echo "${fname} has been added to the database"
    else
        echo "${fname} in database, skipping."
    fi
done;