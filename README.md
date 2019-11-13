# AWS ToDo Application

## Build Docker Image 
In the repo, there is docker file which used to build the docker image install all prerequisite for the application and also install the nginx for reverse proxy to redirect the url on port 80. 

## Application CI/CD 
For CICD, I have used Azure DevOps for short time, but I can also use AWS code  pipeline and  for this purpose but that was quick way for me to do this. 
There is file called “Pipeline.yml” which build the docker image and push to the docker repo which later will use in kuberneter to comsume the latest image as latest application changes will be in that image. 

## Application Deployment on Kubernetes
In the repo there is folder called “Application_Deployment” which has deployment yml file which can use helm or kubeclt to do deployment on kubernets, we can also make this CI/CD, when new image comes it should redeploy again in kubernets.

## Application Infrastructure on AWS
In the repo there is folder called “AWS-Infra-Prevision” this has all the terraform file which used to prevision the infrastructure on AWS. 
