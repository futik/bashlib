#!/bin/sh 

FILE_TO_BACKUP="${1}"

if [ -z "${FILE_TO_BACKUP}" ]; then
    echo "$0 <file_to_backup>"
    exit -1
fi

BACKUP_DIR="./backups"          # local directory to store backups
RSA_PRIV="./rsa.private"
RSA_PUB="./rsa.public"

BACKUP_FILE="${BACKUP_DIR}/${FILE_TO_BACKUP}.backup"       # the backup file name convention
BACKUP_KEY_FILE="${BACKUP_FILE}.key"      # the backup file name convention

# generate RSA private/public key-pair - this key-pair is for demo purposes
if [ ! -f "${RSA_PRIV}" ] && [ ! -f "${RSA_PUB}" ]; then 
    # generate RSA private/public key-pair
    openssl genrsa -out ${RSA_PRIV} 4096
    openssl rsa -in ${RSA_PRIV} -out ${RSA_PUB} -pubout -outform PEM
fi

# generate AES-256 key
AES_KEY=$(openssl enc -aes-256-cbc -P -k "`dd if=/dev/urandom count=100 conv=ascii 2>/dev/null`" 2>/dev/null| grep key| sed -e "s/.*=//g")

if [ -f "${FILE_TO_BACKUP}" ]; then
    # write encrypted data encryption key
    echo ${AES_KEY}| openssl rsautl -encrypt -inkey ./rsa.public -pubin > ${BACKUP_KEY_FILE}

    # encrypt the data
    cat ${FILE_TO_BACKUP} | openssl aes-256-cbc -out ${BACKUP_FILE} -e -k ${AES_KEY}
else
    echo "nothing to backup"
fi