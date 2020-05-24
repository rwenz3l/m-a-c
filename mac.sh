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

# Create DB if none present.
sqlite3 ${MAC_DB_FILE} """
    CREATE TABLE IF NOT EXISTS files (
        fname string primary key unique,
        fhash string
    );
    """

# Loop through files & folders
while IFS= read -r -d $'\0' f; do
    # Extract name from path returned by find
    fname="$(basename "${f}")"
    # Generate quoted string for database
    qname="${fname/\'/\'\'}"
    # Check if the name is in the database
    exists=$(sqlite3 ${MAC_DB_FILE} """
        SELECT * from files WHERE fname = '${qname}';
        """)
    printf "\e[1;94m┌─ ${fname}"
    if test -z "${exists}"; then
        rclone -q copyto "${f}" "${target}/${fname}" && \
        sqlite3 ${MAC_DB_FILE} """
        INSERT INTO files (fname) VALUES ('${qname}');
        """ && \
        printf "\n\e[1;92m└─ copied and added to the database.\n\e[1;0m"
    else
        printf "\n\e[1;93m└─ found in db, skipping.\n\e[1;0m"
    fi
done < <(find ${src} -mindepth 1 -maxdepth 1 -print0)