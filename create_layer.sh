#!/bin/bash
LAYERNAME=test-layer

export PKG_DIR="python"

mkdir -p ${PKG_DIR}

# Assumes you are in the virtual environment you want to recreate
pip freeze > requirements.txt
docker run --rm -v $(pwd):/foo -w /foo lambci/lambda:build-python3.8 \
    pip install -r requirements.txt --no-deps -t ${PKG_DIR}

zip -r9 $LAYERNAME.zip ${PKG_DIR}
sudo rm -rf ${PKG_DIR}
rm requirements.txt

# First store to S3 then publish
# Doesn't work well with ferryhopper because my bucket is in a different region than the lambdas
#aws s3 cp $LAYERNAME.zip s3://george-home/Lambda/Layers/$LAYERNAME.zip
#aws lambda publish-layer-version --layer-name $LAYERNAME --content S3Bucket=george-home,S3Key=Lambda/Layers/$LAYERNAME.zip --compatible-runtimes python3.8

# Publish by directly uploading zip file
aws lambda publish-layer-version --layer-name $LAYERNAME --zip-file fileb://$LAYERNAME.zip --compatible-runtimes python3.8

# Publish by directly uploading zip file (FerryHopper version)
aws --profile ferryhopper --region eu-central-1 lambda publish-layer-version --layer-name $LAYERNAME --zip-file fileb://$LAYERNAME.zip --compatible-runtimes python3.8

rm $LAYERNAME.zip
