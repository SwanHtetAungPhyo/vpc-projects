#!/usr/bin/env bash

aws cloudformation create-stack \
  --stack-name vpc-peering-test \
  --template-body file://vpc-peering-template.yaml \
  --parameters \
    ParameterKey=VPCOneCIDR,ParameterValue=10.0.0.0/16 \
    ParameterKey=VPCTwoCIDR,ParameterValue=172.16.0.0/16