#!bin/bash

#CODE started 

set -euo pipefail

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

trap 'echo "there is a error in $LINENO, command is :$BASH_COMMAND"', ERR

USERID=$(id -u)

MONGODB_HOST="mongodb.daws8s.shop"

LOGS_FOLDER="/var/log/roboshop"
SCRIPT_NAME=$(echo $0| cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "SCRIPT started executing $(date)" | tee -a $LOG_FILE 

USERID=$(id -u)

date &>>$LOG_FILE

if [ $USERID -ne 0 ] ; then
echo " Please run with root user else will not work"
exit 1
fi


dnf module disable nodejs -y &>>$LOG_FILE


dnf module enable nodejs:20 -y &>>$LOG_FILE
 

dnf install nodejs -y &>>$LOG_FILE

id=roboshop

if [ $? -ne 0]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>LOG_FILE
  
else 
echo "already user adde"
fi

mkdir -p /app 


curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>LOG_FILE 


cd /app 
rm -rf /app/*

unzip /tmp/catalogue.zip &>>$LOG_FILE

cd /app 
npm install &>>$LOG_FILE

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
systemctl daemon-reload
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongoshdadfda -y  &>>$LOG_FILE

mongosh --host $MONGODB_HOST </app/db/master-data.js & >>$LOG_FILE


systemctl restart catalogue
