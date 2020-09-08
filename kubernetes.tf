resource "kubernetes_service" "kubeservice" {
  metadata {
    name = "nextcloud"
    labels = {
      app = "nextcloud"
    }
  }
  spec {
    selector = {
      app = "nextcloud"
      tier= "frontend"
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
    name = "nextcloud-pv-claim"
    labels = {
      app = "nextcloud"
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
    name = "nextcloud"
    labels = {
      app = "nextcloud"
    }
  }
  

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nextcloud"
        tier= "frontend"
      }
    }
    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = "nextcloud"
          tier= "frontend"
        }
      }

      spec {
        container {
          image = "nextcloud:latest"
          name  = "nextcloud"
          env {
            name = "MYSQL_DATABASE"
            value= aws_db_instance.rdsinstance.name     
          }
          env {
            name = "MYSQL_HOST"
            value= aws_db_instance.rdsinstance.endpoint   
          }
          env {
            name = "MYSQL_USER"
            value= aws_db_instance.rdsinstance.username   
          }
          env {
            name = "MYSQL_PASSWORD"
            value= aws_db_instance.rdsinstance.password     
          }
          port {
            container_port = 80
            name = "nextcloud"
          }

          volume_mount {
            name = "nextcloud-ps"
            mount_path = "/var/www/html"
          }        
        }
        volume {
          name = "nextcloud-ps"
          persistent_volume_claim {
            claim_name = "nextcloud-pv-claim"
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