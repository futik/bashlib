#!/bin/sh 

FILE_TO_RESTORE="${1}"

if [ -z "${FILE_TO_RESTORE}" ] && [[ "${FILE_TO_RESTORE}" == *.backup ]]; then
    echo "$0 <backup_file_to_restore>"
    exit -1
fi

BACKUP_DIR="./backups"          # local directory to store backups
RSA_PRIV="./rsa.private"
RSA_PUB="./rsa.public"

BACKUP_KEY_FILE="${FILE_TO_RESTORE}.key"      # the backup file name convention

# generate RSA private/public key-pair - this key-pair is for demo purposes
if [ ! -f "${RSA_PRIV}" ] && [ ! -f "${RSA_PUB}" ]; then 
    # generate RSA private/public key-pair
    echo "generating RSA keypair"
    openssl genrsa -out ${RSA_PRIV} 4096
    openssl rsa -in ${RSA_PRIV} -out ${RSA_PUB} -pubout -outform PEM
fi

if [ -f "${FILE_TO_RESTORE}" ]; then
    # decrypt data encryption key
    AES_KEY=$( openssl rsautl -decrypt -inkey ${RSA_PRIV} -in ${BACKUP_KEY_FILE} )

    # encrypt the data
    cat ${FILE_TO_RESTORE} | openssl aes-256-cbc -pbkdf2 -d -k "${AES_KEY}" | gzcat
else
    echo "nothing to backup"
fi