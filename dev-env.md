terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
}

provider "kubernetes" {
  # Configuration options
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace_v1" "dev_env" {
  metadata {
    name = "dev-env"
  }
}
resource "kubernetes_deployment_v1" "hiscross_api" {
  metadata {
    name      = "hiscross-api"
    namespace = kubernetes_namespace_v1.dev_env.metadata.0.name
  }
  spec {
    replicas = "3"
    selector {
      match_labels = {
        app = "hiscross-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "hiscross-app"
        }
      }
      spec {
        container {
          name              = "tomcat-container"
          image             = "tomcat:latest"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 6060
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "loadbalancer_service"  {
  metadata {
    name = "${kubernetes_deployment_v1.hiscross_api.metadata[0].name}-svc"
    namespace = kubernetes_namespace_v1.dev_env.metadata[0].name
  }
  spec {
    type = "LoadBalancer"
    selector  = {
      app = kubernetes_deployment_v1.hiscross_api.spec[0].selector[0].match_labels.app
    }
    port {
      target_port = kubernetes_deployment_v1.hiscross_api.spec[0].template[0].spec[0].container[0].port[0].container_port
      port = 9000
    }
  }
}