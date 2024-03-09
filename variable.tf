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

