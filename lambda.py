"""
Updates TargetTrackingScaling policy based on shedule
"""

import boto3
import logging

asg_client = boto3.client('autoscaling')
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info('Event:' + str(event))

    # Get Current Policies
    policy_response = asg_client.describe_policies(
        AutoScalingGroupName=[event['asg_name']],
        PolicyNames=[event['policy_name']])

    for asg in policy_response['ScalingPolicies']:
        tracking_config_new = {
          'PredefinedMetricSpecification':
          asg['TargetTrackingConfiguration']['PredefinedMetricSpecification'],
        }

        tracking_config_new.update(TargetValue=event['target'])

        asg_client.put_scaling_policy(
            AutoScalingGroupName=event['asg_name'],
            PolicyName=event['policy_name'],
            PolicyType='TargetTrackingScaling',
            TargetTrackingConfiguration=tracking_config_new)

        ssm_client.put_parameter(
            Name='/platform/' + event['policy_name'],
            Value=str(event['target']),
            Type="String",
            Overwrite=True)
