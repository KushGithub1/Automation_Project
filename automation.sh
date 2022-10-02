#!/bin/bash
s3_bucket='upgrad-parshant'
name='parshant'
timestamp=$(date +"%d%m%Y-%H%M%S")


sudo apt update -y

if [[  $(dpkg-query -l | grep apache2 | awk 'NR==1{print $2}') == "apache2" ]]
then
        echo "Already installed "
else
       sudo apt install apache2 -y
fi

if [[ ! $(systemctl status apache2 |grep running  | awk '{print $3}') == '(running)' ]]
then
       systemctl restart apache2

fi

if [[ ! $(systemctl status apache2 | grep enabled | awk '{ print $4}')  ==  "enabled;" ]] ; then
        systemctl enable apache2
fi

cd /var/log/apache2 && tar -czf $name-httpd-logs-${timestamp}.tar *.log &&
mv $name-httpd-logs-${timestamp}.tar /tmp/


aws s3  cp /tmp/$name-httpd-logs-${timestamp}.tar s3://$s3_bucket/$name-httpd-logs-${timestamp}.tar

docroot="/var/www/html"
if [[ ! -f ${docroot}/inventory.html ]]
then
        echo -e 'Log Type\t-\tTime Created\t-\tType\t-\tSize' > ${docroot}/inventory.html
fi

size=$(du -h /tmp/$name-httpd-logs-${timestamp}.tar | awk '{print $1}')
if [[ -f ${docroot}/inventory.html ]]
then
        echo -e "httpd-logs\t-\t${timestamp}\t-\ttar\t-\t${size}" >> ${docroot}/inventory.html
fi

if [ -f /etc/cron.d/automation ]
then
   echo "0 0 * * *  /root/Automation_project/automation.sh" > /etc/cron.d/automation
fi

