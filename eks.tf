resource "aws_iam_role" "demo" {
  name = "eks-cluster-demo"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo.name
}

resource "aws_iam_role_policy_attachment" "eks_acces_poc_all" {
  policy_arn = aws_iam_policy.eks_cluster_access_poc.arn
  role       = aws_iam_role.demo.name
}

resource "aws_eks_cluster" "demo" {
  name     = "demo"
  role_arn = aws_iam_role.demo.arn
  cluster_access = "API_AND_CONFIG_MAP"

  vpc_config {
    subnet_ids = [
      aws_subnet.private-us-east-1a.id,
      aws_subnet.public-us-east-1b.id,
      aws_subnet.public-us-east-1a.id,
      aws_subnet.private-us-east-1b.id,
    ]
    # Allow public access to the API server endpoint
    endpoint_public_access = true

    # Optionally, specify the CIDR block for public access
    public_access_cidrs = ["0.0.0.0/0"]
     
  }
  version = "1.29"
  depends_on = [aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy]
}

