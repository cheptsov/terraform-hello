def say_hello(event, context):
    message = 'Hello, {}!'.format(event['name'])
    return {
        'message': message
    }