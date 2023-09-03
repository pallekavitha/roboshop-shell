#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE

VALIDATE $? "Setting up NPM Source"

yum install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing NodeJS"

# once the user is created , if you run this script 2nd time 
# this command will definetly fail
#IMPROVEMENT : first check the user already exists or not, if not exist then create
useradd roboshop &>> $LOGFILE

# write a condition to check directory already exists or not
mkdir /app &>> $LOGFILE

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading user artifact"

cd /app &>> $LOGFILE

VALIDATE $? "moving into app directory"

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies"

#give full path of user.service because we are inside /app
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "copying user.service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "enabling user"

systemctl start user &>> $LOGFILE

VALIDATE $? "starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying mongo repo"

yum install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongo client"

mongo --host mongodb.joindevops.live </app/schema/user.js &>> $LOGFILE

VALIDATE $? "loading user data into mongodb"


