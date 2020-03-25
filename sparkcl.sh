#!/bin/bash
#Written by Antima Mishra 
#Contact antima@lbncyberlabs.com
#This script use flintrock to create and manage spark cluster 

#Function to setup script firsttime
setupfirsttime(){
	echo "Setting up script,it will take few minutes"
        sudo yum update -y
        sudo yum install -y python3-pip

        ppv=`which pip3`

if [ ! -z "$ppv" ] ;
   then
      pip3 install --user flintrock 
      pip3 install --user "cryptography==2.4.2" 
      createdefaultvalue 
else
     echo "Unbale to install pip3"
     exit
fi     
        
}

#Create new cluster

createdefaultvalue(){
sgname=sparkcllanaccess
checksg=`aws ec2 describe-security-groups --filter Name=group-name,Values=sparkcllanaccess | grep GroupId | awk {'print $2'} | tr -d '" ' | tr -d ", "`
if [ ! -z "$checksg" ] ;
    then 
         sgid=$checksg
    else 	 

vpccidr=`aws ec2 describe-vpcs  | grep CidrBlock | grep -v "CidrBlockAssociationSet" | grep -v "CidrBlockState" | head -1 | awk {'print $2'} | tr -d '" ' | tr -d ", "`
vpcid=`aws ec2 describe-vpcs  | grep VpcId | awk {'print $2'} | tr -d '" ' | tr -d ", "`

sgid=`aws ec2 create-security-group --group-name $sgname --description "Spark Cluster SG" --vpc-id $vpcid | grep sg | awk {'print $2'} | tr -d '" ' | tr -d ", "`

fi

vpccidr=`aws ec2 describe-vpcs  | grep CidrBlock | grep -v "CidrBlockAssociationSet" | grep -v "CidrBlockState" | head -1 | awk {'print $2'} | tr -d '" ' | tr -d ", "`


aws ec2 authorize-security-group-ingress \
    --group-id $sgid \
    --protocol tcp \
    --port 0-63000 \
    --cidr $vpccidr
    
aws ec2 authorize-security-group-ingress \
    --group-id $sgid \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress \
    --group-id $sgid \
    --protocol tcp \
    --port 9999 \
    --cidr 0.0.0.0/0


read -p "Enter EC2 Key name " dkeyname
echo $dkeyname  > clkey.txt

read -p "Enter AMI ID " damiclid
echo $damiclid > clamid.txt


read -p "Enter Instance profile name " dimrol
echo $dimrol > cliam.txt


}



createcl(){


read -p "Enter Cluster Name  " clname
read -p "Enter Number of slave to launch " slvnum
read -p "Enter Instance type like t2.micro " instancetype

cldkeyname=`cat clkey.txt`
cldimrol=`cat cliam.txt`
cldamiclid=`cat clamid.txt`


flintrock launch $clname \
    --num-slaves $slvnum \
    --spark-version 2.4.4 \
    --ec2-key-name $cldkeyname \
    --ec2-identity-file $cldkeyname.pem \
    --ec2-ami $cldamiclid \
    --ec2-user ec2-user \
    --install-hdfs \
    --hdfs-version 2.8.5 \
    --install-spark \
    --ec2-instance-type $instancetype \
    --ec2-instance-profile-name $cldimrol \
    --ec2-security-group sparkcllanaccess


exit 

}

#Destroy cluster
destroycl(){

read -p "Enter Cluster Name  " clname

 flintrock destroy $clname	
exit

}

#Add slave 
addslave(){

read -p "Enter Cluster Name  " clname
read -p "Enter Number of slave to add  " slvnum
cldkeyname=`cat clkey.txt`


flintrock add-slaves --ec2-identity-file $cldkeyname.pem --ec2-user ec2-user $clname --num-slaves=$slvnum
flintrock run-command --ec2-identity-file $cldkeyname.pem --ec2-user ec2-user $clname "/bin/bash /home/ec2-user/copys3lib.sh"
exit

}

#Remove slave
removeslave(){

read -p "Enter Cluster Name  " clname
read -p "Enter Number of slave to remove  " slvnum
cldkeyname=`cat clkey.txt`


flintrock remove-slaves --ec2-identity-file $cldkeyname.pem --ec2-user ec2-user $clname --num-slaves=$slvnum

exit

}

#Start Cluster
startcl(){

read -p "Enter Cluster Name  " clname
cldkeyname=`cat clkey.txt`


flintrock start --ec2-identity-file $cldkeyname.pem --ec2-user ec2-user  $clname

exit

}

#Stop Cluster
stopcl(){

read -p "Enter Cluster Name  " clname
cldkeyname=`cat clkey.txt`


flintrock stop $clname	

exit

}	


#Get details of cl
getcldetails(){

read -p "Enter Cluster Name  " clname
cldkeyname=`cat clkey.txt`


flintrock describe $clname	

exit

}


#Login to cluster

logincl(){

read -p "Enter Cluster Name  " clname
cldkeyname=`cat clkey.txt`


flintrock login --ec2-identity-file $cldkeyname.pem --ec2-user ec2-user  $clname

exit


}	

runcmdcl(){

read -p "Enter Cluster Name  " clname

read -p "Enter comand to run  " cmdtorun
cldkeyname=`cat clkey.txt`

flintrock run-command --ec2-identity-file $cldkeyname.pem --ec2-user ec2-user  $clname $cmdtorun

exit


}	


#Menu to salect manage cluster option
manageclmenu() {
	while true
	do
            show_menuscl
            read_cloptions	    
    done
}


show_menuscl(){
        echo "~~~~~~~~~~~~~~~~~~~~~"    
        echo " Spark Cluster"
        echo "~~~~~~~~~~~~~~~~~~~~~"
        echo "1. Launch a new spark cluser"
        echo "2. Manage existing spark cluster"
        echo "3. Exit"
      

}


manageexcl() {
 while true
 do	 
     show_menusexclmg
     read_exclmgoptions
done    
}


show_menusexclmg(){

        echo "~~~~~~~~~~~~~~~~~~~~~"    
        echo " Existing Cluster Mangement Options"
        echo "~~~~~~~~~~~~~~~~~~~~~"
        echo "1. Get details of cluster"
        echo "2. Add Slave to cluser"
	echo "3. Remove Slave from cluser"
	echo "4. Stop cluser"
	echo "5. Start cluser"
	echo "6. Destroy cluser"
        echo "7. Login to cluser"
	echo "8. Run command to cluser"
        echo "9. Exit"


}






# do something
show_menus(){
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Setup Script First Time"
	echo "2. Manage Spark Cluster"
	echo "3. Exit"
}

# Exit when user the user select 3 form the menu option.
read_options(){
	local choice
	read -p "Enter choice [ 1 - 3] " choice
	case $choice in
		1) setupfirsttime ;;
		2) manageclmenu ;;
		3) exit 0 ;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}


read_cloptions(){
        local choicecl
        read -p "Enter choice [ 1 - 3] " choicecl
        case $choicecl in
                1) createcl ;;
                2) manageexcl ;;
                3) exit 0 ;;
                *) echo -e "${RED}Error...${STD}" && sleep 2
        esac
}

read_exclmgoptions(){
        local choiceexclmg
        read -p "Enter choice [ 1 - 7] " choiceexclmg
        case $choiceexclmg in
                1) getcldetails ;;
                2) addslave ;;
                3) removeslave ;;
		4) stopcl ;;
		5) startcl ;;
		6) destroycl ;;
		7) logincl ;;
		8) runcmdcl ;;
                9) exit 0 ;;
                *) echo -e "${RED}Error...${STD}" && sleep 2
        esac
}




# Step #3: Trap CTRL+C, CTRL+Z and quit singles
trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true
do
 
	show_menus
	read_options
done

