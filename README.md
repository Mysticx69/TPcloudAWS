# 1. TPcloudAWS
- [1. TPcloudAWS](#1-tpcloudaws)
  - [1.1. Introduction](#11-introduction)
  - [1.2. Code structure](#12-code-structure)
  - [1.3. Terraform Modules](#13-terraform-modules)
    - [1.3.1. Networking module](#131-networking-module)
    - [1.3.2. WebServers module](#132-webservers-module)
  - [1.4. Modules calls and extra ressources](#14-modules-calls-and-extra-ressources)
  - [1.5. Terraform outputs](#15-terraform-outputs)
  - [1.6. Tags policy](#16-tags-policy)
  - [1.7. Usage](#17-usage)
  - [1.8. Demonstration](#18-demonstration)
  - [1.9. Useful links](#19-useful-links)
  - [1.10. TODO list](#110-todo-list)
  - [1.11. Architecture](#111-architecture)
  - [1.12. Flow matrix](#112-flow-matrix)

## 1.1. Introduction
All this project was made in terraform, I will try to resume my code in the next sections.
</br>
We added some extra things (compared to what was asked in the TP subject):
- We simulated webservers, backend servers and database servers using docker containers (deployed through user_data attribute in terraform)
- We deployed an Elastic Load Balancer (ELB) in frontend who listen to port 80 and forward to an Auto Scalling Group (of our webservers) to access web services. We dont have access to Amazon Certificate Manager to deploy service on HTTPS.
- We deployed a bastion host for devops team with correct security group. Unfortunately, we dont have access to marketplace to deploy bastion CIS host (hardened VM) but it's my recommendation.
- In some security groups, you will find an extra ip : `176.147.76.8/32`. It's my personnal internet box public Ip for test purposes and to reach web services and so on. Feel free to communicate your public IP so I can add it to security groups so you can also test services.

**All the code was written following the best practices enonced in the e-book >[here](https://www.terraform-best-practices.com)<**

A `.pre-commit-config.yaml` at the root of the project with some hooks :

- terraform-checkov
  - Analyse all your terraform code in a security point of view and alert you if he finds something wrong
- terraform-tflint
  - Analyse all your terraform code and alert you if you have bad or deprecated code structure.

Others usefull hooks (check the .pre-commit-config.yaml)

## 1.2. Code structure
```bash
.
|-- README.md
`-- terraform
    |-- mockinfra-env
    |   |-- backend.tf
    |   |-- main.tf
    |   |-- output.tf
    |   `-- provider.tf
    `-- modules
        |-- Networking
        |   |-- README.md
        |   |-- main.tf
        |   |-- output.tf
        |   `-- variables.tf
        `-- WebServers
            |-- AutoScalingGroup.tf
            |-- AutoscaleTargetPolicy.tf
            |-- ElasticLoadBalancer.tf
            |-- LaunchConfig.tf
            |-- README.md
            |-- output.tf
            |-- scripts
            |   |-- backend.sh
            |   |-- mysql.sh
            |   `-- webservers.sh
            |-- variables.tf
            `-- versions.tf
  ```

## 1.3. Terraform Modules

As you can see above, there is a modules folder who contains two subfolder : Networking and WebServers.

### 1.3.1. Networking module
The aim of this module is to deploy a full network infrastructure based on the input variables you give to him.
</br>
**Resources deployed:**
- VPC
- Subnets
- Internet Gateway
- NAT Gateway
- Route tables (for public subnets => to IGW ; for private subnets => to NAT gateway)
- Route rules
- Route association
- Default VPC security group

**You will find all documentation about this module in the README.md in modules/Networking folder, autogenerated by terraform-docs hook.**

### 1.3.2. WebServers module
The aim of this module is to deploy a full working entry point for your web servers facing the internet based on the input variable you give to him.
</br>
**Ressources deployed:**
-  Elastic Load Balancer with his S3 bucket for logs.
-  Auto Scaling Group
-  Auto Scaling Target Policy (based on CPU% utilization = 60%)
-  LaunchConfig
-  3 scripts called by user_data to install and deploy Docker containers

  **You will find all documentation about this module in the README.md in modules/WebServers folder, autogenerated by terraform-docs hook.**

## 1.4. Modules calls and extra ressources
The entrypoint of terraform is in mockinfra-env folder, this is where everything is regrouped. You will find in the main.tf  all resources that are to be deployed.
There is the modules calls and some extra ressources like the bastion host, backend host, database host, all of security groups needed, KMS keys, etc...

## 1.5. Terraform outputs
I writted some usefull terraform outputs (fetched after resources creation) :

```bash
default_sg_id = "sg-06de06d5b9f665c8a"
elb_dns_name = [
  "ELB-mockinfrawebservers-1478364048.us-east-1.elb.amazonaws.com",
]
elb_sg_id = "sg-0d41f3190fd9dd358"
private_subnets_id = [
  [
    "subnet-05abe123599f8b303",
    "subnet-07d5672769d6ef791",
  ],
]
public_subnets_cidr = [
  [
    "10.150.1.0/24",
    "10.150.2.0/24",
  ],
]
public_subnets_id = [
  [
    "subnet-0ff8934b45cacc2a2",
    "subnet-053f657183e7b2e18",
  ],
]
vpc_cidr = "10.150.0.0/16"
vpc_id = "vpc-0db3fdc08d4e1a198"
webser_sg_id = "sg-0b60744ce66441a95"
```

**You can find them in the output.tf files**


## 1.6. Tags policy
We added some default tags for every resources terraform will deployed. You can find them in provider.tf in mockinfra-env folder:
```terraform
default_tags {
    tags = {
      Authors     = "Antoine STERNA-Remi GRUFFAT"
      Project     = "Awscloudproject-5IRC"
      Environment = "MockInfrastructure"
      DeployedBy  = "Terraform"
    }
  }
```
That means every ressources (except auto scalling group) will have these tags in addition to the others when ressources are deployed

## 1.7. Usage
1. Clone the repository
2. Set up terraform, aws cli and pre-commit hooks
3. Set up your aws credentials (AWS ACCESS KEY and AWS SECRET KEY) for terraform
4. Go to the mockinfra-env folder
5. `terraform init --upgrade`
6. `terraform plan`
7. `terraform apply`

## 1.8. Demonstration

As you can see above, we fetched automaticly (at the end of the `terraform apply` process) the DNS name of our Elastic Load Balancers.

**Reminder**: Our ELB listen to port 80 and forward requests to available servers in our Auto Scaling Group who host the webservices (simple docker container with nginx)

Let's try to connect to our ELB: [http://ELB-mockinfrawebservers-1478364048.us-east-1.elb.amazonaws.com](http://ELB-mockinfrawebservers-1478364048.us-east-1.elb.amazonaws.com)

![image](https://user-images.githubusercontent.com/84475677/198371167-e66e8214-4933-49b5-a538-4e592ea363cc.png)

**We can see that our ELB returned us the answer given by the webservers that host the service**









































## 1.9. Useful links
</br>

[links](https://aws.amazon.com/architecture/security-identity-compliance/?cards-all.sort-by=item.additionalFields.sortDate&cards-all.sort-order=desc&awsf.content-type=*all&awsf.methodology=*all)
[ssh best practices (from original author)](https://nvlpubs.nist.gov/nistpubs/ir/2015/nist.ir.7966.pdf)
## 1.10. TODO list
- EC2 encryption volumes (voir KMS)
- VPC flowlogs
- multi-tier infrastructure (Presentation - Application - Data)
- TAGS
- Give recommendations for the AWS users and the root account management.
- Give recommendations on which AWS or other third-party services can be used to add
  security to the infrastructure, for example EDR (Endpoint Detection and Response), IDS
  (Intrusion detection system), IPS (Intrusion prevention system) => marketplace? Fortigate, palo alto (for firewall) etc
- **Review at least 2 guidelines or best practices (from NIST, ANSSI or CIS) and
  describe 3 best practices that we should apply for this kind of infrastructure
  NIST: https://csrc.nist.gov/publications/sp800
  ANSSI: https://www.ssi.gouv.fr/administration/bonnes-pratiques/
  CIS: https://downloads.cisecurity.org/**
 - Tag policies (AWS organazitations) => Unfortunately, no rights on this service with labs account
 - Infra AWS draw.io

## 1.11. Architecture

![Architecture](https://user-images.githubusercontent.com/84475677/197707646-c85bcebc-6ee1-4538-8038-2d6735579699.png)

## 1.12. Flow matrix
![flow matrix](https://user-images.githubusercontent.com/84475677/197709780-8ed712af-26bf-408f-8df9-68c6cd836cee.png)
