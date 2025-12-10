#bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SGI_ID="sg-05310a4bf245de30c"

for instance in $@
do
   INSTANCE_ID=$( aws ec2 run-instances \
      --image-id ami-09c813fb71547fc4f \
      --instance-type t3.micro \
      --security-group-ids sg-05310a4bf245de30c \
      --count 1 \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
      --query 'Instances[0].InstanceId' \
      --output text
   )
    #Get private ip
   if [ $instance != "frontend" ]; then 

    IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text)

     else 
     IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)
   fi

   echo "$instance: $IP"

done


