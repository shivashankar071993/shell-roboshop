#!bin/bash

#CODE started 


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)

MONGODB_HOST="mongodb.daws8s.shop"

LOGS_FOLDER="/var/log/roboshop"
SCRIPT_NAME=$(echo $0| cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "SCRIPT started executing $(date)" | tee -a $LOG_FILE 

USERID=$(id -u)

date &>>$LOG_FILE

if [ $USERID -ne 0 ] ; then
echo " Please run with root user else will not work"
exit 1
fi

VALIDATE(){

    if [ $1 -ne 0 ] ;  then 
         echo -e "$2... $R failure $N"
        exit 1
    else
         echo "$2... $G success $N"

    fi
}
dnf module disable nodejs -y &>>LOG_FILE
VALIDATE $? "DISABLING NODE JS"

dnf module enable nodejs:20 -y &>>LOG_FILE

VALIDATE $?"enable node js" 
dnf install nodejs -y &>>LOG_FILE

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>LOG_FILE
VALIDATE $? "useradd"
mkdir /app 
VALIDATE $? "app directory creation"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 

VALIDATE $? "downloading to catalogue app" &>>LOG_FILE
cd /app 
unzip /tmp/catalogue.zip &>>LOG_FILE

cd /app 
npm install &>>LOG_FILE
VALIDATE $? "npm install"
cp catalogue.service /etc/systemd/system/catalouge.service
VALIDATE $? "copying catalogue service "

systemctl daemon-reload
VALIDATE $? " demon reaload"
cp mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? " copying mongo repo"
dnf install mongodb-mongosh -y
VALIDATE $? "installing mongodb clinet"
mongosh --host $MONGODB_HOST </app/db/master-data.js

VALIDATE $? "Load catalogue products"

systemctl restart catalogue
VALIDATE $? "restarted catalogue"