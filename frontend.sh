#!bin/bash

#CODE started 


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
FILE_DIR=$PWD
#MONGODB_HOST="mongodb.daws8s.shop"

LOGS_FOLDER="/var/log/roboshop"
SCRIPT_NAME=$(echo $0| cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "SCRIPT started executing $(date)" | tee -a $LOG_FILE 
start_time=$(date +%s)

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


dnf module disable nginx -y &>>$LOG_FILE 
VALIDATE $? "disablling nginx"
dnf module enable nginx:1.24 -y &>>$LOG_FILE 
VALIDATE $? "Enabling nginx"
dnf install nginx -y &>>$LOG_FILE 
VALIDATE $? "install nginx"

systemctl enable nginx &>>$LOG_FILE 
VALIDATE $? "enable nginx"
systemctl start nginx &>>$LOG_FILE 
VALIDATE $? "start  nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "deleting defalut content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip

VALIDATE $? "download the frontend content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip

rm -rf /etc/nginx/nginx.conf

cp $FILE_DIR/ngix.conf /etc/nginx/nginx.conf
VALIDATE $? "copying the files in nginx conf"