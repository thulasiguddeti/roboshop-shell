#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>>$LOGFILE

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y 

VALIDATE $? "Installing Remi release"

dnf module enable redis:remi-6.2 -y 

VALIDATE $? "Enabiling Redis"

dnf install redis -y 

VALIDATE $? "Installing Reddis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf 

VALIDATE $? "Allowing Remoe Connections" 

systemctl enable redis 

VALIDATE $? "Enabiling Reddis"

systemctl start redis 

VALIDATE $? "Start Reddis"



