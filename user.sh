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
        exit 1
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

id roboshop # if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then 
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "roboshop user creation"
else 
    echo -e "roboshop user already exist $Y .. SKIPPING $N"
fi 

VALIDATE $? "Creating roboshop User"

mkdir -p /app &>> $LOGFILE 

VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading User appilcation"

cd /app &>> $LOGFILE

unzip  -o /tmp/user.zip &>>$LOGFILE

VALIDATE $? "unzipping user"

cd /app

npm install &>> $LOGFILE

VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service

VALIDATE $? "Copying user.service file"

systemctl daemon-reload &>>$LOGFILE 

VALIDATE $? "User demon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? " Enable user service"

systemctl start user &>> $LOGFILE

VALIDATE $? " Starting user service"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying Mongodb Repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB Client"

mongo --host 172.31.45.55 </app/schema/user.js

VALIDATE $? "Loading the user data into MongoDB" &>> $LOGFILE


