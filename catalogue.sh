#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ...$R FAILED $N"
    else 
        echo -e "$2 ...$G SUCCESS $N"
    fi   
}

if [ $ID -ne 0 ]
then
    echo -e "$R Error :: Please run the script with root acess $N"
    exit 1 # you can give other than zero
else
    echo "Your are a root user"
fi # it indicates if condition ends here.

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabiling current NodeJS" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabiling NodeJS:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing NodeJS:18"

useradd roboshop &>> $LOGFILE

VALIDATE $? "Creating roboshop User"

mkdir /app &>> $LOGFILE 

VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading Catalogue appilcation"

cd /app &>> $LOGFILE

unzip /tmp/catalogue.zip &>>$LOGFILE

VALIDATE $? "unzipping catalogue"

cd /app

npm install &>> $LOGFILE

VALIDATE $? "Installing Dependencies"

#use absolute path to catalogue.service file , because catalogue.service exits there.

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "Copying catalogue.service file"

systemctl daemon-reload &>>$LOGFILE 

VALIDATE $? "Catalogue demon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? " Enable Catalogue service"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? " Starting Catalogue service"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying Mongodb Repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB Client"

mongo --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js

VALIDATE $? "Loading the catalogue data into MongoDB"























