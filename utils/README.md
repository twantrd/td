# Utility Tools ![alt-text](https://img.shields.io/badge/shell-bash-orange.svg "shellscript")
Script(s) to quickly fetch information from AWS

# Pre-requisites
1. This assumes that you have an AWS account already and have used `aws configure` (AWS CLI) to set up your default access/secret keys like so:
```
-bash-4.1$ aws configure
AWS Access Key ID [None]: blah
AWS Secret Access Key [None]: blah
Default region name [None]: us-west-2
Default output format [None]: json
``` 

# Usage
`gather_info.sh` - Display to stdout your ELB FQDN, ELB name, instance status, and public ip of your instances behind the LB. 
<br>
![alt-text](util_sshot.png?raw=true "screenshot")

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
