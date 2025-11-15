
#provider "kubernetes" {#

#  config_path    = "~/.kube/config"
#  host           = "https://172.16.24.128:8443"
#  config_context = "minikube"
#}

##conexao helm com cluster
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

#conectando no cluster
#provider "kubernetes" {
#  config_path    = "~/.kube/config"
#  config_context = "minikube"
#}

#providers
terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

#Install do kyverno com helm
resource "helm_release" "envoy" {
  name             = "envoy"
  repository       = "oci://docker.io/envoyproxy"
  chart            = "gateway-helm"
  version          = "v1.6.0"
  namespace        = "envoy-gateway-system"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true
  values = [file("${path.module}/values-settings.yaml")]
}

#criar gateway-class
resource "kubectl_manifest" "envoy_gateway_class" {
  yaml_body = <<YAML
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: envoy-gateway-class
spec:
  controllerName: gateway.envoyproxy.io/controller
YAML
}