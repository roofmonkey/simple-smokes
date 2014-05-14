mv RESULTS RESULTS_OLD

### This script has only one dependency... bigpetstore ! To get it got to github.com/apache/bigtop and 
### build with "mvn clean package".  

### Simplified smoke tests.  We will replace these with BIGTOP-1222 ASAP

### Test Mapreduce 

/usr/lib/hadoop/bin/hadoop jar  /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples-2.2.0.2.0.6.0-101.jar pi 2 2

echo "MAPRED RESULT = $?"

### Test Mahout 
cp mahout/als_input /mnt/glusterfs/user/tom/
rm -rf /mnt/glusterfs/user/tom/als_output
rm -rf /mnt/glusterfs/tmp/mahout* 

mahout parallelALS --input als_input --lambda 0.1 --implicitFeedback true --alpha 0.8 --numFeatures 2 --numIterations 5  --numThreadsPerSolver 1 --tempDir /tmp/mahout-als --output als_output

echo "MAHOUT RESULT = $?" 

### Test Pig + Advanced Mapreduce (BigPetStore)
rm -rf /mnt/glusterfs/user/tom/bigpet*

/usr/lib/hadoop/bin/hadoop jar hive-pig/bigpetstore-1.3.10.jar org.bigtop.bigpetstore.generator.BPSGenerator 1000 bigpetstore

cp /usr/lib/pig/pig-0.12.0.2.0.6.1-101-withouthadoop.jar /mnt/glusterfs/pig.jar
export HADOOP_CLASSPATH=/usr/lib/pig/pig-0.12.0.2.0.6.1-101-withouthadoop.jar 

/usr/lib/hadoop/bin/hadoop jar hive-pig/bigpetstore-1.3.10.jar org.bigtop.bigpetstore.etl.PigCSVCleaner -libjars glusterfs:///pig.jar bigpetstore bigpetstore_cleaned 
bps=$?
echo "PIG RESULT = $bps"
echo "BPS RESULT = $bps" 

### Now test hive on the bigpetstore data

export HIVE_HOME=/usr/lib/hive/
### If fails... then Make sure hive server is started ???
hive -f hive-pig/bigpetstore.ql

echo "HIVE RESULT = $?"

### Test Flume

mkdir -p /mnt/glusterfs/tmp/flume-test/
rm -rf /mnt/glusterfs/tmp/flume-test/*
nohup ./flume/source.sh&
timeout 60 flume-ng agent --conf ./flume/conf/ -f ./flume/conf/flume.conf -Dflume.root.logger=DEBUG,console -n agent
echo "Timeout for flume agent expired... now testing sink."
sleep 2
echo "Now testing `wc -l /mnt/glusterfs/tmp/flume-test/`"
cat /mnt/glusterfs/tmp/flume-test/* | grep -q "hello"
echo "Flume Result = $?" 
rm nohup.out

### Test SQOOP
export SQOOP_HOME=/usr/lib/sqoop
cd sqoop
./test-sqoop.sh
echo "SQOOP RESULT = $?"
cd ..

echo "TESTS DONE !"
