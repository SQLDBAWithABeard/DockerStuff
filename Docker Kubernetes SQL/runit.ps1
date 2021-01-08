	cd '\Kubernetes Docker SQL'
kubectl get nodes
kubectl get pods

kubectl create -f .\sqlserver.yaml
kubectl get pods

kubectl get services

<#
# Remove it

kubectl delete deployment sqlserver
kubectl delete service sqlserver-service

#>
