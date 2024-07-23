#!/bin/bash

# Variables
KUBE_CONFIG="path/to/your/kubeconfig"  # Replace with actual path or use Jenkins/Kubernetes plugin for config
REGISTRY_URL="your-docker-registry.com"  # Replace with your Docker registry URL
BUILD_NUMBER="1"  # Example build number or use dynamically from Jenkins

# Build and push Docker images
docker build -t ${REGISTRY_URL}/nodejs-image:${BUILD_NUMBER} -f Dockerfile.nodejs .
docker push ${REGISTRY_URL}/nodejs-image:${BUILD_NUMBER}

docker build -t ${REGISTRY_URL}/python-image:${BUILD_NUMBER} -f Dockerfile.python .
docker push ${REGISTRY_URL}/python-image:${BUILD_NUMBER}

# Apply Kubernetes configurations
kubectl apply -f kubernetes/deployment.yaml --kubeconfig=${KUBE_CONFIG}
kubectl apply -f kubernetes/service.yaml --kubeconfig=${KUBE_CONFIG}

# Configure Horizontal Pod Autoscaler (HPA)
kubectl apply -f kubernetes/hpa.yaml --kubeconfig=${KUBE_CONFIG}

# Additional Kubernetes configurations if needed
# kubectl apply -f kubernetes/other-configs.yaml --kubeconfig=${KUBE_CONFIG}

# Clean up old Docker images if needed
# docker image rm ${REGISTRY_URL}/nodejs-image:${BUILD_NUMBER}
# docker image rm ${REGISTRY_URL}/python-image:${BUILD_NUMBER}

echo "Deployment completed successfully!"
