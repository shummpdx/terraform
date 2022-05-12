# Terraform Projects

These directories are various small projects I've created to learn about the incorporation of AWS and terraform. 

## Directory Descriptions
### autoScaling

This directory will showcase auto scaling. We will create a launch configuration that will define an Amazon Linux VM with SSH capabilities. We will then create an autoscaling group that will spin up two EC2 instances based on the configurations. We'll then create a simple autoscaling policy that will create a single instance (_scaling_adjustment_) when triggered by a CloudWatch alarm. 

The CloudWatch alarm will check the CPU Utilization and when it's reached an *average* that is _greater than or equal to_ 20% utilization over a 2-minute period, it will trigger the *scale_up* policy.

We will also create a *scale_down* policy that will remove an instance if CPU utilization is _less than or equal to_ 10% over another 2-minute period.

To test that our policy works, we can use a utility called *stress*.
To install on an Amazon Linux VM:

1. SSH into your instance (you will need to change change the key name and deploy it if you haven't already done so)
2. Enter ```amazon-linux-extras install epel -y```
3. Enter ```yumm install stress```
4. Enter ```stress --cpu 8 --vm-bytes 1024```
5. Go back to your EC2 instances and select the machine you've SSH'd into -> then go to monitoring.
6. Wait awhile and the alarm should trigger the creation of another EC2 instance
7. ctrl+c the stress test
8. Once CPU utilization <= 10% the instance that was created should terminate. 

### expressions

This directory shows examples of working with *for*

### instances

This directory shows how to set up a basic EC2 instance with a keypair and allows SSH

### launchConfiguration
*Important: AWS recommends using _launch templates_ rather than _launch configurations_*

This directory showcases how a launch configuration is set up. Launch configurations are templates that an *autoscaling group* uses to launch an EC2 instance. Launch configurations take:
1. AMIs
2. Instance Type
3. Key Pair
4. Security Groups
5. Block Device Mapping

A launch template or EC2 instance can also be used for autoscaling groups. 

### modules
Modules are "containers for multiple resources that are used together." 

### networkACL
This directory will create an EC2 instance that uses NACLs to deny myself access to the apache page. 

## To Run
Inside of any particular directory enter 

```
terraform init
```

to initialize a working directory containing Terraform configuration files. You should always run this command when first working with Terraform so that it knows which providers will be required prior to running.

## Validate
Use 

```
terraform validate
```

to validate that your configurations are syntactically valid and internally consistent. 

## Plan
Use

```
terraform plan
```

to get an output of all the proposed changes that will occur when you are ready to apply. 

## Apply
Use

```
terraform apply
```

to run your configurations and begin building the described architecture. 