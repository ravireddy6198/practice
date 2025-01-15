#!/bin/bash

USERID=$(id -u)



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


mkdir -p $LOGS_FOLDER
echo "Script started executing at: $TIMESTAMP" &>>$log_file_name

CHECK_ROOT

dnf install nginx -y  &>>$log_file_name
VALIDATE $? "Installing Nginx Server"

systemctl enable nginx &>>$log_file_name
VALIDATE $? "Enabling Nginx server"

systemctl start nginx &>>$log_file_name
VALIDATE $? "Starting Nginx Server"

rm -rf /usr/share/nginx/html/* &>>$log_file_name
VALIDATE $? "Removing existing version of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$log_file_name
VALIDATE $? "Downloading Latest code"

cd /usr/share/nginx/html
VALIDATE $? "Moving to HTML directory"

unzip /tmp/frontend.zip &>>$log_file_name
VALIDATE $? "unzipping the frontend code"

cp /home/ec2-user/practice/practice-shell-expense/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied expense config"

systemctl restart nginx &>>$log_file_name
VALIDATE $? "Restarting nginx"