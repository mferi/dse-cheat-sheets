------- boto3 world---------

### Sdk for python
import boto3

### Connection to Amazon S3
s3 = boto3.resource('s3')

### Print out all bucket names
buckets = s3.buckets.all()
for bucket in buckets:
    print(bucket.name)

### Print out some object feautures including identifiers and attributes
BUCKETNAME= 'com.aegate.analytics.development'
bucket = s3.Bucket(BUCKETNAME)
objects = bucket.objects.all()
for obj in objects:
    print(obj.key, obj.last_modified)

### Get a bucket by name
bucket = s3.Bucket('com.aegate.analytics.development')

### Upload a new file
with open('fine_name', 'rb') as data:
    bucket.Object('file_name').put(Body=data)