#!/bin/bash
LAYERNAME=everypay-type2-notifier-layer

export PKG_DIR="python"

mkdir -p ${PKG_DIR}

# Assumes you are in the virtual environmnet you want to recreate
pip freeze > requirements.txt
docker run --rm -v $(pwd):/foo -w /foo lambci/lambda:build-python3.8 \
    pip install -r requirements.txt --no-deps -t ${PKG_DIR}

zip -r9 $LAYERNAME.zip ${PKG_DIR}
sudo rm -rf ${PKG_DIR}
rm requirements.txt

# First store to S3 then publish 
aws s3 cp $LAYERNAME.zip s3://george-home/Lambda/Layers/$LAYERNAME.zip
aws lambda publish-layer-version --layer-name $LAYERNAME --content S3Bucket=george-home,S3Key=Lambda/Layers/$LAYERNAME.zip --compatible-runtimes python3.8

# Publish by directly uploading zip file
#aws lambda publish-layer-version --layer-name $LAYERNAME --zip-file fileb://$LAYERNAME.zip --compatible-runtimes python3.8

rm $LAYERNAME.zip
