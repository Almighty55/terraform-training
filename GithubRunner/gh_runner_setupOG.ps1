aws eks --region us-east-1 update-kubeconfig --name demo

kubectl get svc

helm repo add jetstack https://charts.jetstack.io

helm repo update

helm search repo cert-manager

helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.6.0 --set prometheus.enabled=false --set installCRDs=true

kubectl create ns actions


kubectl create secret generic controller-manager -n actions --from-literal=github_app_id=298877 --from-literal=github_app_installation_id=34679976 --from-file=github_app_private_key=..\keys\k8s-actions-cloudbyte.2023-02-27.private-key.pem


helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm repo update
helm search repo actions



helm install actions actions-runner-controller/actions-runner-controller --namespace actions --version 0.22.0 --set syncPeriod=1m


kubectl apply -f ../k8s/runner-deployment.yaml