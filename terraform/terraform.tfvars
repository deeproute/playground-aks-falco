location = "westeurope"
resource_group_name = "playground-aks-falco" # if running with bootstrap.sh, don't forget to change there too.
cluster_name = "aks-falco" # if running with bootstrap.sh, don't forget to change there too.
private_cluster_enabled = false
kubernetes_version = "1.21.9"
node_count = 1
vm_size = "Standard_D4as_v5"  #"Standard_B2ms"
