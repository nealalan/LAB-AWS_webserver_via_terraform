## [nealalan.github.io](https://nealalan.github.io)/[LAB-AWS_webserver_via_terraform](https://nealalan.github.io/LAB-AWS_webserver_via_terraform)

# Project Goal
- Stay security minded by restricting network access and creating a secure web server. 
- Create a secure web server within the free tier of AWS.
- Fully automate the creation of a Virtual Private Cloud and all necessary components.
- Automate, as much as possible, the installation and configuration of an NGINX webserver.
- Pull the website source data from github.
- Note: Installing a quality file editor such as [Atom](https://atom.io/) is highly recommended!

# Project Files
You should have a good understanding of the files involved and the filesystem used on your computer and the webserver. I will go more in depth in the below sections on where these files come from and how to edit them.

## Files I'm providing for you to edit
- [vpc.tf](https://github.com/nealalan/tf-201812-nealalan.com/blob/master/vpc.tf) - a consolidated terraform file (infrastructure as code) to create a VPC, associated components and an EC2 Ubuntu instance in a Public Subnet
  - best practice is to separate out the terraform components into sections, but this worked out well for me to have it in one file
  - I can see a good practice in storing the variables in a separate .tf file - which is what terraform recommends
- [install.sh](https://github.com/nealalan/tf-201812-nealalan.com/blob/master/install.sh) - shell script to configure the Ubuntu instance to configure NGINX web server with secure websites (https)
  - website are automatically pulled from git repos for respective sites

## Your system (computer and webserver)
- ~/ - your home folder on both your computer (if using a Mac or Linux based system) 
  - Mine, on my Mac is /home/neal/ and on the Ubuntu webserver it is /home/ubuntu/)
  - The tilde is just a shortcut to the default location of all of your files. If you type the commande "cd" you will always be returned to the home folder.
- ~/Projects/ - where your projects should be located, including the scripts you pull down

## 'Hidden' files the system uses
You will need to understand what these files are and be able to edit these files

- ~/.ssh/web-site.pem - Private key for you only. Good idea to store a copy in your pwd mgr.
- ~/.ssh/web-site-pub-key.pem - Public key so you can connect to your server. 
  - This is stored on AWS and in Ubuntu.
- ~/.ssh/known_hosts - System file that stores a key fingerprint
  - If you delete and recreate the same instance many times, you'll have to remove 'offending' records from here
- ~/.aws/credentials - the file that will store your automated AWS keys and secret keys

# Section 1 - [AWS Account](https://aws.amazon.com/) Setup.
![](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/blob/master/images/AWSfreetier.png?raw=true)
- If you have a .edu email address you can sign up for an educational account. No credit card required! Keep this forever!
- You will have to enter a credit card, but will still be given "free tier" credit. 
  - Don't worry, if you have a major mishap and some charges, AWS will be nice enough to credit you. 
  - But you'll want a credit card on file if you decide to buy a domain name(s) and use Route 53.
- Now, create your AWS root account!

## Billing
Lets talk about billing. Even though you are using the Free Tier, it is your responsibility to understand the limits and stay within them.

- It's important to watch your use! 
  - Be prepared to be charged a few dollars if you don't pay attention to the terms. 
  - You can avoid charges by reading pricing documentation before you create anything.
  - You can be notified immediately of charges if you setup alerts!
- Examples of overage charges: 
  - If you run more than 750 hours of EC2 instances in a month (there are 744 in a month) you can be charged. 
  - If you use more than 30 GB of space, irrelevant of the instance running, you will be charged. 
  - If you have an Elastic IP that isn't assigned to an active instance or gateway, you will be charged per hour.
  - If you register a domain name and use the DNS service within AWS, you will be charged. 
- Understand and watch [billing](https://console.aws.amazon.com/billing/home?region=no-region#/bills) and [cost explorer](https://console.aws.amazon.com/billing/home?region=no-region#/). 
- If you do see a few charges, don't panic and try to destroy everything. Seek guidance.
  - If you destroy things, you may miss what is actually causing the charges. And may cause MORE charges!

# Section 2 - AWS Security
First, you need a password manager! 
- If you're not using a password manager, you might not be ready for cloud technology! 
- You will have a number of keys and passwords to keep track of. Keep them in your password manager!
- Here's a good article on password managers... [Consumer Reports: Everything You Need to Know About Password Managers](https://www.consumerreports.org/digital-security/everything-you-need-to-know-about-password-managers/)

- When you create an account, you will be shown a number of pieces of data. Store these in your password manager! The data is for your root account. 
	- AWS Console address: https://<account-id-number>.signin.aws.amazon.com/console
	- Username & Password
	- Account ID
	- Access Key ID
	- Secret Access Key
	
## Identity and Access Management (IAM) & Account Security
- The [IAM Dashboard](https://console.aws.amazon.com/iam) will give you security status recomendations. 
  - Read them. 
  - Understand them. 
  - Put yourself in compliance. 
  - You don't want someone to penetrate account, start running crypto mining and give you a bill for $10,000. 
  - It's happened.

![](https://raw.githubusercontent.com/nealalan/EC2_Ubuntu_LEMP/master/iam.png)
- It is recommended you setup MFA (Multi-factor Authentication) for your root account.
- A couple of soft token apps for your phone include:
  - [Last Pass Authenticator](https://lastpass.com/auth/) (since you should be using LastPass anyway!)
  - Google Authenticator

### Create new users in [IAM](https://console.aws.amazon.com/iam/home?=#/users)

#### New User: Administrator user. 
- This will actually be what you use for doing anything in AWS via a browser. 
- It's a best practice not to log in with your root account.
- I use my actual email address as my root and the first part (login) of my email as my main account. 
- Select AWS access type: AWS Management Console

#### New User: terraform user. 
- This is what the script will use from your computer for access to AWS.
- Select AWS access type: Programmatic access
![](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/blob/master/images/Screen%20Shot%202018-12-13%20at%207.29.42%20PM.jpg?raw=true)
- Attach existing policies:
  - AmazonVPCFullAccess
  - AmazonEC2FullAccess 
- Grab your "Access Key ID" and "Secret Access Key" now. Save them in your Password Manager!
  - **This will be the only opportunity** for you to save the "Secret Access Key".

![](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/blob/master/images/Screen%20Shot%202018-12-13%20at%207.45.39%20PM.jpg?raw=true)
- Note: it is important that you don't share these keys for anything. You want to make sure the secret key is never exposed on a webpage or on github.

## Public / Private Access Keys
- These are seperate from the IAM access key! You will need to create a key pair for use with the web server. 
  - The public key will be stored on and used by the webserver. 
  - The private key will be used to connect from you computer to the web server.

### Generate a Private key
- Use [EC2: Key Pairs](https://us-east-2.console.aws.amazon.com/ec2/v2/home?#KeyPairs:sort=keyName) to generate a key for AWS storage and EC2 connectivity.
  - This process will download a file such as web-site.pem - your private key
  - Save your keys to your home folder under a subfolder called .ssh/
  - DELETE THE KEY YOU CREATED FROM EC2: Key Pairs! 
    - If you don't, it will break terraform later. Terraform will put the key back.

### Use the Private key to generate a Public key
```bash
$ cd
$ mkdir .ssh
$ cd .ssh
# set the permissions on the key for it to be used by ssh utilities
$ chmod 500 web-site.pem
# generate a public key from the private key file
$ ssh-keygen -y -f web-site.pem > web-site-pub-key.pem
```

# Section 3 - Domain Name
The cost is pretty cheap for first year and renewal years, as listed, for some "tld's" (top level domains).
![](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/blob/master/images/Screen%20Shot%202018-12-14%20at%2012.59.41%20AM.jpg?raw=true)

## Pick Your Domain Name
You have a couple choices for domain names.  

1) Register and manage with GoDaddy or other registrar services. Or choose the cheapest one possible by searching "cheapest tld". 
  - Can save you a few dollars. If you search "setup godaddy point to aws" you will find instructions on how to use godaddy as your DNS instead of AWS.
  - You have to setup the nameserver (NS) records on the registrar site to point to Amazon. 
  - You can always transfer them to AWS in the future.

2) Registered and manager with AWS Route 53. 
  - Go to "Registered domains" and click "Register domain"
  - A little more cost but less management necessary.

## Create a Hosted Zone in Route 53
NOTE: The hosted zone in route 53 has a monthly charge of about 50 cents. If you choose, you can manage your DNS records outside of AWS as mentioned in the last section.

- Go to "Hosted Zones" and click "Create Hosted Zone"
- Enter your domain name and click Create!
- Create your Start of Authority (SOA) and NameServer (NS) records. The NS records will be entered under the domain as the name servers to look for the DNS records.

![](https://raw.githubusercontent.com/nealalan/EC2_Ubuntu_LEMP/master/nsrecords.png)
- Create your A type record for domain.com and www.domain.com

![](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/blob/master/images/Screen%20Shot%202018-12-13%20at%208.21.18%20PM.jpg?raw=true)
- If you have a mail service setup that will host your mail, you can setup the MX records as shown.

![](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/blob/master/images/Screen%20Shot%202018-12-13%20at%208.20.34%20PM.jpg?raw=true)

# Section 4 - Terraform Script
- You should have a Projects folder on your computer, preferable in a "home" folder. 
```bash
# IF NOT: 
$ cd
$ mkdir Projects
```

- If you're using a Mac, you could create it on your Desktop, in your Documents folder or in /home/neal/Projects/
- From the command line, you need to pull down the terraform script
```bash
$ cd Projects
# pull down the scripts
$ git clone https://github.com/nealalan/LAB-AWS_webserver_via_terraform.git
```

- You will see the progess of the download...
![](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/blob/master/images/Screen%20Shot%202018-12-13%20at%208.46.35%20PM.jpg?raw=true)

- You should have the files locally in Projects/LAB-AWS_webserver_via_terraform/
![](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/blob/master/images/Screen%20Shot%202018-12-13%20at%208.46.58%20PM.jpg?raw=true)

## Install Terraform
Go to the [Hashicorp Terraform](https://learn.hashicorp.com/terraform/getting-started/install) site.
```bash
# if on a Mac, try
$ brew install terraform
```

## Setup Credentials
Use the keys created in AWS IAM.
```bash
$ cd
$ mkdir .aws
$ cd .aws
$ atom credentials
```

In the credentials file you want to add an entry:
```bash
[terraform]
aws_access_key_id = A*******************
aws_secret_access_key = z9************************************
```
We will be referring to these in our variables in our terraform script.

## Create an Elastic IP address
- Go to VPC, Click Elastic IP, Click Allocate New Address and select Amazon Pool.
  - Make a note of the IP address. You will need it later.

- IMPORTANT: An elastic IP may incur an hourly charge ($0.003) if you take longer than an hour to submit the terraform script.   - Be prepared to manually delete the Elastic IP if you destroy your project or instance!!! 
  - You are manually creating this Elastic IP. Terraform WILL NOT manage or delete this for you!
  - It's a benefit to keep an Elastic IP so you don't have to go change your DNS records IP address anytime your instance is restarted.
- SIDE NOTE: It is possible for Terraform to manually create an Elastic IP address. 
  - I choose to manually create my own, becaus I'd have to manage my DNS records everytime terraform destroyed my Elastic IP.

## Customize the script
```bash
$ atom vpc.tf
```

1. Remove documentation that is irrelevant to the your site.
2. Change variables project_name. This is what your VPC will be named.
3. Set your pub_key_path. This is the file you created from the private key in the .ssh/ folder.
4. Set your creds_path and creds_profile. The creds fields are the AWS keys we saved.
5. Add the instance_assigned_elastic_ip as the Elastic IP address you created.
6. Find your local IP address as add_my_inbound_ip_cidr:
```bash
$ curl -4 ifconfig.co
```

7. (optional) Set your CIDR ranges. For this project we only need a couple of IP addresses, but you also want to learn CIDR addressing from a scalable perspective.
  - [VPC CIDR Address](https://github.com/nealalan/EC2_Ubuntu_LEMP/blob/master/README.md#vpc-cidr-address) and [Public Subnet](https://github.com/nealalan/EC2_Ubuntu_LEMP/blob/master/README.md#vpc-public-subnetwork-subnet)
  - You can probably leave the CIDR ranges as listed.
8. Change variables subnet_1_name and subnet_2_name.
9. Name your pub_key_name what you want it to be called in the AWS Keys library. Likely best to keep it whatever the file of the key is called, without the .pem extension.
10. The ami variable should be fine unless you want to install a different version of Ubuntu.

Regarding the rest of the script, as of now, you shouldn't have to edit any of it, at least not for the scope of this lab.

## Run the script!
1. TEST: This will show you potential errors and give you details of resources that will be created by terraform.
```bash
terraform plan
```

2. RUN the script for real! After the script complets, you can explore your new Infrascture on AWS under VPC and EC2.
```bash
$ terraform apply
```

3. CONNECT: 
```bash
$ ssh -i ~/.ssh/web-site.pem ubuntu@ip
```
- Since you are using your elastic IP, you can connect to it or you can replace IP with any domain name the DNS records list the IP address for. Think of it as a shortcut.
  
Note: If your IP changes, for example you're on a VPN, you will need to add your new IP address to the VPC ACL. I do this nearly everytime I go to a new coffee shop.

# Section 5 - NGINX and server configuration script

## Download 
You need to download the generic version of the script and then make the script executable.
```bash
$ curl https://raw.githubusercontent.com/nealalan/LAB-AWS_webserver_via_terraform/master/install.sh > install.sh
$ chmod +x ./install.sh
```

## Customize the script
```bash
$ nano install.sh
```

1. Remove documentation that is irrelevant to the your site.
2. Change all references of nealalan.com to your domain name.
3. Remove all reference to neonaluminum.com (or change it to another domain or subdomain or for whatever you have the Elastic IP assigned to a DNS record.)
4. On the "sudo certbot --authenticator" line, PLEASE change the email address to your email address.
5. Remove the "git clone" lines for nealalan.com and neonaluminum.com unless you want to clone your websites. If you do remove them you will simply need to create your own.

## Run the script!
This will take a few minutes, and if you edited everything correctly, you should be kicked out of the ssh connection.
```bash
$ ./install.sh
```

- After you reconnect using ssh, you should now be able to browse to your website in any browser.
- If you didn't load a page, you will not see a page.

# Section 6 - Your page
In the script, links were automatically made to the folders holding your website. So, for example, from my ~/ (home directory) I can just perform:
```bash
$ cd nealalan.com
$ nano -m index.html
```

- I can now directly edit my website.
- Note, if you haven't used nano before, you can use search how to. 
  - To summarize, you can use the arrow keys, type on lines and use Ctrl-X to exit

## My page
- Here's my page: 
  - My server is at static IP [18.223.13.99](http://18.223.13.99) 
  - serving [https://nealalan.com](https://nealalan.com) [https://www.nealalan.com](https://www.nealalan.com)
  - and [https://neonaluminum.com](https://neonaluminum.com) [https://www.neonaluminum.com](https://www.neonaluminum.com)
  - with redirects from all http:// addresses

![](https://raw.githubusercontent.com/nealalan/EC2_Ubuntu_LEMP/master/sites-as-https.png)

- Verify secure sites using: [Sophos Security Headers Scanner](https://securityheaders.com/) and [SSL Labs test
](https://www.ssllabs.com/ssltest).

# Section 7 - Undo, undo, undo
To get rid of everything: 
- A few simple commands from your local machine
```bash
$ terraform plan -destroy
$ terraform destroy
```

- Make sure all your [EC2 instances](https://us-east-2.console.aws.amazon.com/ec2/v2/home) are stopped or gone!
- Remove your [Elastic IPs](https://us-east-2.console.aws.amazon.com/ec2/v2/home?#Addresses:sort=PublicIp). 
- Ensure your [Route 53 hosted zones](https://console.aws.amazon.com/route53/home) are deleted.
- NOTE: Don't delete your account. You may want it again for another lab!

# TO-DO
- Add a terraform resource to add an alarm:
	- Threshold: StatusCheckFailed >= 1 for 2 datapoints within 30 minutes
	- Period: 15 minutes
	- Datapoints to alarm: 2 out of 2
	- Action: When in alarm, reboot the instance with id 

[[edit](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/edit/master/README.md)]
