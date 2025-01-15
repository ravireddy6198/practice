#!/bin/bash

USERID=$(id -u)

mkdir -p /home/ravi/expense_logs

log_folder="/home/ravi/expense_logs"
log_file=$(echo $0 | cut -d "." -f1)
timestamp=$(date +%Y-%m-%d-%H-%M-%S)

log_file_name="$log_folder/$log_file----$timestamp.log"

validate(){
if [ $1 -ne 0 ]
then
    echo "$2 --------------- failure"
    exit 1
else
    echo "$2 ------------ success"
fi

}




check_root(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR: You must have sudo access to execute this script"
        exit 1
    fi
}

echo " script execution started :$timestamp"


check_root

dnf module disable nodejs -y &>>$log_file_name
validate $? " disabling nodjs"

dnf module enable nodejs:20 -y &>>$log_file_name
validate $? " enabling nodjs"

dnf install nodejs -y &>>$log_file_name
validate $? " installing nodjs"

id expense
if [ $? -ne 0 ]
then
    echo "expense user doesnot exist"
    useradd expense &>>$log_file_name
    validate $? " adding expense user"
else 
    echo " expense user already exist ----- skipping"
fi

mkdir -p /app
validate $? " creating app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$log_file_name
validate $? " download code"

cd /app
rm -rf /app/*

unzip /tmp/backend.zip &>>$log_file_name
validate $? " unzipping"

cd /app

npm install &>>$log_file_name
validate $? " installing packages using npm"

cp /home/ec2-user/practice/practice-shell-expense/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>$log_file_name
validate $? "Installing MySQL Client"

mysql -h 172.31.29.83 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$log_file_name
validate $? "Setting up the transactions schema and tables"


systemctl daemon-reload &>>$log_file_name
validate $? "Daemon Reload"

systemctl enable backend &>>$log_file_name
validate $? "Enabling backend"

systemctl restart backend &>>$log_file_name
validate $? "Starting Backend"


