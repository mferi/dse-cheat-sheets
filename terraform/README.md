# Notes about using terraform
- Configure servers
- Deploy infrastructure

### First configure service provider
```
provider "aws" {
  region = "us-east-1"
}
```

### Create resources
resource <type_of_resource> <internal_identifier> {}

##### Example: create an EC2 instance
```hcl-terraform
resource "aws_instance" "some_identifier" {
  // AMI ID for Amazon Linux AMI 2016.03.0 (HVM)
  ami           = "ami-08111162"
  instance_type = "t2.micro"

  tags {
    Name = "some_name"
  }
}
```
### Initialise provider plugins
> terraform init

### See what you are about to deploy
> terraform plan

### Deploy your infrastructure
> terraform apply

### Variables
You can parameterise your configurations using variables. Description, type, default are optional.
##### Example:
```hcl-terraform
variable "foo"	{	
    description	= "The name of the EC2	instance"
}
```
Use interpolation syntax to reference your input variables
##### Example:
```${var.name}```
Also pass variables using the -var parameter
##### Example
> terraform	apply -var foo=bar

### Dependencies between resources
> terraform graph

### Destroy resources
> terraform destroy

### State
By default states are stored locally in *.tfstate files.
IMPORTANT: state files can content secrets at the moment of writing this, never commit to git
A backend can be configured and some allow locking, encryption and versioning.
##### Example
```hcl-terraform
terraform	{	
		backend	"s3"	{	
				bucket					=	"bucket-name"
				key								=	"project-name/terraform.tfstate"	
				region					=	"us-east-1"
				encrypt				=	true	
				dynamodb_table	=	"terraform-locks"
		}	
}
```
### Outputs
Highlights values when Terraform applies and can be queried with output command
```hcl-terraform
output "some_sfn_output" {
  value = "${aws_sfn_state_machine.some_identifier.status}"
}
```
### Data sources
Data defined outside your terraform (provider side for instance) can be fetched and used for configuration.
##### Example data for a trust policy to create IAM role to execute some service
```hcl-terraform
resource "aws_iam_role" "sfn_state_machine_role" {
  name               = "ExecutionRoleForSomeService"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy_trust.json}"
}


data "aws_iam_policy_document" "assume_role_policy_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}
```
### Modules
Like blueprints or building blocks. You specify module inputs in a different file like terraform.tfvars


### Loops : count
```hcl-terraform
resource "aws_instance" "example"	{	
				count	=	"${length(var.names)}"
				ami =	"${var.ami}"
				instance_type =	"t2.micro"	
				tags {
				  Name	= "${element(var.names,	count.index)}"
				 }	
}

variable "names"	{		
		default	=	["foo",	"bar"]	
		type =	"list"
}	
```

### Conditionals : count
In HCL true = 1 and false =	0
```hcl-terraform
resource "aws_instance" "example"	{	
				count	=	"${var.create_instance_boolean}"
				ami =	"ami-abcd1234"
				instance_type =	"t2.micro"	
				tags  {
				    Name	=	"${var.name}"
				    }	
}	
variable "create_instance_boolean"	{	
		default	= true
}
```
Ternary usage for conditionals is supported too
##### Example
If variable var is equal to "bar" then 1 otherwise 0
```"${var.foo == "bar" ? 1 : 0}"```	

### Recommended folder structure
Source: Gruntworks
```
infrastructure-live
        global	(Global	resources	such	as	IAM,	SNS,	S3)				
                └	iam
                └	sns
        stage	(Non-production	workloads,	testing)
                └	vpc
                └	mysql
                └	frontend	
        prod (Production	workloads,	user-facing	apps)
                └	vpc
                └	mysql
                └	frontend	
        mgmt	(DevOps	tooling	such	as	Jenkins,	Bastion	Host)
                └	vpc
                └	bastion
infrastructure-modules	
		└	vpc
		└	mysql			
		└	frontend
```