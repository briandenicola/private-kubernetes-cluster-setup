/*provider "helm" {
    kubernetes {
        host                  = azurerm_kubernetes_cluster.k8s.kube_config.0.host
        client_certificate    = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
        client_key            = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
        client_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_ca_certificate)
    }
}

resource "helm_release" "traefik_ingress" {
    name        = "traefik"
    repository  = "https://helm.traefik.io/traefik"
    chart       = "traefik/terfik"

    set {
        name    = "service.annotations"
        value   = "{service.beta.kubernetes.io/azure-load-balancer-internal: 'true'}"
    }

    set {
        name    = "ports.websecure.tls.enabled"
        value   = "true"
    }

        set {
        name    = "additionalArguments"
        value   = "{--serverstransport.insecureskipverify}"
    }
}
*/
