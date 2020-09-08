output "endpoint" {
  value = aws_eks_cluster.ekscluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.ekscluster.certificate_authority[0].data
}

output "loadbalancer" {
  value = kubernetes_service.kubeservice.load_balancer_ingress[0].hostname
}

output "db_name" {
  value = aws_db_instance.rdsinstance.name
}

output "db_endpoint" {
  value = aws_db_instance.rdsinstance.endpoint
}

resource "null_resource" "start-chrome"  {
	provisioner "local-exec" {
	    command = "start chrome ${kubernetes_service.kubeservice.load_balancer_ingress[0].hostname}"
  	}
	depends_on = [
		kubernetes_service.kubeservice,
		kubernetes_deployment.kube
	]
}