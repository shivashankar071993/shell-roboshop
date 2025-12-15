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
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLING NODE JS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable node js" 

dnf install nodejs -y &>>$LOG_FILE



id=roboshop

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>LOG_FILE
    VALIDATE $? "useradd"
else 
echo "already user adde"
fi

mkdir -p /app 
VALIDATE $? "app directory creation"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>>LOG_FILE 

VALIDATE $? "downloading to user app" 
cd /app 
rm -rf /app/*
VALIDATE $? "cleaning everthing in app directory"
unzip /tmp/user.zip &>>$LOG_FILE

cd /app 
npm install &>>$LOG_FILE
VALIDATE $? "npm install"
cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "copying user service "

systemctl daemon-reload
VALIDATE $? "daemon-reload "

systemctl restart user
VALIDATE $? "restarted user"

End_time=$(date +%s)
TOTAL_TIME=$(($End_time - $start_time))
echo -e "script execution time in : $Y $TOTAL_TIME Seconds $N"