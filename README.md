##################################################################################################

**aws-ec2-rds-timeout**

##################################################################################################


Purpose:
This Terraform project automates the creation of resources on AWS to start and stop EC2 and RDS instances at scheduled times using AWS Lambda. Utilizing CloudWatch Events, the instances can be automatically stopped as needed, helping to save costs by ensuring the instances are not running unnecessarily outside of working hours.

Prerequisites:
- Terraform v0.12.x or higher;
- AWS account with access configured in your development environment;
- Lambda functions files with properly configuration.

Created Resources:
- For EC2 instances:
    - AWS Lambda Functions: Two Lambda functions, start_ec2_instance and stop_ec2_instance, responsible for starting and stopping EC2 instances, respectively;
    - IAM Roles and Policies: Roles and Policies required to allow the Lambda functions to manage EC2 instances and be invoked by CloudWatch Events;
    - CloudWatch Event Rules and Targets: Rules to trigger the Lambda functions at scheduled times - stopping instances as needed;
    - Lambda Permissions: Permissions needed to allow CloudWatch Events to invoke the Lambda functions.

- For RDS instances:
    - Lambda Functions: `rds_stop` and `rds_start` for stopping and starting RDS instances, respectively;
    - IAM Role (`aws_iam_role.lambda_rds_role`) with policies that allow the Lambda functions to perform necessary actions on RDS instances;
    - IAM Policy (`aws_iam_role_policy.lambda_rds_policy`) specifying the allowed actions, such as starting and stopping RDS instances;
    - CloudWatch Event Rules: `schedule_rds_stop` and `schedule_rds_start` to schedule the stopping and starting of RDS instances;
    - CloudWatch Event Targets: `target_rds_stop` and `target_rds_start` that link the CloudWatch rules to the corresponding Lambda functions;
    - Lambda Permissions: Allows CloudWatch events to invoke the Lambda functions `rds_stop` and `rds_start`.

Changes in Scheduling:
- EC2 Instances:
    - For changes in the times when EC2 instances should stop, in the `main.tf` file in the `ec2_instances` folder, edit the `schedule_expression` on line 49 as desired;
    - For changes in the times when EC2 instances should start, in the `main.tf` file in the `ec2_instances` folder, edit the `schedule_expression` on line 93 as desired.

A syntax for filling in the times when the instances should start or stop must follow this format: 
`schedule_expression = "cron(Minute Hour DayOfMonth Month DayOfWeek Year)`

Additionally, the Lambda functions will need to be configured in the fields: 
`region_name` and `instance ID`.

- RDS Instances:
    - For changes in the times when RDS instances should stop, in the `main.tf` file in the `rds_instances` folder, edit the `schedule_expression` on line 56 as desired;
    - For changes in the times when EC2 instances should start, in the `main.tf` file in the `ec2_instances` folder, edit the `schedule_expression` on line 62 as desired.

To prevent the unavailability of resources, it is mandatory that RDS instances are started before EC2 instances, and for the action of stopping the instances, the logic to follow is the opposite; thus, RDS instances should be stopped before EC2 instances.

Before using the provided code, consider following the best practice of managing the Terraform backend. This ensures that the infrastructure is managed consistently and securely, especially in collaborative environments where multiple people or teams may be configuring resources simultaneously. With a centralized and versioned tfstate, conflicts and errors from outdated states are avoided, and auditing and restoring previous versions become possible, increasing the reliability and transparency of the entire operation.

To implement this practice efficiently, the detailed procedure was in the following project, which provides a backend configuration using S3 as an example:

https://github.com/deavelarthiago/terraform-s3-backend-management

This process provides a solid foundation to ensure shared and protected state, preparing the environment for the safe and organized execution of other projects.