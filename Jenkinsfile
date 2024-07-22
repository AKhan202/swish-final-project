pipeline {
    agent any

    environment {
        // Define environment variables used throughout the pipeline
        REGISTRY_URL = 'your-docker-registry.com'  // Replace with your Docker registry URL
        APP_NAME = 'your-app'
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

                    // Deploy Python application (if applicable)
                    // sh "kubectl apply -f kubernetes/python-deployment.yaml --kubeconfig=${KUBE_CONFIG}"
                    // sh "kubectl apply -f kubernetes/python-service.yaml --kubeconfig=${KUBE_CONFIG}"
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
                // Clean up old Docker images or other resources if necessary
                script {
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
