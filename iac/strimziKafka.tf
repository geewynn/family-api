resource "kubernetes_namespace" "kafka_namespace" {
  metadata {
    name = "kafka"
  }
  depends_on = [google_container_node_pool.primary]
}


resource "helm_release" "strimzi-kafka" {
  name  = "strimzi-kafka-operator"
  namespace = "kafka"
  repository = "https://strimzi.io/charts/"
  chart= "strimzi-kafka-operator"

  depends_on = [google_container_node_pool.primary, kubernetes_namespace.kafka_namespace]
}

data "kubectl_file_documents" "strimzi" {
  content = file("strimzi-yaml.yaml")
}


resource "kubectl_manifest" "strimzi_kafka" {
  count     = length(data.kubectl_file_documents.strimzi.documents)
  yaml_body = element(data.kubectl_file_documents.strimzi.documents, count.index)

  depends_on = [helm_release.strimzi-kafka]
}

resource "kubectl_manifest" "strimzi_topic" {
    yaml_body = <<YAML
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
 name: coterie
 namespace: kafka
 labels:
   strimzi.io/cluster: "strimzi-cluster-operator"
spec:
 partitions: 2
 replicas: 1
YAML
  depends_on = [
    kubectl_manifest.strimzi_kafka
  ]
}
