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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "installing maven"

id roboshop &>>LOG_FILE

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>LOG_FILE
    VALIDATE $? "useradd"
else 
echo "already user adde"
fi

mkdir -p /app 
VALIDATE $? "app directory creation"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>LOG_FILE 

VALIDATE $? "downloading to shipping app" 
cd /app 
rm -rf /app/*
VALIDATE $? "cleaning everthing in app directory"
unzip /tmp/shipping.zip &>>$LOG_FILE


cd /app 
mvn clean package &>>$LOG_FILE
mv target/shipping-1.0.jar shipping.jar 

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service

VALIDATE $? "copying shipping service "

systemctl daemon-reload
VALIDATE $? "daemon-reload "

systemctl enable shipping 
VALIDATE $? "enabling shipping"
systemctl start shipping
VALIDATE $? "starting shipping"

dnf install mysql -y 

VALIDATE $? "connecting mysql server"

mysql -h mysql.daws8s.shop -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE

if [ $? -ne 0 ]; then 

mysql -h mysql.daws8s.shop -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
mysql -h mysql.daws8s.shop  -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
mysql -h mysql.daws8s.shop  -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE

else 
    "shipping already loaded $Y skipping $N"

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restarting shipping"


End_time=$(date +%s)
TOTAL_TIME=$(($End_time - $start_time))
echo -e "script execution time in : $Y $TOTAL_TIME Seconds $N "