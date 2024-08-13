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

dnf install nginx -y &>> $LOGFILE

VALIDATE $? "Installing web server Nginx"

systemctl enable nginx &>> $LOGFILE 

VALIDATE $? "Enabiling web server Nginx"

systemctl start nginx &>> $LOGFILE 

VALIDATE $? "Start web server Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE 

VALIDATE $? "Removing Default content in Nginx server"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE 

VALIDATE $? "Downloaded web application"

cd /usr/share/nginx/html &>> $LOGFILE  

VALIDATE $? "Moving to nginx html directory"

unzip -o /tmp/web.zip  &>> $LOGFILE 

VALIDATE $? "Unzipping web"

cp /home/centos/roboshop-shell/roboshop.conf  /etc/nginx/default.d/roboshop.conf 

VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "Restarting nginx web"


