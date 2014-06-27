#/bin/bash!

#This test only works if the database (stored in a file),
#is accessible by the same path to any node in the cluster.
#Otherwise, there will be failures.

### Remove the test database if it exists.
hadoop fs -rmr T
hadoop fs -rm -r /tmp/sqsmoke*

#This is in the dfs - thus - this 
#database is actually distributed to all nodes.
#no need for an actual url.
dbfile="/mnt/glusterfs/tmp/sqsmoke"

# Create a simple table...
#sqltool=`find sqltool*jar`
#echo "sql tool is $sqltool "
hsql=`find $SQOOP_HOME/lib -name hsql*jar | grep -v sources`
echo "hsql : $hsql"

rm -rf $dbfile

# Create db permissions

echo "Creating db perms"
# A personal, local, persistent database.

echo "urlid smoketest
url jdbc:hsqldb:file:$dbfile;shutdown=true
username SA
password" > $HOME/sqltool.rc

echo "creating table....."

# Create a Database in the DFS .  HSQL will forward jdbc requests to 
# read from a "local" file that is actually identical on all nodes -
# thus simulating a real sqoop workflow where mappers can pull data
# from a jdbc interface in parallel. 
echo "CREATE TABLE t (i INT PRIMARY KEY, v VARCHAR(25), d DATE);
INSERT INTO t(i, v, d) VALUES (1, 'one two three', null);
INSERT INTO t(i, v, d) VALUES (2, null, '2007-06-24');
INSERT INTO t(i, v, d) VALUES (3, 'one,two,,three', '2007-06-24');
INSERT INTO t(i, v, d) VALUES (4, '"one"two""three', '2007-06-24');
INSERT INTO t(i, v, d) VALUES (5, '"one,two"three,', '2007-06-24');
INSERT INTO t(i, v, d) VALUES (6, '', '2007-06-24');
commit;" > testsqoop.sql

# Create a simple database into hsql:
#java -jar /usr/lib/sqoop/lib/hsqldb-1.8.0.10.jar smoketest testsqoop.sql
java -jar $hsql smoketest testsqoop.sql

$SQOOP_HOME/bin/sqoop import-all-tables -libjars $hsql --connect jdbc:hsqldb:file:$dbfile
ls -altrh /mnt/glusterfs/user/tom/T/
