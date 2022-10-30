# Recommendations for the AWS users and the root account management.

## Limit task performed by root user

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

## IAM User 

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
