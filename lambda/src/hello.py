import json


def say_hello(event, context):
    message = 'Hello, {}!'.format(event["queryStringParameters"]['name'])
    return {
        "statusCode": 200,
        "isBase64Encoded": False,
        'body': json.dumps({"message": message})
    }
