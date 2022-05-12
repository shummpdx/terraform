# Terraform Projects

These directories are various small projects I've created to learn about the incorporation of AWS and terraform. 

## Directory Descriptions
### autoScaling

This directory will showcase auto scaling. We will create a launch configuration that will define an Amazon Linux VM with SSH capabilities. We will then create an autoscaling group that will spin up two EC2 instances based on the configurations. We'll then create a simple autoscaling policy that will create a single instance (_scaling_adjustment_) when triggered by a CloudWatch alarm. 

The CloudWatch alarm will check the CPU Utilization and when it's reached an *average* that is _greater than or equal to_ 20% utilization over a 2-minute period, it will trigger the *scale_up* policy.

We will also create a *scale_down* policy that will remove an instance if CPU utilization is _less than or equal to_ 10% over another 2-minute period.

To test that our policy works, we can use a utility called *stress*.
To install on an Amazon Linux VM use:

This will spin up an autoscaling group based on the health cehcks done on the EC2 instances. It creates a **launch configuration** that will be used to spin up an EC2 instance. It is set up to spin up two EC2 instances. If one, or both, do not pass the health check the autoscaling group will initialize the necessary number of instances so that the minimum size is always met. 

## To Run
Inside of any particular directory enter 

'''
    terraform init
'''

to initialize a working directory containing Terraform configuration files. You should always run this command when first working with Terraform so that it knows which providers will be required prior to running.

## Validate
Use 

'''
terraform validate
'''

to validate that your configurations are syntactically valid and internally consistent. 

## Plan
Use

'''
terraform plan
'''

to get an output of all the proposed changes that will occur when you are ready to apply. 

## Apply
Use

'''
terraform apply
'''

to run your configurations and begin building the described architecture. 