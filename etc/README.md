# AWS provisioning with Ansible & Terraform ![alt-text](https://img.shields.io/badge/ansible-2.3.0.0-blue.svg) ![alt-text](https://img.shields.io/badge/terraform-0.9.5-green.svg)
Sample setup of using Terraform to bring up infrastructure (ec2 instances, ELB, keypair, secgroups) and using Ansible as a provisioner for config mgmt.

# References
List of links below for reference
* [Terraform](https://www.terraform.io/)
* [Ansible](https://www.ansible.com/)

# Pre-requisites
1. For the account running this, generate ssh keys and place the public key in the `aws_key_pair` resource
2. This assumes that you have an AWS account already and have used `aws configure` (AWS CLI) to set up your default access/secret keys like so:
```
-bash-4.1$ aws configure
AWS Access Key ID [None]: blah
AWS Secret Access Key [None]: blah
Default region name [None]: us-west-2
Default output format [None]: json
``` 

# Setup
* Copy `ansible` dir to `/etc/` 
* Copy `terraform` dir to `/etc/`

# Usage
* terraform plan (to see what terraform will do)
* terraform apply (to provision infrastructure)
	* This will also locally execute ansible playbooks to provision Apache and Nginx listening on non-standard ports for illustration purposes<p>
![alt-text](terra_sshot.png?raw=true "screenshot")

# Contributing
Use the git-flow process: <br>
http://yakiloo.com/getting-started-git-flow/ <br>
https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow

1. Fork the repository on Github
2. Create a named feature branch (like add_component_x)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github
