pipeline {
    agent any

    environment {
        REGISTRY_URL = 'https://hub.docker.com/repository/docker/khana88/swish-final-project/general'  // Replace with your Docker registry URL
        KUBE_CONFIG = credentials('kubeconfig')  // Jenkins credentials for Kubernetes config
    }

    stages {
        stage('Build and Push Docker Images') {
            steps {
                script {
                    // Build and push Node.js image
                    docker.build("nodejs-image:${BUILD_NUMBER}", "-f Dockerfile.nodejs .")
                    docker.withRegistry(REGISTRY_URL, 'docker-credentials-id') {
                        docker.image("nodejs-image:${BUILD_NUMBER}").push()
                    }

                    // Build and push Python image
                    docker.build("python-image:${BUILD_NUMBER}", "-f Dockerfile.python .")
                    docker.withRegistry(REGISTRY_URL, 'docker-credentials-id') {
                        docker.image("python-image:${BUILD_NUMBER}").push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Deploy Node.js application
                    sh "kubectl apply -f kubernetes/deployment.yaml --kubeconfig=${KUBE_CONFIG}"
                    sh "kubectl apply -f kubernetes/service.yaml --kubeconfig=${KUBE_CONFIG}"
                    // Apply node affinity, taints, or other configurations as needed
                    sh "kubectl apply -f kubernetes/node-affinity.yaml --kubeconfig=${KUBE_CONFIG}"
                    sh "kubectl apply -f kubernetes/node-taints.yaml --kubeconfig=${KUBE_CONFIG}"
                }
            }
        }

        stage('Setup Monitoring') {
            steps {
                script {
                    // Install Prometheus using Helm
                    sh "helm repo add prometheus-community https://prometheus-community.github.io/helm-charts"
                    sh "helm repo update"
                    sh "helm install prometheus prometheus-community/kube-prometheus-stack --kubeconfig=${KUBE_CONFIG}"

                    // Apply Prometheus configuration
                    sh "kubectl apply -f kubernetes/prometheus.yaml --kubeconfig=${KUBE_CONFIG}"
                }
            }
        }

        stage('Configure Autoscaling') {
            steps {
                script {
                    // Configure Horizontal Pod Autoscaler (HPA)
                    sh "kubectl apply -f kubernetes/hpa.yaml --kubeconfig=${KUBE_CONFIG}"
                }
            }
        }

        stage('Deploy UI Changes') {
            steps {
                // Example: Copy UI files to web server directory (if needed)
                sh "cp -r ui/* /var/www/html"
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    // Clean up old Docker images or other resources if necessary
                    docker.image("nodejs-image:${BUILD_NUMBER}").remove()
                    docker.image("python-image:${BUILD_NUMBER}").remove()
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
            // Optionally, trigger notifications or further actions upon successful deployment
        }
        failure {
            echo 'Deployment failed!'
            // Optionally, trigger notifications or rollback actions upon deployment failure
        }
    }
}
