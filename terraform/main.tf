# Configure service provider
provider "aws" {
  region = "us-east-1"
}

# Create an EC2 instance
resource "aws_instance" "some_identifier" {
  // AMI ID for Amazon Linux AMI 2016.03.0 (HVM)
  ami           = "ami-08111162"
  instance_type = "t2.micro"

  tags {
    Name = "some_name"
  }
}

resource "aws_eip" "some_identifier" {
  instance = "${aws_instance.some_identifier.id}"
}

output "public_ip_address" {
  // Interpolation syntax TYPE.NAME.ATTRIBUTE
  value = "${aws_instance.some_identifier.public_ip}"
}

# Create a State Machine https://www.terraform.io/docs/providers/aws/r/sfn_state_machine.html
resource "aws_sfn_state_machine" "some_identifier" {
  name     = "some_name"
  role_arn = "some_iam_role_arn"

  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using a Pass state",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Pass",
      "Result": "Hello MyDrive",
      "End": true
    }
  }
}
EOF
}

#########################################
# Create IAM role to execute Some Service
#########################################
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
