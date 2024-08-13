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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disabling current MySQl version"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "Copied Mysql repo"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "Installing MySQl server"

systemctl enable mysqld   &>> $LOGFILE

VALIDATE $? "enable MySQl server"

systemctl start mysqld  &>> $LOGFILE

VALIDATE $? "starting MySQl server"

mysql_secure_installation --set-root-pass RoboShop@1  &>> $LOGFILE

VALIDATE $? "Setting MySQl root password"
