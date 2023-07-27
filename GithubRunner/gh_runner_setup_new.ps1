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
--from-file=github_app_private_key=.\keys\k8s-actions-cloudbyte.2023-02-27.private-key.pem

# Install ARC
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm upgrade --install --namespace actions-runner-system --create-namespace `
             --wait actions-runner-controller actions-runner-controller/actions-runner-controller `
             --set syncPerdiod=1m

# Apply deployment to namespace
kubectl apply -f ./k8s/horizontal-runner-autoscaler.yaml

#! troubleshooting
# kubectl get pods -n actions-runner-system
# kubectl logs -f controller-manager-749f7bcd66-fs5dh  -c runner -n actions-runner-system

# TODO: review this
# https://github.com/actions/actions-runner-controller/tree/master/contrib/examples/terraform