#!bin/bash

#CODE started 


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)

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

dnf install python3 gcc python3-devel -y
VALIDATE $? "installing Python"

id roboshop &>>$LOG_FILE 

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "useradd"
else 
echo "already user adde"
fi

mkdir -p /app 
VALIDATE $? "app directory creation"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOG_FILE 

VALIDATE $? "downloading to payment  app" 
cd /app 
rm -rf /app/*
VALIDATE $? "cleaning everthing in app directory"
unzip /tmp/payment.zip &>>$LOG_FILE

cd /app 
pip3 install -r requirements.txt &>>$LOG_FILE 

VALIDATE $? "Adding depedencies"
 

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service

VALIDATE $? "copying payment service "

systemctl daemon-reload
VALIDATE $? "daemon-reload "

systemctl enable payment 
VALIDATE $? "enabling payment"
systemctl start payment
VALIDATE $? "starting payment"


End_time=$(date +%s)
TOTAL_TIME=$(($End_time - $start_time))
echo -e "script execution time in : $Y $TOTAL_TIME Seconds $N "