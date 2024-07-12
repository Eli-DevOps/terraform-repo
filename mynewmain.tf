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

# Resource: Kubernetes Namespace for Dev Environment
resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
}

# Resource: Kubernetes Namespace for Staging Environment
resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
}

# Resource: Kubernetes Deployment for Dev Environment
resource "kubernetes_deployment" "dev_app" {
  metadata {
    name      = "dev-app"
    namespace = kubernetes_namespace.dev.metadata.0.name
    labels = {
      environment = "dev"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "myapp"
        environment = "dev"
      }
    }

    template {
      metadata {
        labels = {
          app = "myapp"
          environment = "dev"
        }
      }

      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Resource: Kubernetes Deployment for Staging Environment
resource "kubernetes_deployment" "staging_app" {
  metadata {
    name      = "staging-app"
    namespace = kubernetes_namespace.staging.metadata.0.name
    labels = {
      environment = "staging"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "myapp"
        environment = "staging"
      }
    }

    template {
      metadata {
        labels = {
          app = "myapp"
          environment = "staging"
        }
      }

      spec {
        container {
          image = "nginx:alpine"
          name  = "nginx"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}