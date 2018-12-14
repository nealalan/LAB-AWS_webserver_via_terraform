# [nealalan.github.io](https://nealalan.github.io)/[LAB-AWS_webserver_via_terraform](https://nealalan.github.io/LAB-AWS_webserver_via_terraform)

# Project Goal
- Stay security minded by restricting network access and creating a secure web server. 
- Create a secure web server within the free tier of AWS.
- Fully automate the creation of a Virtual Private Cloud and all necessary components.
- Automate, as much as possible, the installation and configuration of an NGINX webserver.
- Pull the website source data from github.
- Note: Installing a quality file editor such as [Atom](https://atom.io/) is highly recommended!

# Section 1 - AWS Setup.
![](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/blob/master/images/AWSfreetier.png?raw=true)
- If you have a .edu email address you can sign up for an educational account, which will not require a credit card.
- You will have to enter a credit card, but will still be given "free tier" credit. 
- Create an AWS root account.

## Billing
- It's important to watch your use! Be prepared to be charged a few dollars if you don't pay attention to the terms. But you can avoid charges by reading pricing documentation before you do things.
  - If you run more than 750 hours of EC2 instances in a month (there are 744 in a month) you can be charged. 
  - If you use more than 30 GB of space, irrelevant of the instance running, you will be charged. 
  - If you have an Elastic IP that isn't assigned to an active instance or gateway, you will be charged per hour.
  - If you register a domain name and use the DNS service within AWS, you will be charged. You can use another provider for cheaper.
- Pay attention to [BILLING](https://console.aws.amazon.com/billing/home?region=no-region#/bills) and [cost explorer](https://console.aws.amazon.com/billing/home?region=no-region#/). 
- If you do see a few charges, don't panic. Once you remove it, the charges should stop and may go away. 

# Section 2 - AWS Security
- First, you need a password manager! 
  - If you're not using a password manager, you might not be ready for cloud technology. 
  - You will have a number of keys and passwords to keep track of. 
  - Here's a good article... [Consumer Reports: Everything You Need to Know About Password Managers](https://www.consumerreports.org/digital-security/everything-you-need-to-know-about-password-managers/)

## Identity and Access Management (IAM) & Account Security
- When you have any account, you will be shown a number of pieces of data. 
- Store these in your password manager! The data is for your root account. 
- It is recommended you setup MFA (Multi-factor Authentication) for your root account.
	- AWS Console address: https://<account-id-number>.signin.aws.amazon.com/console
	- Username & Password
	- Account ID
	- Access Key ID
	- Secret Access Key
- The [IAM Dashboard](https://console.aws.amazon.com/iam) will give you security status recomendations.
![](https://raw.githubusercontent.com/nealalan/EC2_Ubuntu_LEMP/master/iam.png)
- Use IAM to create a new Administrator user. This will actually be what you use. 
  - It's a best practice not to log in with your root account.
  - I use my actual email address as my root and the first part (login) of my email as my main account. 
- Use IAM to create a new terraform user. This is what the script will use.
  - Select programatic access. 
  ![](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/blob/master/images/Screen%20Shot%202018-12-13%20at%207.29.42%20PM.jpg?raw=true)
  - Attach existing policies:
    - AmazonVPCFullAccess
    - AmazonEC2FullAccess 
  - Grab your key and secret_key now. Save them in your Password Manager!
  ![](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/blob/master/images/Screen%20Shot%202018-12-13%20at%207.45.39%20PM.jpg?raw=true)


# Section 3 - Domain Name

## Prereqs

  - Registering your domain name and creating a Hosted Zone in Route 53
  - [VPC CIDR Address](https://github.com/nealalan/EC2_Ubuntu_LEMP/blob/master/README.md#vpc-cidr-address) and [Public Subnet](https://github.com/nealalan/EC2_Ubuntu_LEMP/blob/master/README.md#vpc-public-subnetwork-subnet)
  - [EC2: Network & Security: Key Pairs](https://github.com/nealalan/EC2_Ubuntu_LEMP/blob/master/README.md#ec2-network--security-key-pairs)
  - The first step in [Connect to your instance](https://github.com/nealalan/EC2_Ubuntu_LEMP/blob/master/README.md#connect-to-your-instance) - except here you can connect to ubuntu@domain.com or ubuntu@EIP
- An AWS account with the IAM keys created for use in terraform
- Install [terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) or search your package manager
  - Configure terraform with IAM keys


# Terraform Script
## Files
This repo contains two files:
- [vpc.tf](https://github.com/nealalan/tf-201812-nealalan.com/blob/master/vpc.tf) - a consolidated terraform file (infrastructure as code) to create a VPC, associated components and an EC2 Ubuntu instance in a Public Subnet
  - best practice is to separate out the terraform components into sections, but this worked out well for me to have it in one file
  - need to implement the logic to automatically push (scp?) the install.sh file to the EC2 instance and run it automatically
- [install.sh](https://github.com/nealalan/tf-201812-nealalan.com/blob/master/install.sh) - shell script to configure the Ubuntu instance to configure NGINX web server with secure websites (https)
  - website are automatically pulled from git repos for respective sites

## Steps / Commands
I used... 
1. git clone this repo
2. terraform init
3. terraform plan
4. terraform apply
5. ssh -i priv_key.pem ubuntu@ip
6. curl https://raw.githubusercontent.com/nealalan/tf-201812-nealalan.com/master/install.sh > install.sh
7. chmod +x ./install.sh
8. .install.sh

Optional:
- terraform plan -destroy
- terraform destroy


## Result
My server is at static IP [18.223.13.99](http://18.223.13.99) serving [https://nealalan.com](https://nealalan.com) and [https://neonaluminum.com](https://neonaluminum.com) with redirects from all http:// addresses

![](https://raw.githubusercontent.com/nealalan/EC2_Ubuntu_LEMP/master/sites-as-https.png)


- Verify secure sites: [Sophos Security Headers Scanner](https://securityheaders.com/) and [SSL Labs test
](https://www.ssllabs.com/ssltest).


## NEXT STEPS
As you move around you'll need to log in to the AWS Console and add your local IP address to the EC2: Network ACLs. Here's an example of one I had in the past...
![](https://raw.githubusercontent.com/nealalan/EC2_Ubuntu_LEMP/master/ACLsshlist.png)
Also, I now have the flexibility to totally recreate the websever through a few small script changes if I make major site changes, add a new domain name or need to upgrade to the latest LTS of Ubuntu.

## Installing MariaDQ 
And setting it to have a Root PW...
```bash
$ sudo apt install mariadb-client
$ sudo apt install mariadb-server
$ sudo passwd root (NealAlanDreher12)
$ sudo mysql -u root
# Disable plugin authentication for root
> use mysql;
> update user set plugin='' where User='root';
> flush privileges;
> exit
$ sudo systemctl restart mariadb.service
$ sudo mysql_secure_installation
# verity root auth works
$ sudo mysql -u root
$ sudo mysql -u root -p
```

## Fixing Errors
Within a few days I messed up my Ubuntu instance. The solution was clearly going to take longer than 15 minutes. So here's what I did, thanks to terraform:
1. Grab what is managed by terraform
![](https://github.com/nealalan/tf-201812-nealalan.com/blob/master/images/Screen%20Shot%202018-12-10%20at%209.19.52%20PM.jpg?raw=true)
2. Mark the Ubuntu instance as tainted for destruction
```bash
terraform taint aws_instance.wb
```
3. Verify what will happen (a side effect was my ACLs and SGs will be cleaned up since I was running an outdated lab that requried me to open some ports)
```bash
$ terraform plan
```
![](https://github.com/nealalan/tf-201812-nealalan.com/blob/master/images/Screen%20Shot%202018-12-10%20at%209.17.39%20PM.jpg?raw=true)
4. Run!
```bash
$ terraform apply
```
5. Setup Ubuntu to host my webserver again
```bash
$ curl https://raw.githubusercontent.com/nealalan/tf-201812-nealalan.com/master/install.sh > install.sh
$ chmod +x ./install.sh
$ .install.sh
```
6. Consider using virtuanenv or even running another EC2 instance when I want to plan with some labs?!?!?! I can alwauys assign a subdomain to a lab instance.

[[edit](https://github.com/nealalan/LAB-AWS_webserver_via_terraform/edit/master/README.md)]
