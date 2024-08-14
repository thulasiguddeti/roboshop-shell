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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "Installing Python"

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Downloading Payment"

cd /app &>> $LOGFILE

VALIDATE $? "moving to app directory"

unzip -o /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "Unzipping payment file"

pip3.6 install -r requirements.txt  &>> $LOGFILE

VALIDATE $? "Installing Python dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service  &>> $LOGFILE

VALIDATE $? "Copying payment service"

systemctl daemon-reload  &>> $LOGFILE

VALIDATE $? "Payment demon-reload"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "Enable payment"

systemctl start payment  &>> $LOGFILE

VALIDATE $? "starting payment"
