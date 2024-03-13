data "aws_iam_policy_document" "test_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-test"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "test_oidc" {
  assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy.json
  name               = "test-oidc"
}

resource "aws_iam_policy" "test-policy" {
  name = "test-policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.test_oidc.name
  policy_arn = aws_iam_policy.test-policy.arn
}

output "test_policy_arn" {
  value = aws_iam_role.test_oidc.arn
}


resource "aws_iam_policy" "eks_cluster_access_poc" {
  name        = "eks-cluster-access-policy_poc"
  description = "IAM policy for accessing the EKS cluster"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "eks:*",
          "ec2:Describe*",
          "ec2:List*",
          "ec2:Get*",
          // Add additional permissions as needed
        ],
        Resource = "*",
      },
    ],
  })
}





# IAM OIDC Identity Provider
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  depends_on = [aws_eks_cluster.demo]
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = aws_eks_cluster.demo.identity[0].oidc[0].issuer
  url             = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

# IAM Role for RBAC Role Mapping
resource "aws_iam_role" "eks_rbac_role" {
  name               = "eks-rbac-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks_oidc_provider.arn
      }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${aws_iam_openid_connect_provider.eks_oidc_provider.url}:sub" = "system:serviceaccount:kube-system:aws-node"
        }
      }
    }]
  })
}

# IAM Role Policy for RBAC Role Mapping
resource "aws_iam_role_policy_attachment" "eks_rbac_policy_attachment" {
  role       = aws_iam_role.eks_rbac_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Kubernetes RBAC Role Binding
resource "kubernetes_role_binding" "aws_node_role_binding" {
  metadata {
    name      = "aws-node-role-binding"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:node"
  }

  subject {
    kind      = "User"
    name      = aws_iam_openid_connect_provider.eks_oidc_provider.url
    api_group = "rbac.authorization.k8s.io"
  }
}

# Output IAM OIDC Identity Provider ARN
output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc_provider.arn
}


resource "aws_iam_policy_attachment" "eks_cluster_access_attachment" {
  name       = "eks-cluster-access-attachment"
  users      = ["syedmd", "alokp"]  # Replace <USER_NAME> with the individual user's IAM username
  policy_arn = aws_iam_policy.eks_cluster_access_poc.arn
}
