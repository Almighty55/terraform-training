aws eks --region us-east-1 update-kubeconfig --name github_actions
# kubectl get svc
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.12.0 --set prometheus.enabled=false --set installCRDs=true

# Create namespace
kubectl create ns actions-runner-system

# Authenticating to the GitHub API
#TODO: Change for 21packets github APP
kubectl create secret generic controller-manager -n actions-runner-system `
--from-literal=github_app_id=298877 `
--from-literal=github_app_installation_id=34679976 `
--from-file=github_app_private_key=..\keys\k8s-actions-cloudbyte.2023-02-27.private-key.pem

# Install ARC
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm repo update
helm upgrade --install --namespace actions-runner-system `
    --version 0.23.3 `
    --wait actions-runner-controller actions-runner-controller/actions-runner-controller `
    --set syncPeriod=1m


# Apply deployment to namespace #* levels up two directories because terraform executes it
kubectl apply -f ../k8s/horizontal-runner-autoscaler.yaml

#! troubleshooting
# kubectl get pods -n actions-runner-system
# kubectl logs -f controller-manager-749f7bcd66-fs5dh  -c runner -n actions-runner-system

#! RESET k8
# kubectl delete configmap --all -n default
# kubectl delete secret --all -n default
# kubectl delete pvc --all -n default
# kubectl delete pv --all

# kubectl get ns -o json | ConvertFrom-Json | ForEach-Object { $_.items |
#     Where-Object { $_.metadata.name -notin @('kube-system', 'kube-public', 'kube-node-lease', 'default') } |
#     ForEach-Object { kubectl delete ns $_.metadata.name } }




# TODO: review this
# https://github.com/actions/actions-runner-controller/tree/master/contrib/examples/terraform