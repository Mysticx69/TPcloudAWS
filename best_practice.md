
# TSL Recommandations

## Asymetric recommandations 
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



## Symmetric recommandations 

Prioritize AES or Chacha20 encryption algorithms 
Tolerate Camelia and ARIA encryption algorithms 

Hash functions: Only SHA-2 functions should be used, the others can not be considered as secure. 



# Password creation 
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

### Password manager 
[Password manager](https://staysafeonline.org/online-safety-privacy-basics/password-managers/)

But having such different and complex password for every application we use is really difficult to remember, that why it is also recommanded to use password manager instead of a messy note that are free access.

The password manager will be an encrypted that no one can break. And you just need to remember one strong password in order to access all your passwords. 

NIST recommand different password manager options : 
- Keeper
- Bitwarden 
- 1Password 
- Dashlane
- LastPass

### Multi-factor authentication (MFA) 
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


# AWS Bastion 

To access your EC2 instance on your private subnets from remote location while being secure, we recommand to setup a Linux bastion host 

Amazon give a [Quick Start Deployment Guide
](https://aws-quickstart.github.io/quickstart-linux-bastion/) that I will explain here.

Deploying this Quick Start with default parameters builds the following Linux Bastion Hosts environment in the AWS Cloud.

Architecture :

IMAGE architecture 

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
