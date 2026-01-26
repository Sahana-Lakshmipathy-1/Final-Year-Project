import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    route_key = event["requestContext"]["routeKey"]
    connection_id = event["requestContext"]["connectionId"]
    domain = event["requestContext"]["domainName"]
    stage = event["requestContext"]["stage"]
    
    # Initialize the API Gateway Management client
    apigw = boto3.client(
        "apigatewaymanagementapi",
        endpoint_url=f"https://{domain}/{stage}"
    )

    if route_key == "$connect":
        logger.info(f"Connect: {connection_id}")
        # Send ID back immediately upon connection
        try:
            apigw.post_to_connection(
                ConnectionId=connection_id,
                Data=json.dumps({"connection_id": connection_id}).encode("utf-8")
            )
        except Exception as e:
            logger.error(f"Failed to send ID on connect: {e}")
        return {"statusCode": 200}

    if route_key == "$disconnect":
        logger.info(f"Disconnect: {connection_id}")
        return {"statusCode": 200}

    if route_key == "$default":
        # Fallback: if the app sends any initial message, send the ID again
        apigw.post_to_connection(
            ConnectionId=connection_id,
            Data=json.dumps({"connection_id": connection_id}).encode("utf-8")
        )
        return {"statusCode": 200}

    return {"statusCode": 400, "body": "Unknown route"}