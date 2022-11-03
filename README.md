# 1. TPcloudAWS
- [1. TPcloudAWS](#1-tpcloudaws)
  - [1.1. Architecture diagrams](#11-architecture-diagrams)
  - [1.2. Flow matrix](#12-flow-matrix)
  - [1.3. Introduction](#13-introduction)
  - [1.4. Code structure](#14-code-structure)
  - [1.5. Terraform Modules](#15-terraform-modules)
    - [1.5.1. Networking module](#151-networking-module)
    - [1.5.2. WebServers module](#152-webservers-module)
  - [1.6. Modules calls and extra ressources](#16-modules-calls-and-extra-ressources)
  - [1.7. Scripts](#17-scripts)
  - [1.8. Terraform outputs](#18-terraform-outputs)
  - [1.9. Tags policy](#19-tags-policy)
  - [1.10. Usage](#110-usage)
  - [1.11. Demonstration](#111-demonstration)
    - [1.11.1. Elastic Load Balancer](#1111-elastic-load-balancer)
    - [1.11.2. Bastion host](#1112-bastion-host)
- [2. Best practices](#2-best-practices)
  - [2.1. Asymetric recommandations](#21-asymetric-recommandations)
  - [2.2. Symmetric recommandations](#22-symmetric-recommandations)
  - [2.3. Password creation](#23-password-creation)
    - [2.3.1. Password manager](#231-password-manager)
    - [2.3.2. Multi-factor authentication (MFA)](#232-multi-factor-authentication-mfa)
  - [2.4. AWS Bastion](#24-aws-bastion)
- [3. Recommendations for the AWS users and the root account management.](#3-recommendations-for-the-aws-users-and-the-root-account-management)
  - [3.1. Limit task performed by root user](#31-limit-task-performed-by-root-user)
  - [3.2. IAM User](#32-iam-user)
- [4. Security to the infrastructure](#4-security-to-the-infrastructure)
- [5. Other recommandations](#5-other-recommandations)
  - [5.1. Amazon Cloud Watch](#51-amazon-cloud-watch)
  - [5.2. Amazon Cloud trail](#52-amazon-cloud-trail)
  - [5.3. Amazon GuardDuty](#53-amazon-guardduty)

## 1.1. Architecture diagrams

![archi](https://user-images.githubusercontent.com/84475677/199694637-d6f2656b-9962-492d-84dc-c04f8e79e91d.png)


## 1.2. Flow matrix
![flow matrix](https://user-images.githubusercontent.com/84475677/197709780-8ed712af-26bf-408f-8df9-68c6cd836cee.png)


## 1.3. Introduction
All this project was made in terraform, I will try to resume my code in the next sections.
</br>
We added some extra things (compared to what was asked in the TP subject):
- We simulated webservers, backend servers and database servers using docker containers (deployed through user_data attribute in terraform)
- We deployed an Elastic Load Balancer (ELB) in frontend who listen to port 80 and forward to an Auto Scalling Group (of our webservers) to access web services. We dont have access to Amazon Certificate Manager to deploy service on HTTPS properly.
- We deployed a S3 Bucket with encryption, versioning and restrcited access for ELB logs
- We deployed a bastion host for devops team with correct security group. Unfortunately, we dont have access to marketplace to deploy bastion CIS host (hardened VM) but it's my recommendation.
- In some security groups, you will find an extra ip : `176.147.76.8/32`. It's my personnal internet box public Ip for test purposes and to reach web services and so on. Feel free to communicate your public IP so I can add it to security groups so you can also test services.

We added :
- EC2 encryption volumes (with KMS)
- Tags policy (Our own policy since AWS organization now available in labs accounts)
- VPC flowlogs to AWS cloudwatch

Nb: We didnt add network access list in our project cause since we have an ELB in public subnets, we cant specify his IP and we cant specify resource tag name in NACL. However, we highly recommend to use NGFW instead of NACL.

**All the code was written following the best practices enonced in the e-book >[here](https://www.terraform-best-practices.com)<**

A `.pre-commit-config.yaml` at the root of the project with some hooks :

- terraform-checkov
  - Analyse all your terraform code in a security point of view and alert you if he finds something wrong
  - Exemple : S3 bucket with public access; Security groups with lack of restrictions; and so on...
- terraform-tflint
  - Analyse all your terraform code and alert you if you have bad or deprecated code structure.

Others usefull hooks (check the .pre-commit-config.yaml)

## 1.4. Code structure
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

## 1.5. Terraform Modules

As you can see above, there is a modules folder who contains two subfolder : Networking and WebServers.

### 1.5.1. Networking module
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

### 1.5.2. WebServers module
The aim of this module is to deploy a full working entry point for your web servers facing the internet based on the input variable you give to him.
</br>
**Ressources deployed:**
-  Elastic Load Balancer with his S3 bucket for logs.
-  Auto Scaling Group
-  Auto Scaling Target Policy (based on CPU% utilization = 60%)
-  LaunchConfig
-  3 scripts called by user_data to install and deploy Docker containers

  **You will find all documentation about this module in the README.md in modules/WebServers folder, autogenerated by terraform-docs hook.**

## 1.6. Modules calls and extra ressources
The entrypoint of terraform is in mockinfra-env folder, this is where everything is regrouped. You will find in the main.tf  all resources that are to be deployed.
There is the modules calls and some extra ressources like the bastion host, backend host, database host, all of security groups needed, KMS keys, etc...


## 1.7. Scripts

We writed 3 differents bash scripts to deploy our services through user data with terraform. Those scripts will be executed right after the creation of the instance.
Here is an exemple of webservers.sh to install docker and start a container with nginx:

``` bash
#!/bin/bash

# Some sane options.
set -e # Exit on first error.
set -x # Print expanded commands to stdout.

sudo apt-get update &&
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release &&
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin &&

docker run --name static-site-2  -d -p 80:80 dockersamples/static-site
```
## 1.8. Terraform outputs
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


## 1.9. Tags policy
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

## 1.10. Usage
1. Clone the repository
2. Set up terraform, aws cli and pre-commit hooks
3. Set up your aws credentials (AWS ACCESS KEY and AWS SECRET KEY) for terraform
4. Go to the mockinfra-env folder
5. Add your public IP in security groups
6. `terraform init --upgrade`
7. `terraform plan`
8. `terraform apply`

## 1.11. Demonstration

### 1.11.1. Elastic Load Balancer

As you can see above, we fetched automaticly (at the end of the `terraform apply` process) the DNS name of our Elastic Load Balancers.

**Reminder**: Our ELB listen to port 80 and forward requests to available servers in our Auto Scaling Group who host the webservices (simple docker container with nginx)

Let's try to connect to our ELB: [http://ELB-mockinfrawebservers-1478364048.us-east-1.elb.amazonaws.com](http://ELB-mockinfrawebservers-1478364048.us-east-1.elb.amazonaws.com)

![hello docker](https://user-images.githubusercontent.com/84475677/199701018-91c6e61a-5445-4c97-bc51-d02f357713a6.png)

**We can see that our ELB returned us the answer given by the webservers that host the service**

### 1.11.2. Bastion host

We deployed a bastion host with an Elastic IP in a public subnet. Only devops can access the instance and only the bastion host can access to all the servers with SSH.
We decided to use ssh agent for devops so they can connect to all servers through the bastion host without stocking all private keys within it.
We didnt deploy it in an Auto Scaling Group but we followed best pratices and deployed it with auto recovery. If the instance fail EC2 instance heal chekcs, the instance will be rebuild instantly with same config (including Elastic IP)
EIP of bastion : `3.214.244.149`

1. We start the ssh agent on a devops machine
2. We add the private key to our agent(public key associated has been deployed on all servers with terraform)
3. We connect to our bastion host
   - ssh -A option :  Enables forwarding of connections from an authentication agent such as ssh-agent(1).


![bastion demo](https://user-images.githubusercontent.com/84475677/199689347-05825167-8291-494c-b759-3ca367c0f3a7.png)

![on bastion](https://user-images.githubusercontent.com/84475677/199690918-a05204ab-7fd0-4204-b9f1-1540c22cf62f.png)

**Now we are on our bastion host, let's connect to our database server in a private subnet**

Private IP of our DB server : `10.150.20.115`

![image](https://user-images.githubusercontent.com/84475677/199691202-6b2da047-5bcc-44d6-8e92-3f382fd0013f.png)

Now we are connected on our database and we can see mysql running :

![sqm running docker](https://user-images.githubusercontent.com/84475677/199692050-a887aee9-3425-43a1-ad26-3de954e705bd.png)

**We can also create a config file for ssh and specify a lot of different options to control the behavior of ssh, for exemple ssh user, identity file, etc...**

Here is the recommendations for SSH by ANSSI [>here<](https://www.ssi.gouv.fr/en/guide/openssh-secure-use-recommendations/)<


# 2. Best practices

## 2.1. Asymetric recommandations
The ANSSI recommand best pratcices relative to TLS protocol.
In fact, TLS is used everyday :
- ssh connect
- https website
- many other applications

There is 6 declinaisons of the SSL/TLS protocol nowadays : SSLv2, SSLv3, TLS, TLS 1.1, TLS 1.2 and TLS 1.3.
It is recommanded to use TLS 1.3, nevertheless TLS 1.2 can, under certain circumstances be considered as a strong usage.

You should use TLS 1.3 and accept TLS 1.2

You should **not** accept or use SSLv2, SSLv3, TLS 1.0 and TLS 1.1

During key exchange, the client must authentify the server.

The persistence privacy must be assured with PFS, you should use ephemeral Diffie-Hellman (ECDHE or by default, DHE)

If you want more information, please check this [link](https://www.ssi.gouv.fr/uploads/2020/03/anssi-guide-recommandations_de_securite_relatives_a_tls-v1.2.pdf
)



## 2.2. Symmetric recommandations

Prioritize AES or Chacha20 encryption algorithms
Tolerate Camelia and ARIA encryption algorithms

Hash functions: Only SHA-2 functions should be used, the others can not be considered as secure.



## 2.3. Password creation
[NIST recommandation](https://staysafeonline.org/online-safety-privacy-basics/passwords-securing-accounts/)
The 3 main ways to have a secure password are :
* Using strong password
* With a password manager
* With Multi-factor authentication (if available)

No matter what accounts they protect, all passwords should be created with these three guiding principles in mind:
- Long – Every one of your passwords should be at least 12 characters long.

- Unique – Each account needs to be protected with its own unique password. Never reuse passwords. This way, if one of your accounts is compromised, your other accounts remain secured. We’re talking really unique, not just changing one character or adding a “2” at the end – to really trick up hackers, none of your passwords should look alike.
- Complex – Each unique password should be a combination of upper case letters, lower case letters, numbers and special characters (like >,!?). Again, remember each password should be at least 12 characters long. Some websites and apps will even let you include spaces.

If your password is long, unique and complex, our recommendation is that you don’t need to ever change it unless you become aware that an unauthorized person is accessing that account, or the password was compromised in a data breach.

### 2.3.1. Password manager
[Password manager](https://staysafeonline.org/online-safety-privacy-basics/password-managers/)

But having such different and complex password for every application we use is really difficult to remember, that why it is also recommanded to use password manager instead of a messy note that are free access.

The password manager will be an encrypted that no one can break. And you just need to remember one strong password in order to access all your passwords.

NIST recommand different password manager options :
- Keeper
- Bitwarden
- 1Password
- Dashlane
- LastPass

### 2.3.2. Multi-factor authentication (MFA)
[MFA](https://staysafeonline.org/online-safety-privacy-basics/multi-factor-authentication/)

Multi-factor authentication is sometimes called two-factor authentication or two-step verification, and it is often abbreviated to MFA. No matter what you call it, MFA is a cybersecurity measure for an account that requires anyone logging in to prove their identity multiple ways. Typically, you will enter your username, password, and then prove your identity some other way, like with a fingerprint or by responding to a text message.

We recommend that you implement MFA for any account that permits it, especially any account associated with work, school, email, banking, and social media.

- Different forms of MFA :
    - Extra PIN as well as you password
    - Extra security question
    - Code sent to your email or sms
    - Biometric identifiers like facial recongnition or fingerprint scan
    - Standalone app that requires you to approve each attempt to access an account
    - An additional code either emailed to an account or texted to a mobile number
    - A secure token – a separate piece of physical hardware, like a key fob, that verifies a person’s identity with a database or system

You have different MFA software such as :
- Google authenticator
- Authy
- Microsoft authenticator for microsoft applications


## 2.4. AWS Bastion

To access your EC2 instance on your private subnets from remote location while being secure, we recommand to setup a Linux bastion host

Amazon give a [Quick Start Deployment Guide
](https://aws-quickstart.github.io/quickstart-linux-bastion/) that I will explain here.

Deploying this Quick Start with default parameters builds the following Linux Bastion Hosts environment in the AWS Cloud.

Architecture :

![linux-bastion-architecture](https://user-images.githubusercontent.com/71137818/199471061-56b15d26-2734-438c-a8ad-7f3b1a51f635.png)

- A highly available architecture that spans two Availability Zones.*
- A virtual private cloud (VPC) configured with public and private subnets, according to AWS best practices, to provide you with your own virtual network on AWS.*
- In the public subnets:

    - Managed network address translation (NAT) gateways to allow outbound internet access for resources in the private subnets.*

  - A Linux bastion host in an Auto Scaling group for connecting to Amazon Elastic Compute Cloud (Amazon EC2) instances in public and private subnets.

- An Amazon CloudWatch log group to hold the Linux bastion host shell history logs.

- AWS Systems Manager for access to the bastion host.

<sub> \*The template that deploys this Quick Start into an existing VPC skips the components marked by asterisks and prompts you for your existing VPC configuration. <sub>

The point to have the Linux bastion host in an Auto Scaling group is that if you only have 1 Bastion host, it is known as a SPOF (Single Point of Failure), which means that none of your instance are accecible if just only 1 bastion host goes down. With the Auto scaling group, the SPOF is eliminated and we can access the different EC2 instance even if one bastion host goes down.

It is also recommanded not to store the different private key on the Bastion host and use [ssh Agent Forwarding](https://www.ssh.com/academy/ssh/agent#ssh-agent-forwarding) instead



https://staysafeonline.org/programs/cybersecurity-awareness-month/

https://staysafeonline.org/online-safety-privacy-basics/passwords-securing-accounts/

https://www.nist.gov/blogs/cybersecurity-insights/cybersecurity-awareness-month-2022-using-strong-passwords-and-password

https://downloads.cisecurity.org/#/

https://aws.amazon.com/solutions/implementations/linux-bastion/

https://tsapps.nist.gov/publication/get_pdf.cfm?pub_id=901083

https://docs.aws.amazon.com/config/latest/developerguide/security-best-practices-for-aws-waf.html

https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r4.pdf


# 3. Recommendations for the AWS users and the root account management.

## 3.1. Limit task performed by root user

Amazon recommand that you should only use root user for specifis [tasks]([linkurl](https://docs.aws.amazon.com/accounts/latest/reference/root-user-tasks.html)) **only** :
 - To create the first [administrator]([linkurl](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)) user in AWS IAM
 - To perform tasks that ***only*** root user can perform :
   - those tasks are :
     - Change account settings
     - Restore IAM permissions
     - Activate IAM access to the Billing and Cost management console
     - View certain tax invoices
     - Close you AWS account
     - Register as a seller
     - Enable S3 bucket with MFA
     - Edit or delete an Amazon Simple Storage Service (Amazon S3) bucket policy that includes an invalid virtual private cloud (VPC) ID or VPC endpoint ID
     - Sign up for GovCloud

So except thoses tasks : **Do not user the root user**

- Do not use your AWS account root user access key
  - If you don't already have an access key for your AWS account root user, don't create one unless you absolutely need to. Instead, use the root user to create an IAM user for yourself that has administrative permissions.
  - If you must keep one available, [rotate](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_RotateAccessKey) (change) the access key regularly.
  - If you do have an access key for your root user, delete it.
  - Never share your AWS account root user password or access keys with anyone
  - Use a strong password to help protect access to the AWS Management Console
  - Enable AWS multi-factor authentication ([MFA](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa.html)) on your AWS account root user account.



https://docs.aws.amazon.com/accounts/latest/reference/root-user-tasks.html

https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_RotateAccessKey

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa.html

## 3.2. IAM User

- Use temporary credentials
- Require multi-factor authentication (MFA)
- Rotate access keys regularly for use cases that require long-term credential
- Apply least-privilege permissions:
  - grant only the permissions required to perform a task.
    - For that you can use [IAM Access Analyzer]([linkurl](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-policy-generation.html))  to generate least-privilege policies based on access activity
- Regularly review and remove unused users, roles, permissions, policies, and credentials

https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-policy-generation.html

https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html

https://aws.amazon.com/iam/resources/best-practices/




# 4. Security to the infrastructure

In order to increase security in the EC2 instance we recommand using multiple security solution such as EDR in order to secure data and endpoints, and prevent, detect, and respond to threats.

You can use AWS services and third party solution offered in AWS [Marketplace](https://aws.amazon.com/marketplace) for that.

We recommand [CrowdStrike](https://aws.amazon.com/marketplace/solutions/media-entertainment/edr/) as and EDR in order to have:

- Protection against malware and malware-free attacks for workloads
- Real-time and historical visibility into endpoint activity for threat detection, response, and forensics
- Integrated intelligence and proactive threat hunting (Falcon OverWatch) to provide an additional layer of oversight and analysis
- Visibility into workloads and assets across accounts and environments for better security and IT hygiene

![firefox_pi8hiIUrbZ](https://user-images.githubusercontent.com/71137818/198871049-b4418b5f-3695-41d9-a180-f28002764605.png)

We recommand also to have IPS or [IDS](https://aws.amazon.com/mp/scenarios/security/ids/) to increase security. You can also visit the [Marketplace](https://aws.amazon.com/marketplace) for that.

You can either choose an EC2 instance IDS/IPS or you can choose to put a Next Gen Firewall.

We recommand NGFW : it will provide much of same protections as standard firewalls, while also adding application-level inspection, intrusion prevention, and full-stack visibility.

You can either put a [Fortinet VM](https://aws.amazon.com/marketplace/pp/prodview-wory773oau6wq?sr=0-4&ref_=beagle&applicationId=AWSMPContessa) or you physical FW if you have one.


# 5. Other recommandations

We also recommand 3 other AWS tools to increasing security and monitoring of your infrastrucure.

Here are the 3 tools recommanded :

- [Cloud Watch](#51-amazon-cloud-watch)
- [Cloud trail](#52-amazon-cloud-trail)
- [Guarduty](#53-amazon-guardduty)


## 5.1. Amazon Cloud Watch

Amazon [CloudWatch](https://aws.amazon.com/cloudwatch/?nc1=h_ls) collects and visualizes real-time logs, metrics, and event data in automated dashboards to streamline your infrastructure and application maintenance.

<img width="1180" alt="Product-Page-Diagram_Amazon-CloudWatch (1) e9686469670ce5278b9ccf847834f40d5874efa4" src="https://user-images.githubusercontent.com/71137818/199541365-6de5f745-d149-4d7e-82a1-0d74f4e88b50.png">

You can create alarms that watch metrics and send notifications or automatically make changes to the resources you are monitoring when a threshold is breached. For example, you can monitor the CPU usage and disk reads and writes of your Amazon EC2 instances and then use that data to determine whether you should launch additional instances to handle increased load. You can also use this data to stop under-used instances to save money.

It can be used for different cases :

- Monitor application performance
  - Visualize performance data, create alarms, and correlate data to understand and resolve the root cause of performance issues in your AWS resources.
- Perform root cause analysis
  - Analyze metrics, logs, logs analytics, and user requests to speed up debugging and reduce overall mean time to resolution.
- Optimize resources proactively
  - Automate resource planning and lower costs by setting actions to occur when thresholds are met based on your specifications or machine learning models.
- Test website impacts
  - Find out exactly when your website is impacted and for how long by viewing screenshots, logs, and web requests at any point in time.

You can check [here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html) the **Related AWS services** and how to **Access CloudWatch**

All the [features](https://aws.amazon.com/cloudwatch/features/) about AWS CloudWatch



## 5.2. Amazon Cloud trail

AWS [CloudTrail](https://aws.amazon.com/cloudtrail/?nc1=h_ls) monitors and records account activity across your AWS infrastructure, giving you control over storage, analysis, and remediation actions.

![product-page-diagram_AWS-CloudTrail_HIW feb63815c1869399371b4b9cc1ae00e78ed9e67f](https://user-images.githubusercontent.com/71137818/199541385-a952a01d-d6dc-4f53-9294-492c2227430b.png)

It can be used for different cases :

- Audit activity
  - Monitor, store, and validate activity events for authenticity. Easily generate audit reports required by internal policies and external regulations.
- Identify security incidents
  - Detect unauthorized access using the Who, What, and When information in CloudTrail Events. Respond with rules-based EventBridge alerts and automated workflows.
- Troubleshoot operational issues
  - Continuously monitor API usage history using machine learning (ML) models to spot unusual activity in your AWS accounts, and determine root cause.

More information [here](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html)

All the [features](https://aws.amazon.com/cloudtrail/features/) about AWS CloudWatch


## 5.3. Amazon GuardDuty

Amazon [GuardDuty](https://aws.amazon.com/guardduty/?nc1=h_ls) is a threat detection service that continuously monitors your AWS accounts and workloads for malicious activity and delivers detailed security findings for visibility and remediation.

![Amazon-GuardDuty_HIW 057a144483974cb73ab5f3f87a50c7c79f6521fb](https://user-images.githubusercontent.com/71137818/199541397-f4ef17fd-69b6-4c0f-8d0e-fa9d76d39ff6.png)

It can be used for different cases :
- Improve security operations visibility
  - Gain insight of compromised credentials, unusual data access in Amazon S3, API calls from known malicious IP addresses, and more.
- Assist security analysts in investigations
  - Receive security event findings with context, metadata, and impacted resource details, and determine their root cause using GuardDuty console integration with Amazon Detective.
- Identify files containing malware
  - Scan Amazon Elastic Block Store (EBS) for files that might have malware creating suspicious behavior on instance and container workloads running on Amazon EC2.
- Route insightful information on security findings
  - Route findings to your preferred operational tools using integrations with AWS Security Hub and Amazon EventBridge.

More information [here](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html)

All the [features](https://aws.amazon.com/guardduty/features/) about AWS CloudWatch
