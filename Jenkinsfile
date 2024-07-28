pipeline {
    agent {
         kubernetes {
            cloud 'minikube'
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
        HELM_HOME = '/usr/local/bin/helm'
        KUBE_NAMESPACE = 'dev-environments'
        REGISTRY_URL = 'https://hub.docker.com/repositories/khana88'
        KUBE_CONFIG = credentials('swish-final-project')  
    }

    parameters {
        choice(name: 'BASE_IMAGE', choices: ['Alpine', 'Ubuntu'], description: 'Base image to use')
        string(name: 'MEMORY', defaultValue: '2Gi', description: 'Memory request for the container')
        string(name: 'CPU', defaultValue: '1', description: 'CPU request for the container')
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://my-workspace21-admin@bitbucket.org/my-workspace21/swish-final-project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def dockerfile = ""
                    def imageTag = ""
                    if (params.BASE_IMAGE == 'Alpine') {
                        dockerfile = 'docker/Dockerfile.alpine'
                        imageTag = 'swish-final-project-alpine'
                        sh "docker build -t khana88/swish-final-project-alpine:latest -f ${dockerfile} ."
                    } else if (params.BASE_IMAGE == 'Ubuntu') {
                        dockerfile = 'docker/Dockerfile.ubuntu'
                        imageTag = 'swish-final-project-ubuntu'
                        sh "docker build -t khana88/swish-final-project-ubuntu:latest -f ${dockerfile} ."
                    }

                    
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def imageTag = ""
                    if (params.BASE_IMAGE == 'Alpine') {
                        imageTag = 'swish-final-project-alpine'
                        sh "docker push khana88/swish-final-project-alpine:latest"
                    } else if (params.BASE_IMAGE == 'Ubuntu') {
                        imageTag = 'swish-final-project-ubuntu'
                        sh "docker push khana88/swish-final-project-ubuntu:latest"
                    }

                    
                }
            }
        }

        stage('Package Helm Chart') {
            steps {
                script {
                    sh "helm package helm/dev-environment swish-final-project/helm/dev-environment"
                }   
            }
        }

        stage('Deploy Monitoring') {
            steps {
                script {
                    sh "helm upgrade --install prometheus helm/prometheus --namespace dev-environments --values helm/prometheus/values.yaml"
                    sh "helm upgrade --install grafana helm/grafana --namespace dev-environments --values helm/grafana/values.yaml"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    helm upgrade --install dev-environment helm/dev-environment \
                      --namespace dev-environments \
                      --set image.repository=docker.io/khana88/swish-final-project-alpine/latest \
                      --set image.tag=latest \
                      --set resources.requests.memory="512Mi" \
                      --set resources.requests.cpu="250m" \
                      --values helm/dev-environment/values.yaml
                    """
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sh "kubectl get pods --namespace=dev-environments"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
