import json
import boto3
import os
from datetime import datetime
import time
import calendar

def lambda_handler(event, context):
    cloudwatch = boto3.client('cloudwatch')
    date = datetime.now()
    first = date.replace(day=1)
    last = date.replace(day = calendar.monthrange(date.year, date.month)[1])
    print('first: ', first)
    print('last: ', last)
    
    targetGroupARN='arn:aws:lambda:us-west-1:889986269978:function:test'
    tgarray=targetGroupARN.split(':')
    target=tgarray[-1]
    print(target)
    
    response = cloudwatch.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 'myrequest',
                'MetricStat': {
                    'Metric': {
                        'Namespace': 'AWS/Lambda',
                        'MetricName': 'Invocations',
                        'Dimensions': [
                            {
                                'Name': 'lambda',
                                'Value': target
                            },
                        ]
                    },
                    'Period': 300,
                    'Stat': 'Sum',
                    # 'Unit': 'Count'
                }
            },
        ],
        # StartTime=datetime(first.year, first.month, first.day),
        StartTime=datetime(2021, 11, 1),
        # EndTime=datetime(last.year, last.month, last.day),
        EndTime=datetime(2021, 11, 30),
    )
    
    print(response)
    return response