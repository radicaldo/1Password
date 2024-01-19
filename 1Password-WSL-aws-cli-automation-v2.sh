#!/bin/sh

# This uses MFA devices to get temporary (eg 12 hour) credentials.  Requires
# a TTY for user input.
#
# Forked from https://gist.github.com/Yloganathan/c24a3d99213c72c7316269a1888b2600
#
# GPL 2 or higher

SESSION_DURATION=14400

set -ef -o pipefail

if [ ! -t 0 ]; then
  echo "Must be on a tty"
  exit 1
fi

# Build a temporary credential profile from 1Password where you've stored your AWS keys and default region so they aren't stored permanently in the crentials file
# This is necessary because the initial command to fetch your mfa arn and username can't be run without your keys

# Set the PowerShell command.  NOTE: these 1Password Secret references need to be changed to your secret references.
powershell_command="\$Env:opmfa='op://YOUR vaultname/ YOUR mfa itemname/one-time password?attribute=otp'|op inject; \$Env:akey='op://YOUR vaultname/ YOUR aws access key itemname/access key id'|op inject; \$Env:seckey='op://YOUR vaultname/ YOUR aws secret key itemname/secret access key' |op inject; \$Env:region='op://YOUR vaultname/ your item name/region' |op inject; \$Env:opmfa; \$Env:akey; \$Env:seckey; \$Env:region"

# Run the PowerShell command and store the output in a variable
code=$(powershell.exe -Command "$powershell_command")


# Clean the code of CRLF Windows characters and store each line in separate variables
cleaned_code=$(echo -n "$code" | tr -d '\r')

# Store each line of the powershell response in separate variables
i=0
while IFS= read -r line; do
    case $i in
        0) opmfa="$line";;
        1) akey="$line";;
        2) seckey="$line";;
        3) region="$line";;
    esac
    i=$((i+1))
done <<< "$cleaned_code"

# Build temporary credentials profile with the retrieved keys and region from 1Password Secret vault
export AWS_ACCESS_KEY_ID=$akey
export AWS_SECRET_ACCESS_KEY=$seckey
export AWS_DEFAULT_REGION=$region
export AWS_DEFAULT_OUTPUT="json"

# From here, don't allow unset variables.
set -u

identity=$(aws sts get-caller-identity --query Arn --output text)
username=$(echo -- "$identity" | sed -n 's!.*/!!p')
if [ -z "$username" ]; then
  echo "Can not identify who you are. Something failed when calling GetCallerIdentity."
  exit 1
fi

echo "User $identity"

# XXX this isn't robust enough if the user has > 1 MFA device.
device=$(aws iam list-mfa-devices --user-name "$username" --query 'MFADevices[0].SerialNumber' --output text)
if [ "$device" = "null" -o $? -ne 0 ]; then
  mfa=$(aws iam list-mfa-devices --user-name "$username")
  echo "Can not find any MFA device(s) for you."
  echo
  echo $mfa
  exit 1
fi

#putting it all together we call aws to get the session token
tokens=$(aws sts get-session-token --serial-number "$device" --token-code "$opmfa" --duration-seconds $SESSION_DURATION)

secret=$(echo -- "$tokens" | sed -n 's!.*"SecretAccessKey": "\(.*\)".*!\1!p')
session=$(echo -- "$tokens" | sed -n 's!.*"SessionToken": "\(.*\)".*!\1!p')
access=$(echo -- "$tokens" | sed -n 's!.*"AccessKeyId": "\(.*\)".*!\1!p')
expire=$(echo -- "$tokens" | sed -n 's!.*"Expiration": "\(.*\)".*!\1!p')

if [ -z "$secret" -o -z "$session" -o -z "$access" ]
then
  echo "Unable to get temporary credentials."
  echo "Could not find secret/access/session tokens in GetSessionToken output."
  exit 1
fi

# create a temporary profile name from your AWS username. I remove @yourdomain.com because it's cleaner.
credprof="${username%%@*}"

# set the temporary profile in the aws credentials file
aws --profile $credprof configure set aws_access_key_id $access
aws --profile $credprof configure set aws_secret_access_key $secret
aws --profile $credprof configure set aws_session_token $session
aws --profile $credprof configure set region $region

# You have to run export AWS_PROFILE=<insert-whatever-your-profile-name-is> in the ubuntu shell after this script before you run any other AWS CLI Commands.  
# It will override the requirement to need a default profile.  Otherwise AWS CLI will yell at you about not being configured since your credentials file doesn't have a default profile for security purposes.

echo "Session Token valid until "$expire". Temporary profile is name is "$credprof""
echo "IMPORTANT: Remember you have to run"
echo "export AWS_PROFILE=<temporary profile name above>"
echo "to override the requirement of aws cli needing a default profile before you can run any aws cli commands."
