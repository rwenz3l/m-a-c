#!/bin/bash

src="${1}"
target="${2}"
# TODO: Check if arguments actually given or empty

sqlite3 mac.db """
    CREATE TABLE IF NOT EXISTS files (
        fname string primary key unique,
        fhash string
    );
    """
for f in $(find "${src}" -maxdepth 1 | sort); do
    fname="$(basename "${f}")"
    exists=$(sqlite3 mac.db """
        SELECT * from files WHERE fname = '${fname}';
        """)
    if test -z ${exists}; then
        echo "Copy: ${fname}"
        rclone -q copyto "${f}" "${target}/${f}" && \
        sqlite3 mac.db """
        INSERT INTO files (fname) VALUES ('$fname');
        """ && \
        echo "$fname has been added to the database"
    else
        echo "$fname in database, skipping."
    fi
done;