provider "aws" {
  region = "eu-north-1"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  
  set {
    name  = "server.persistentVolume.enabled"
    value = "true"
  }
  
  set {
    name  = "server.persistentVolume.size"
    value = "8Gi"
  }
  
  set {
    name  = "alertmanager.persistentVolume.enabled"
    value = "true"
  }
  
  set {
    name  = "alertmanager.persistentVolume.size"
    value = "2Gi"
  }
  
  set {
    name  = "server.retention"
    value = "7d"
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  
  set {
    name  = "persistence.enabled"
    value = "true"
  }
  
  set {
    name  = "persistence.size"
    value = "5Gi"
  }
  
  set {
    name  = "adminPassword"
    value = "admin"  # Change this in production
  }
  
  set {
    name  = "datasources.datasources\\.yaml.apiVersion"
    value = "1"
  }
  
  set {
    name  = "datasources.datasources\\.yaml.datasources[0].name"
    value = "Prometheus"
  }
  
  set {
    name  = "datasources.datasources\\.yaml.datasources[0].type"
    value = "prometheus"
  }
  
  set {
    name  = "datasources.datasources\\.yaml.datasources[0].url"
    value = "http://prometheus-server.monitoring.svc.cluster.local"
  }
  
  set {
    name  = "datasources.datasources\\.yaml.datasources[0].access"
    value = "proxy"
  }
  
  set {
    name  = "datasources.datasources\\.yaml.datasources[0].isDefault"
    value = "true"
  }
  
  values = [
    file("${path.module}/grafana-dashboards.yaml")
  ]
}

resource "helm_release" "node_exporter" {
  name       = "node-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-node-exporter"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
}

resource "helm_release" "kube_state_metrics" {
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
}

resource "helm_release" "aws_cloudwatch_exporter" {
  name       = "cloudwatch-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-cloudwatch-exporter"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  
  set {
    name  = "aws.region"
    value = "eu-north-1"
  }
  
  set {
    name  = "config"
    value = file("${path.module}/cloudwatch-exporter-config.yml")
  }
}

resource "kubernetes_secret" "alertmanager_config" {
  metadata {
    name      = "alertmanager-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "alertmanager.yml" = file("${path.module}/alertmanager.yml")
  }
}
