#! /bin/bash


# MAKE SURE UPDATE SCRIPT HAS BEEN RUN BEFORE RUNNING THIS SCRIPT

#Setup data

echo "------------------Setting Up Data For East And West--------------------------"
hadoop fs -mkdir /input_east/
hadoop fs -copyFromLocal ./East/*.csv /input_east/
hadoop fs -mkdir /input_west/
hadoop fs -copyFromLocal ./West/*.csv /input_west/

echo "------------------Data Copied Successfully to HDFS----------------------------"

# create user 'east' and 'west' in accumulo and grant permissions.

cd /home/guest/cdse/accumulo/accumulo-1.4.2/

echo "123456
123456" | bin/accumulo shell -u root -p acc -e "createuser east"
echo "123456
123456" | bin/accumulo shell -u root -p acc -e "createuser west"
bin/accumulo shell -u root -p acc -e "grant -s System.CREATE_TABLE -u east
grant -s System.CREATE_TABLE -u west
quit"

echo "-------------------------east and west users created-------------------------"


#create target tables

echo "-------------------------creating result tables result_east for east data and result_westfor west data--------"

echo "true


STRING" | bin/accumulo shell -u east -p 123456 -e "createtable result_east
setiter -class org.apache.accumulo.core.iterators.user.SummingCombiner -p 10 -t result_east -majc -minc -scan
quit"

echo "true


STRING" | bin/accumulo shell -u west -p 123456 -e "createtable result_west
setiter -class org.apache.accumulo.core.iterators.user.SummingCombiner -p 10 -t result_west -majc -minc -scan
quit"



echo "------------------------finished creating tables--------------------------"

#run mapreduce jobs
cd NBACount

/home/guest/cdse/accumulo/accumulo-1.4.2/bin/tool.sh NBACount.jar counter.WordCount acc guestvb /input_east/ result_east -u east -p 123456

/home/guest/cdse/accumulo/accumulo-1.4.2/bin/tool.sh NBACount.jar counter.WordCount acc guestvb /input_west/ result_west -u west -p 123456


echo "-------------------TWITTER WIN LOSE COUNT COMPLETED. PLEASE SCAN result_east AND result_west TO VIEW WIN/LOSE COUNTS----------------"

#cleanup

hadoop fs -rmr /input_east/
hadoop fs -rmr /input_west/

exit 0


