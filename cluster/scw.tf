resource "scaleway_k8s_cluster" "scw-cluster" {
  name    = "scw-cluster"
  version = "1.22.2"
  cni     = "cilium"
  tags    = ["cluster-1", "meetup"]
}

resource "scaleway_k8s_pool" "scw-cluster-pool-1" {
  cluster_id = scaleway_k8s_cluster.scw-cluster.id
  name       = "scw-cluster-pool-1"
  node_type  = "DEV1-M"
  size       = 1
}

resource "local_file" "scw-kubeconfig" {
  content  = scaleway_k8s_cluster.scw-cluster.kubeconfig[0].config_file
  filename = "scw.yaml"
}