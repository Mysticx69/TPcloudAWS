We also recommand 3 other AWS tools to increasing security and monitoring of your infrastrucure. 

Here are the 3 tools recommanded : 

- [Cloud Watch](#amazon-cloud-watch) 
- [Cloud trail](#amazon-cloud-trail)
- [Guarduty](#amazon-guardduty) 


## Amazon Cloud Watch

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



## Amazon Cloud trail

AWS CloudTrail monitors and records account activity across your AWS infrastructure, giving you control over storage, analysis, and remediation actions.

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


## Amazon GuardDuty

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

