pipeline {
    agent {
        kubernetes {
            // Specifies the Kubernetes cloud and pod configuration
            cloud 'kubernetes'
            label 'my-pipeline'
            defaultContainer 'docker'
            yaml """
            apiVersion: v1
            kind: Pod
            metadata:
              name: my-pipeline
            spec:
              containers:
                - name: docker
                  image: docker:stable
                  command:
                    - cat
                  tty: true
                - name: kubectl
                  image: lachlanevenson/k8s-kubectl:v1.20.2
                  command:
                    - cat
                  tty: true
            """
        }
    }

    environment {
        // Environment variables for Docker registry and Kubernetes config
        REGISTRY_URL_NODEJS = 'https://hub.docker.com/repository/docker/khana88/swish-final-project-nodejs/general'
        REGISTRY_URL_PYTHON = 'https://hub.docker.com/repository/docker/khana88/swish-final-project-python/general'
        KUBE_CONFIG = credentials('swish-final-project')  // Jenkins credentials for Kubernetes config
    }

    stages {
        stage('Build and Push Docker Images') {
            steps {
                script {
                    // Build and push Node.js image
                    docker.build('swish-final-project-nodejs:latest', "-f Dockerfile.nodejs .")
                    docker.withRegistry(REGISTRY_URL_NODEJS, 'khana88') {
                        docker.image('swish-final-project-nodejs:latest').push()
                    }

                    // Build and push Python image
                    docker.build('swish-final-project-python:latest', "-f Dockerfile.python .")
                    docker.withRegistry(REGISTRY_URL_PYTHON, 'khana88') {
                        docker.image('swish-final-project-python:latest').push()
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
                    docker.image("swish-final-project-nodejs:latest").remove()
                    docker.image("swish-final-project-python:latest").remove()
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
