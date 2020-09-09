resource "kubernetes_service" "kubeservice" {
  metadata {
    name = "wordpress"
    labels = {
      "app" = "wordpress"
    }
  }
  spec {
    selector = {
      "app" = "wordpress"
      "tier"= "frontend"
    }
    port {
      port        = 80
      node_port = 30001
    }

    type = "LoadBalancer"
  }
  depends_on = [aws_eks_node_group.eks-ng]
  timeouts {
    create = "15m"
  }
}


resource "kubernetes_persistent_volume_claim" "kubepvc" {
  metadata {
    name = "wordpress-pv-claim"
    labels = {
      "app" = "wordpress"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
  depends_on = [aws_eks_node_group.eks-ng]
  timeouts {
    create = "15m"
  }
}

resource "kubernetes_deployment" "kube" {
  metadata {
    name = "wordpress"
    labels = {
      "app" = "wordpress"
    }
  }
  
  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "wordpress"
        "tier"= "frontend"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          "app" = "wordpress"
          "tier"= "frontend"
        }
      }

      spec {
        container {
          image = "wordpress"
          name  = "wordpress"
          env {
            name = "WORDPRESS_DB_NAME"
            value= aws_db_instance.rdsinstance.name     
          }
          env {
            name = "WORDPRESS_DB_HOST"
            value= aws_db_instance.rdsinstance.endpoint   
          }
          env {
            name = "WORDPRESS_DB_USER"
            value= aws_db_instance.rdsinstance.username   
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value= aws_db_instance.rdsinstance.password     
          }
          port {
            container_port = 80
            name = "wordpress"
          }

          volume_mount {
            name = "wordpress-ps"
            mount_path = "/var/www/html"
          }        
        }
        volume {
          name = "wordpress-ps"
          persistent_volume_claim {
            claim_name = "wordpress-pv-claim"
          }
        }
      }
    }
  }
  depends_on = [aws_eks_node_group.eks-ng]
  timeouts {
    create = "30m"
  }
}