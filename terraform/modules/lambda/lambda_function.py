import boto3
import json
import os
import time
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function to bootstrap the IDE instance
    """
    logger.info(f"Event: {json.dumps(event)}")
    
    try:
        # Initialize AWS clients
        ssm = boto3.client('ssm')
        
        # Get environment variables
        environment = os.environ.get('ENVIRONMENT', 'eks-workshop')
        
        # Get instance ID from event or environment
        instance_id = event.get('instance_id')
        if not instance_id:
            # You would need to get this from a data source or parameter
            logger.error("No instance ID provided")
            return {
                'statusCode': 400,
                'body': json.dumps('No instance ID provided')
            }
        
        # Get SSM document name
        ssm_document = event.get('ssm_document', f'{environment}-bootstrap')
        
        logger.info(f"Starting bootstrap for instance: {instance_id}")
        
        # Wait for instance to be ready
        logger.info("Waiting for instance to be ready...")
        time.sleep(30)
        
        # Send SSM command
        logger.info("Sending SSM command...")
        
        # Retry logic for sending command
        max_retries = 3
        for attempt in range(max_retries):
            try:
                response = ssm.send_command(
                    InstanceIds=[instance_id],
                    DocumentName=ssm_document,
                    TimeoutSeconds=1800  # 30 minute timeout
                )
                
                command_id = response['Command']['CommandId']
                logger.info(f"Command sent successfully: {command_id}")
                break
            except Exception as e:
                if attempt < max_retries - 1:
                    logger.warning(f"Attempt {attempt + 1} failed, retrying...")
                    time.sleep(10)
                else:
                    raise e
        
        # Wait for command completion
        waiter = ssm.get_waiter('command_executed')
        waiter.wait(
            CommandId=command_id,
            InstanceId=instance_id,
            WaiterConfig={
                'Delay': 10,
                'MaxAttempts': 90
            }
        )
        
        # Check command execution status
        result = ssm.get_command_invocation(
            CommandId=command_id,
            InstanceId=instance_id
        )
        
        if result['Status'] != 'Success':
            logger.error(f"Command failed with status: {result['Status']}")
            logger.error(f"Error output: {result.get('StandardErrorContent', 'No error output')}")
            raise Exception(f"SSM command failed with status: {result['Status']}")
        
        logger.info("Bootstrap completed successfully!")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Bootstrap completed for instance: {instance_id}',
                'command_id': command_id
            })
        }
        
    except Exception as e:
        logger.error(f"Error during bootstrap: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error during bootstrap: {str(e)}')
        }
