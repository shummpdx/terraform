This folder contains sample variable use cases
1. terraform.tfvars
2. Unique file name (Not autoloaded)
3. Unique file name (Autoloaded)
4. Variables from CLI

Order of Precedence:
Terraform uses the *last* value it finds. 

1. Enviornment Variables
2. terraform.tfvars
3. terraform.tfvars.json
4. *.auto.tfvars/\*.auto.tfvars.json
5. Any -var and -var-file from CLI (in the order they are provided)

Name the file as "terraform.tfvars" to autoload variable files

To run with additional variable file NOT autoloaded we use the command:
terraform plan -var-file=myVars.tfvars

To run with additional variable file autoloaded we use put:
"*.var.tfvars"
to autoload a variable file with a unique filename.

To enter variables from the command line use:
terraform plan -var=instance_type=t2.nano

We can add a "description"  argument to the variable that will prompt us when we don't provide the variable.
We can add a "senstive" argument to the variable that will hide the variable when we do a "terraform plan."
It will still be visible in the terraform.tfstate file
We can add a "validation" argument with a condition 