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

USERID=$(id -u)

date &>>$LOG_FILE

start_time=$(date +%s)

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


dnf install mysql-server -y

VALIDATE $? "Insatlling mysql"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enabling mysql"
systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "starting  mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "setting root password"

End_time=$(date +%s)
TOTAL_TIME=$(($End_time - $start_time))
echo -e "script execution time in : $Y $TOTAL_TIME Seconds $N"
