#!/bin/bash 
sudo yum update -y
wget https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh
chmod +x Anaconda3-2019.07-Linux-x86_64.sh
./Anaconda3-2019.07-Linux-x86_64.sh -b -p  $HOME/anaconda3
export PATH="/home/ec2-user/anaconda3/bin:$PATH"
echo  'export PATH="/home/ec2-user/anaconda3/bin:$PATH"' >> ~/.bashrc 
conda info
conda install -y boto3
conda install -y py4j
conda install -y boto3


wget  https://amiscriptv3.s3.amazonaws.com/aws-java-sdk-1.7.4.jar 
wget  https://amiscriptv3.s3.amazonaws.com/hadoop-aws-2.7.2.jar 
wget  https://amiscriptv3.s3.amazonaws.com/copys3lib.sh
wget  https://amiscriptv3.s3.amazonaws.com/notebook.sh 

chmod +x notebook.sh
chmod +x copys3lib.sh



sudo amazon-linux-extras install postgresql10 vim epel -y
sudo yum install -y postgresql-server postgresql-devel
sudo /usr/bin/postgresql-setup --initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql
export PATH="/home/ec2-user/anaconda3/bin:$PATH"

