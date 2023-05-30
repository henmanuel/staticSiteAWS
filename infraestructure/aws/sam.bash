echo "Enter domain app: example.com"
read APPDomain

if [ -z "$APPDomain" ]; then
  echo "Domain app is required"
  exit 1
fi

echo "Enter the name of Environment: Default -> dev || qa || prod"
read Environment

Dot="."
Hyphen="-"

if [[ $Environment == "dev" ]]; then
  echo "The option chosen is dev"
elif [[ $Environment == "qa" ]]; then
  echo "The option chosen is qa"
elif [[ $Environment == "prod" ]]; then
  echo "The option chosen is prod"
else
  echo "The option chosen is not valid, the default option is dev"
  Environment="dev"
fi

echo "Enter the name of the region: Default -> us-east-1"
read Region

if [ -z "$Region" ]; then
  Region="us-east-1"
fi

TemplateName=${APPDomain}.template
StackName=${Environment}${Hyphen}${APPDomain/./-}

brew install awscli

if [[ $Environment == "prod" ]]; then
  Environment=""
  Hyphen=""
  Dot=""

  Environment="${Environment}${Dot}"
  BucketName=${Environment}${APPDomain}-deploy
  aws s3api create-bucket --bucket "$BucketName" --region us-east-1
  sam deploy -t "$TemplateName" --stack-name "$StackName" --s3-bucket "$BucketName" --region $Region --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND CAPABILITY_NAMED_IAM --parameter-overrides AppName="$APPDomain" Region="$Region"
else
  Environment="${Environment}${Dot}"
  BucketName=${Environment}${APPDomain}-deploy
  aws s3api create-bucket --bucket "$BucketName" --region us-east-1
  sam deploy -t "$TemplateName" --stack-name "$StackName" --s3-bucket "$BucketName" --region $Region --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND CAPABILITY_NAMED_IAM --parameter-overrides AppName="$APPDomain" Environment="$Environment" Region="$Region"
fi

aws s3 sync ../../src s3://"${Environment}${APPDomain}"
