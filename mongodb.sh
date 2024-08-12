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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied MongoDB Repo"

dnf install mongodb-org -y &>> $LOGFILE
 
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabiling MongoDB"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "Start MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Remote access to MongoD"

systemctl restart mongod &>> $LOGFILE 

VALIDATE $? "Restart MongoDB"

