# <p style="text-align: center;"> Tuyul </p>
## Introduction
Tuyul is a fast, simple and lightweight URL Shortener service. You can run it as an executable or as a Docker container.

> **Did you know?** 
> 
> The word `Tuyul` came from a mythical creature from Indonesian folklore. Known for their small size, they will do their master's bidding to steal goods from the community (relax, this app won't steal anything. I promise :) )

## Requirements
- Go 1.20+
- Redis
- Docker
- Terraform (to provision the infrastructure)
- AWS ECS
- make
- Cloudflare DNS zone
## Background
The app is built on Go. The reason is because, first, it's fun :) Second, It's always nice that you can build a fully functioning HTTP server without having to import a lot of 3rd party modules. The app will generate a random short uri between 6-10 characters which will be stored in the database. The app uses environment variables as its configuration. It has 2 endpoints, the url-shortener endpoint(/minime) and the healthcheck endpoint(/health). The app will generate between 6-10 random characters consisting lower-case letters, upper-case letters, and numbers.

As for the database, I chose Redis. Redis is incredibly fast because of it's nature as an in-memory key-value store. I'm well aware that the downside of this is if it's down, then data will be gone. But, we can mitigate this issue by having replicas, preferably a multi-zone replicas setup. Also for the fact that at least for now, I'm not planning to store the data for a long period(talking about TTL 30 days max). To use a relational DBMS is overkill for this app. With Redis, it will keep the app to be platform agnostic rather than locked with 1 specific cloud provider.


All of those are deployed on AWS. Specifically, Amazon ECS for the app and Amazon MemoryDB for the Redis. Fargate is used as the capacity provider for the ECS. That way, the cost would be more efficient. The reason behind ECS & Fargate is that this app does not really have a fancy requirement to spin it up. To use EKS would be overkill and it would introduce a maintenance overhead. Moving on to MemoryDB Redis, it's a Redis Cluster by default and it also create snapshots.So, with that in mind, MemoryDB already provides a high-available Redis solution. The traffic from the internet is handled by Amazon ALB. SSL certificate is provided by Let'sEncrypt and stored in Amazon Certificate Manager. This app also implements Autoscaling group based on CPU & memory consumption. Domain is handled by Cloudflare and ontainer registry is on Docker Hub because they are free and easily accessible:)

## The fun stuff
In this section we will try deploy this project and all of the dependencies for `develop` environment on AWS.
### Preparation
>IMPORTANT !!!
>
>Build-push the image & deploy the infrastructure first before start deploying the app
#### Build Docker Image & Push to Docker Hub
1. export these environment variables
```bash
export APP_NAME=tuyul
export ENVIRONMENT=develop
```
2. start build the container image
```bash
make docker
```
3. tag the recently created image
```bash
docker tag tuyul:latest somerepo/tuyul:latest
```
4. push the image
```bash
docker push somerepo/tuyul:latest
```
#### Deploy the Infrastructure
1. Open  `.infra/terraform/tuyul-infra/environments/develop/config.s3.backend` and change this values
```bash
bucket = "some-tf-state" # Bucket name for storing Terraform state
key    = "develop/infra/core/state" # Object name for the Terraform state inside the bucket
region = "eu-central-1" # AWS region where the bucket resides
```
1. export these environment variables
```bash
export APP_NAME=tuyul
export ENVIRONMENT=develop
```
1. Run some validation test and plan
```bash
make tfplan-infra
```
1. If there is no error, deploy the infrastructure
```bash
make tfapply-infra
```
### Deploy the App
Once the infrastructure's deployment is done, we can start to deploy the app.

1. Retrieve Cloudflare's `api_token` & `account_id` and store it in `AWS Secret Manager` with JSON format.
```json
{
    "api_token": "asuidh23iu209hefk",
    "account_id": "asd2424jfj204"
}
```
1. Create a secret in `AWS Secret Manager` to store `Docker Hub`'s credentials with JSON format
```json
{
    "username": "yourdockerhub",
    "password": "yourNo7$0s7roN9P4sSWorD"
}
```
1. Remember the step to modify infrastructure's Terraform backend in `.infra/terraform/tuyul-infra/environments/develop/config.s3.backend` ? Create a secret in `AWS Secret Manager` to store the information of that backend with this JSON format. Don't forget to name it specifically for each environment.
```json
{
    "bucket": "some-tf-state",
    "key": "develop/infra/core/state",
    "region": "eu-central-1" 
}
```
1. Open `.infra/terraform/tuyul-app/environments/develop/terraform.tfvars` and start putting on some values to some variables
```bash
app_name = "tuyul" ## DON'T CHANGE THIS
env      = "develop" ## DON'T CHANGE THIS
owner    = "platform" ## DON'T CHANGE THIS

infra_state_secret_name = "dev/tf/sample-infra" ## Put the secret name of the infrastructure's TF backend

dockerhub_secret_name = "some/secret/dockerhub-creds" ## Put your Docker Hub's secret name here
container_registry    = "yourdockerhub"
container_port        = 3000

cf_secret_name     = "some-secret-cloudflare-creds" ## Put your Cloudflare's secret name here
acme_email_address = "your@email.com"
```
4. Open  `.infra/terraform/tuyul-app/environments/develop/config.s3.backend` and change this values
```bash
bucket = "some-tf-state" # Bucket name for storing Terraform state
key    = "develop/app/tuyul/state" # Object name for the Terraform state inside the bucket
region = "eu-central-1" # AWS region where the bucket resides
```
5. export these environment variables
```bash
export APP_NAME=tuyul
export ENVIRONMENT=develop
```
6. Run some check to see if there are any errors
```bash
make tfplan-app
```
7. If there is no error, run the deployment
```bash
make tfapply-app
```
## Tech Spec

### Endpoints
`GET` `/minime`

The shortener endpoint

**Query Params**

>`uri`  = the full URL as the target redirection

**Response**
```json
{
    "short_url": string,
    "target": string
}
```

`GET` `/health`

Health check endpoint

**Query Params**

> \-

**Response**
```json
{
    "status": string, // HTTP status code
    "message": string
}
```