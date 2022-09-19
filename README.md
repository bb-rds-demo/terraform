### Sample Terraform project for deploying a load balanced EC2 ASG in front of RDS ###

## Assumptions made when configuring this demo: ##
- The application is required publicly, so HTTP from everywhere is permitted
- No HTTPS is required for a proof of concept, if this is required then a certificate and HTTPS listener will need configuring
- This highlights the infrastructure deployment only and no RDS IAM configuration is required.
- The Terraform backend is local for testing only.

## Extending the configuration
- This has been deployed in modules, for ease of future extention of the deployment.
- For a future deployment to obtain the DNS name of the ALB, this can be retrieved through a Terraform data object, an AWS CLI request, manually through the console, or by an output within the the module.

## CICD
- To depoy to continuously a Terraform backend needs to be configured with the relevant state locks and data storage reliablility
- Authentication will need to be configured, either using IAM credentials, AWS session credentials or any other means
- Once authentication is configured, the deployment can be duplicated for staging/production environments
- To ensure safe deployment into production, a CICD configuration could include a plan stage followed by a gated apply production stage.

## Connection to the RDS instance
- Depending on the desired connection method, this could be achieved through either IAM or username/password
- For IAM connection, the configuration is well documente here
  - https://aws.amazon.com/premiumsupport/knowledge-center/users-connect-rds-iam/
- For username/password authentication, the username/password created within the RDS module can be pushed to parameter store, and retrieved by the EC2 userdata.
