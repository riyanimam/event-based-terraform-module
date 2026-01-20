import json
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """
    Process SQS messages.

    Args:
        event: SQS event containing messages
        context: Lambda context

    Returns:
        dict: Response with status code and processed message count
    """
    logger.info(f"Received event with {len(event['Records'])} records")

    processed_count = 0
    failed_messages = []

    for record in event['Records']:
        try:
            # Extract message body
            body = json.loads(record['body'])
            message_id = record['messageId']

            logger.info(f"Processing message {message_id}: {body}")

            # Your business logic here
            process_message(body)

            processed_count += 1

        except Exception as e:
            logger.error(f"Error processing message {record['messageId']}: {str(e)}")
            failed_messages.append({
                'itemIdentifier': record['messageId']
            })

    # Return batch item failures for partial batch responses
    if failed_messages:
        return {
            'batchItemFailures': failed_messages
        }

    logger.info(f"Successfully processed {processed_count} messages")
    return {
        'statusCode': 200,
        'body': json.dumps({
            'processed': processed_count
        })
    }


def process_message(message):
    """
    Process individual message.

    Args:
        message: Message body to process
    """
    # Implement your business logic here
    logger.info(f"Processing: {message}")
    # Example: save to database, call API, etc.
    pass
