    #! /bin/bash
    SQLDB=$(aws ssm get-parameter --name "/rds/endpoint" --region eu-west-2 --query "Parameter.Value" --output text)
    SQLUSER=$(aws ssm get-parameter --name "/rds/user" --region eu-west-2 --query "Parameter.Value" --output text)
    SQLPASS=$(aws ssm get-parameter --name "/rds/secret" --region eu-west-2 --with-decryption --query "Parameter.Value" --output text)
