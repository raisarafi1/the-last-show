# # add your create-obituary function here
# import boto3
# import requests

# def handler(event, context):

#     name = event['name']
#     birth = event['born']
#     death = event['died']

#     client = boto3.client('ssm')

#     response = client.get_parameter(
#         Name='chatgpt-api-key',
#         WithDecryption=True
#     )

#     key = response['Parameter']['Value']


#     headers = {
#     'Content-Type': 'application/json',
#     'Authorization': 'Bearer ' + key,
#     }
    
#     json_data = {
#         'model': 'text-davinci-003',
#         'prompt': 'write an obituary about a fictional character named ' + name + 'who was born on ' + birth + ' and died on ' + death + '.',
#         'temperature': 0.7,
#         'max_tokens': 600
#     }

#     response = requests.post('https://api.openai.com/v1/completions', headers=headers, json=json_data)

#     response_data = response.json()
#     event['txt'] = response_data['choices'][0]['text']
#     return event




# def lambda_handler(event, context):
#     s3 = boto3.client('s3')
#     key = event['s3_key']+"Mp3.mp3"
#     polly = boto3.client('polly')
#     text = event['txt']
#     response = polly.synthesize_speech(
#     Engine='neural',
#     LanguageCode='en-GB',
#     Text=text,
#     TextType='text',
#     OutputFormat='mp3',
#     VoiceId='Arthur'
#     )
#     audio_stream = response['AudioStream'].read()
#     s3.put_object(Bucket="speech-and-images", Key=key, Body=audio_stream)
#     return event



import boto3
import json
import requests
# from requests_toolbelt.multipart.encoder import MultipartEncoder


# import requests 

#connects to dynamodb table
dynamodb = boto3.resource('dynamodb')
table_name = 'the-last-show-30140980'

def handler(event, context):

    # ssm = boto3.client('ssm')
    # r = ssm.get_parameter(
    # Name='CloudAPIkey',
    # WithDecryption=True
    # )
    # key = r['Parameter']['Value']

    # s3 = boto3.resource('s3', region_name='ca-central-1')
    # bucket = s3.Bucket('terraform-20230422235151931000000001')

    # image = event['image']
    # obj = bucket.Object(image+"."+event['imgtype']) #set imgtype in front end
    # file_obj = obj.get()['Body'].read()

    # multipart_data = MultipartEncoder(
    #     fields={
    #     "file": (image+"Img", file_obj, event['imgtype'].upper()),
    #     "upload_preset": "upload"
    #     }
    # )

    # headers = {
    #     "Content-Type": multipart_data.content_type
    # }

    # upload_url = f"https://api.cloudinary.com/v1_1/dzqo4npks/image/upload"
    # response = requests.post(upload_url, headers=headers, data=multipart_data,
    # auth=("779774815844692", key))
    name = event['name']
    birth = event['birth']
    death = event['death']
    # obituary = event['obituary']

    client = boto3.client('ssm')

    response = client.get_parameter(
        Name='apikey',
        WithDecryption=True
    )

    key = response['Parameter']['Value']


    headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + key,
    }

    json_data = {
        'model': 'text-babbage-001',
        'prompt': 'write an obituary about a fictional character named ' + name + 'who was born on ' + birth + ' and died on ' + death + '.',
        'temperature': 0.7,
        'max_tokens' : 600
    }

    response = requests.post('https://api.openai.com/v1/completions', headers=headers, json=json_data)

    # response_data = response.json()
    # event['txt'] = response_data['choices'][0]['text']
    # return event

    response_data = response.json()
    choices = response_data.get('choices', [])
    if not choices:
        raise ValueError('No choices found in response')
    # event['txt'] = choices[0].get('text', '')
    obituary = choices[0].get('text', '')
    # return event

    


    # name = event['name'] 
    # birth = event['birth']
    # died = event['died']

    #puttin in dynamodb table
    table = dynamodb.Table(table_name)
    table.put_item(Item={'name': name, 'birth': birth, 'death': death, 'obituary' : obituary})
    response = {
        'statusCode': 200,
         'headers':{
             'Access-Control-Allow-Headers': '*',
             'Access-Control-Allow-Origin': '*',
             'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'},
        'body': json.dumps({'message': f'{name, birth, death} saved successfully', 'obituary' : obituary})
    }
    return event, response 
    # return response



