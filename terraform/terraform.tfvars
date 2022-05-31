location = "westeurope"
resource_group_name = "playground-aks-akv-csi" # if running with bootstrap.sh, don't change here and change there.
cluster_name = "aks-akv-csi" # if running with bootstrap.sh, don't change here and change there.
private_cluster_enabled = false
kubernetes_version = "1.21.9"
node_count = 1
vm_size = "Standard_D4as_v5"  #"Standard_B2ms"
