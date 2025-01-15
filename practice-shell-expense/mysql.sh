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

dnf install mysql-server -y &>>$log_file_name
validate $? " Mysql installation"

systemctl enable mysqld &>>$log_file_name
validate $? " Mysql enable"

systemctl start mysqld &>>$log_file_name
validate $? " Mysql started"

mysql -h <host-address> -u root -p<password> -e 'show databases;' &>>$log_file_name

if [ $? -ne 0 ]
then
    echo "MySQL Root password not setup"
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$log_file_name
    validate $? "settingup root password"
else
     echo "MySQL Root password already setup ... skipping"
fi



