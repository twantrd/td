#!/bin/bash
# Display out to console some useful information

color_off='\e[0m'
color_green='\e[0;32m'


#
# MAIN
#
elb_dnsname=$(aws elb describe-load-balancers | grep -i dns | awk '{print $2}' | sed -e 's/"//g' -e 's/,//')
elb_name=$(aws elb describe-load-balancers | grep -i loadbalancername | awk '{print $2}' | sed -e 's/"//g' -e 's/,//')

echo -e "\n** ${color_green}ELB Info${color_off} **"
echo "ELB DNS name: ${elb_dnsname}"
echo "ELB name: ${elb_name}"

echo -e "\n** ${color_green}Instance Info${color_off} **"
aws elb describe-instance-health --load-balancer-name ${elb_name} | grep "InstanceId\|State"

echo -e "\n** ${color_green}Instance Public IPs${color_off} **"
for instance_id in $(aws elb describe-instance-health --load-balancer-name ${elb_name} | grep "InstanceId" | awk '{print $2}' | sed -e 's/"//g' -e 's/,//')
do
    pubip=$(aws ec2 describe-instances --instance-ids ${instance_id} | grep -i public | grep -i PublicIpAddress | awk '{print $2}' | sed -e 's/"//g' -e 's/,//')
    echo "Instance: ${instance_id}, PublicIP: ${pubip}"
done
