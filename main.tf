provider "aws" {
  region                  = "ap-south-1"
  shared_credentials_file = "C:/Users/HP/.aws/credentials"
  profile                 = "default"
}

data "aws_eks_cluster_auth" "eksauth" {
  name = aws_eks_cluster.ekscluster.name
}


provider "kubernetes" {
  host                   = aws_eks_cluster.ekscluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.ekscluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eksauth.token
  load_config_file       = false
}