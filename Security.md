# Security to the infrastructure

In order to increase security in the EC2 instance we recommand using multiple security solution such as EDR in order to secure data and endpoints, and prevent, detect, and respond to threats.

You can use AWS services and third party solution offered in AWS [Marketplace](https://aws.amazon.com/marketplace) for that. 

We recommand [CrowdStrike](https://aws.amazon.com/marketplace/solutions/media-entertainment/edr/) as and EDR in order to have:

- Protection against malware and malware-free attacks for workloads
- Real-time and historical visibility into endpoint activity for threat detection, response, and forensics
- Integrated intelligence and proactive threat hunting (Falcon OverWatch) to provide an additional layer of oversight and analysis
- Visibility into workloads and assets across accounts and environments for better security and IT hygiene

![Alt text](url "Title")

We recommand also to have IPS or [IDS](https://aws.amazon.com/mp/scenarios/security/ids/) to increase security. You can also visit the [Marketplace](https://aws.amazon.com/marketplace) for that. 

You can either choose an EC2 instance IDS/IPS or you can choose to put a Next Gen Firewall.

We recommand NGFW : it will provide much of same protections as standard firewalls, while also adding application-level inspection, intrusion prevention, and full-stack visibility.

You can either put a [Fortinet VM](https://aws.amazon.com/marketplace/pp/prodview-wory773oau6wq?sr=0-4&ref_=beagle&applicationId=AWSMPContessa) or you physical FW if you have one. 
