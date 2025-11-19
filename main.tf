##conexao helm com cluster
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}


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
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
YAML
}

#criar gateway
resource "kubectl_manifest" "envoy_gateway" {
  yaml_body = <<YAML
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: envoy-gateway
  namespace: envoy-gateway-system
  annotations:
    #service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    #service.beta.kubernetes.io/azure-load-balancer-ipv4: "10.10.1.50"
    #service.beta.kubernetes.io/azure-load-balancer-subnet: "subnet-k8s-lb"
spec:
  gatewayClassName: envoy-gateway-class
  listeners:
    - name: http
      protocol: HTTP
      port: 80
YAML
}