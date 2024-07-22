pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'your-docker-registry'
        KUBE_NAMESPACE = 'your-kubernetes-namespace'
        KUBE_SERVER = 'your-kubernetes-server'
        KUBE_CREDENTIALS = 'your-kube-config-credentials' // Kubernetes credentials in Jenkins credentials store
    }

    stages {
        stage('Build') {
            steps {
                script {
                    // Clone the repository
                    checkout scm

                    // Determine which Dockerfile to use based on user input
                    def dockerfile = 'Dockerfile.nodejs' // Example, replace with actual logic

                    // Build Docker image
                    docker.build("${DOCKER_REGISTRY}/your-app:${env.BUILD_NUMBER}", "-f ${dockerfile} .")

                    // Push Docker image to registry
                    docker.withRegistry('https://${DOCKER_REGISTRY}', 'docker-credentials-id') {
                        docker.image("${DOCKER_REGISTRY}/your-app:${env.BUILD_NUMBER}").push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Load Kubernetes credentials
                    withCredentials([kubeconfig(credentialsId: "${KUBE_CREDENTIALS}", disableVersionCheck: true)]) {
                        // Apply Kubernetes deployment and service YAML files
                        sh "kubectl --kubeconfig=${KUBE_SERVER} apply -f kubernetes/deployment.yaml -n ${KUBE_NAMESPACE}"
                        sh "kubectl --kubeconfig=${KUBE_SERVER} apply -f kubernetes/service.yaml -n ${KUBE_NAMESPACE}"
                    }
                }
            }
        }
    }
}
