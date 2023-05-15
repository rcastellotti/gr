#/bin/bash
# set -xe

if [[ $# -eq 1 ]];
then
    wget https://www.sqlite.org/2023/sqlite-amalgamation-3410200.zip
    unzip sqlite-amalgamation-3410200.zip
    gcc sqlite-amalgamation-3410200/shell.c sqlite-amalgamation-3410200/sqlite3.c -lpthread -ldl -lm -o sqlite3
    wget http://www.phoronix-test-suite.com/benchmark-files/pts-sqlite-tests-1.tar.gz
    tar -xf pts-sqlite-tests-1.tar.gz
fi

./sqlite3 benchmark.db  "CREATE TABLE pts1 ('I' SMALLINT NOT NULL, 'DT' TIMESTAMP NOT 
NULL DEFAULT CURRENT_TIMESTAMP, 'F1' VARCHAR(4) NOT NULL, 'F2' VARCHAR(16) NOT NULL);"

TIMEFORMAT='%R'
for i in {1..10}
do
    time cat sqlite-2500-insertions.txt | ./sqlite3 benchmark.db
done 2> tb_sqlite_results."$(date +%s)".txt


if [[ $# -eq 1 ]];
then
    rm -rf sqlite-amalgamation-3410200.zip
    rm -rf sqlite-amalgamation-3410200
    rm -rf benchmark.db
    rm -rf pts-sqlite-tests-1.tar.gz
fi