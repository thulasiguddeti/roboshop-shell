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

dnf install maven -y

VALIDATE $? "Installing Maven"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip  &>> $LOGFILE

VALIDATE $? "Downloding shipping file"

cd /app  &>> $LOGFILE

VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip  &>> $LOGFILE

VALIDATE $? "unzipping the shipping "

cd /app &>> $LOGFILE

VALIDATE $? "moving to app directory"

mvn clean package &>> $LOGFILE

VALIDATE $? "Installing maven package dependencies"

mv target/shipping-1.0.jar shipping.jar  &>> $LOGFILE

VALIDATE $? "renaming jar file as shipping.jar"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service  &>> $LOGFILE

VALIDATE $? "Copying shipping service"

systemctl daemon-reload  &>> $LOGFILE

VALIDATE $? "Shipping demon reload"

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "Enabiling shipping service"

systemctl start shipping  &>> $LOGFILE

VALIDATE $? "starting shipping service"

dnf install mysql -y  &>> $LOGFILE

VALIDATE $? "Installing MySQL client"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "Loading  shipping data from the mysql client"

systemctl restart shipping  &>> $LOGFILE

VALIDATE $? "Restart the shipping service"


