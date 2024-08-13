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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloading cart application"

cd /app &>> $LOGFILE

unzip  -o /tmp/cart.zip &>>$LOGFILE

VALIDATE $? "unzipping cart"

cd /app

npm install &>> $LOGFILE

VALIDATE $? "Installing Dependencies"

#use absolute path to cart.service file , because cart.service exits there.

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service

VALIDATE $? "Copying cart.service file"

systemctl daemon-reload &>>$LOGFILE 

VALIDATE $? "Cart demon reload"

systemctl enable cart &>> $LOGFILE

VALIDATE $? " Enable Cart service"

systemctl start cart &>> $LOGFILE

VALIDATE $? " Starting Cart service"

























