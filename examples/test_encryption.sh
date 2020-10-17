#!/bin/sh 

function get_word () {
    WORDLINE=$((($RANDOM * $RANDOM) % $(wc -w /usr/share/dict/words | awk '{print $1}')))"p" && sed -n $WORDLINE /usr/share/dict/words
}

TEST_FILE="./_backup_test"
TEST_BACKUP_FILE="./backups/_backup_test.backup"

TEST_VALUE="`get_word` `get_word` `get_word` `get_word` `get_word`" 

echo "${TEST_VALUE}" > _backup_test
./backup.sh ${TEST_FILE}
RESULT_VALUE=$(./restore.sh ${TEST_BACKUP_FILE})

echo "random input value : ${TEST_VALUE}"
echo "decrypted value    : ${RESULT_VALUE}"

rm -f _backup_test ./backups/_backup_test.backup*