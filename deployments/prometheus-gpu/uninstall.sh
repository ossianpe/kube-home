helm del --purge prometheus-operator
helm del --purge kube-prometheus

kubectl delete service alertmanager-operated -n monitoring
kubectl delete service prometheus-operated -n monitoring
