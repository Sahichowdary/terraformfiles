variable "region" {
    description = "used to specify the region"
    default = "us-east-1"
}

variable "availability_zone" {
    default = "us-east-1a"
}

variable "availability_zone2" {
    default = "us-east-1b"
}

variable "availability_zone3" {
    default = "us-east-1c"
}

variable "eks_cluster_role" {
    default = "arn:aws:iam::036965198866:role/pocEKSClusterRole"
}

variable "eks_node_role" {
    default = "arn:aws:iam::036965198866:role/pocAmazonEKSNodeRole"
}

variable "eks_encryption_key" {
    default = "arn:aws:kms:us-east-1:036965198866:key/48e8799d-ee0c-4462-a8da-28ae9073ab40"
}

variable "domain-name" {
    default = "saskenpoc.com"
}

variable "loadbalancer_id" {
    default = " "  
}


variable "cloudfront_distribution_arn" {
    default = "arn:aws:cloudfront::036965198866:distribution/E1W8110DKYMBQ1"
}

variable "waf_web_acl_arn" {
    default = "arn:aws:wafv2:us-east-1:036965198866:global/webacl/pocwebacl/6f67ead5-4324-4d9e-a09a-4bf27c803630"
}

variable "lb_name" {
    default = "a81875955f9c747dea66d3466423ec51"
}

variable "lb_name2" {
    default = "afd9d8463920f4813a9ece075be506e5"
}


variable "rds" {
  type = object({
    name = string
    name2 = string
    storage = number
    engine_version = string
    username = string
    password = string
    public_access = bool
  })
}
