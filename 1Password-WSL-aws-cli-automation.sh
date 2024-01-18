#!/bin/sh

# Created 01-18-2024 by radicaldo
# Edited from this excellent guide: https://www.packetmischief.ca/2023/02/26/how-i-use-mfa-with-the-aws-cli/
# Tested on:
# WSL version: 2.0.14.0
# Kernel version: 5.15.133.1-1
# WSLg version: 1.0.59
# MSRDC version: 1.2.4677
# Direct3D version: 1.611.1-81528511
# DXCore version: 10.0.25131.1002-220531-1700.rs-onecore-base2-hyp
# Windows version: 10.0.19045.3803 
# WSL Ubuntu-22.04.3 LTS jammy 
# 1Password for Windows 8.10.24 (81024035)
# aws-cli/2.15.10 Python/3.11.6 Linux/5.15.133.1-microsoft-standard-WSL2 exe/x86_64.ubuntu.22

SESSION_DURATION=14400

set -ef -o pipefail

if [ ! -t 0 ]; then
  echo "Must be on a tty"
  exit 1
fi

if [ -n "$1" ]; then
  export AWS_PROFILE=$1
fi

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

# Call 1Password with PowerShell from WSL
ps_op_call="\$Env:opmfa = 'op://vault-name/item-name/section-name/one-time password?attribute=otp' | op inject; \$Env:opmfa"

# Run the PowerShell command and store the 1Password mfa code in the code variable
code=$(powershell.exe -Command "$ps_op_call")

# Clean the code variable of any Win32 CRLF
cleaned_code=$(echo -n "$code" | tr -d '\r')

# Authenticate aws cli
tokens=$(aws sts get-session-token --serial-number "$device" --token-code "$cleaned_code" --duration-seconds $SESSION_DURATION)

# Pull details from aws sts response
secret=$(echo -- "$tokens" | sed -n 's!.*"SecretAccessKey": "\(.*\)".*!\1!p')
session=$(echo -- "$tokens" | sed -n 's!.*"SessionToken": "\(.*\)".*!\1!p')
access=$(echo -- "$tokens" | sed -n 's!.*"AccessKeyId": "\(.*\)".*!\1!p')
expire=$(echo -- "$tokens" | sed -n 's!.*"Expiration": "\(.*\)".*!\1!p')

#check if response was empty
if [ -z "$secret" -o -z "$session" -o -z "$access" ]
then
  echo "Unable to get temporary credentials."
  echo "Could not find secret/access/session tokens in GetSessionToken output."
  exit 1
fi

#clean profile name of @domain.com so the stored profile name in the credentials file is cleaner.
credprof="${username%%@*}"
#configure temporary credentials in the profile.
aws --profile $credprof configure set aws_access_key_id $access
aws --profile $credprof configure set aws_secret_access_key $secret
aws --profile $credprof configure set aws_session_token $session

echo "Session valid until $expire using CLI profile $credprof"
