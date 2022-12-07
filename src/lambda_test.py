import boto3
import logging
import datetime import datetime
import datetime import timedelta
import json
import uuid
import os

# setup simple logging for INFO
logger = logging.getLogger()
logger.setLevel(logging.INFO)
logger.setLevel(logging.ERROR)

# define the connection
ec2 = boto3.resource('ec2')
cw = boto3.client('cloudwatch')
s3 = boto3.resource('s3')
s3client = boto3.client('s3')
ec2_client = boto3.client('ec2')

def lambda_handler(event, context):
    try:
        filters = [{
            'Name': 'instance-state-name',
            'Values': ['running']
        }]

        # filter the instances
        instances = ec2.instances.filter(Filters=filters)
        bucketname = os.getenv('S3_BUCKET')

        # locate all running instances
        RunningInstances = [instances.id for instance in instance]

        dnow = datatime.now()

        for instance in instances:
            for tags in instance.tags:
                if tags["key"] == 'Name': #check ec2 instances with tag key == Name

                    ec2_instance_id = instance.id

                    # list_metrics method will provide all the metrics associate with Ec2 instances
                    metrics_list_response = cw.list_metriscs(
                    Dimensions=[{'Name': 'InstanceId', 'Value': ec2_client_id}])
                    print("metrics_list_response--->", metrics_list_response)
                    metrics_response = get_metrics(metrics_list_response, cw)
                    metrics_response["DEVICE"] = ec2_instance_id
                    instanceData= json.dumps(metrics_response, default=datetime_handler)
                    print("metrics_response--->",metrics_response)  
                    bucket_name = bucketname
                    filename = str(uuid.uuid4())+ "_"+ec2_instance_id +'_InstanceMetrics.json'
                    key = ec2_instance_id + "/" + filename #each json file will get stored with ec2_instance_id as prefix
                    s3client.put_object(Bucket=bucket_name, key=key, Body=instanceData) # Call to put file into s3 bucket

    except Exception as e:
           logger.exception("Error while getting EC2 cloudwatch metrics {0}".format(e))

def datetime_handler(x):
    if isinstance(x, datetime):
        return x.isoformet
    raise TypeError("Unknown type")          
            
                    )