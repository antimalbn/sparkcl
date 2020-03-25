#!/bin/bash

if [ ! -f "spark/jars/aws-java-sdk-1.7.4.jar" ]
 
    then     
	cp -r aws-java-sdk-1.7.4.jar spark/jars/
    else 
	pwd 
fi   	

if [ ! -f "spark/jars/hadoop-aws-2.7.2.jar" ]
  
  then 
	
	cp -r hadoop-aws-2.7.2.jar spark/jars/

  else
	 pwd 

fi	  
