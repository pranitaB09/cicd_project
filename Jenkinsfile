pipeline {
    agent any

    environment {
        SONAR_HOST_URL = 'http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000'
        SONAR_PROJECT_KEY = '2401020_Restaurant_Reservation'
        NEXUS_DOCKER_REPO = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085/ajinkya-project"
        IMAGE_FRONTEND = "restaurant-frontend"
        IMAGE_BACKEND = "restaurant-backend"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/pranitaB09/cicd_project'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh """
                    sonar-scanner \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.host.url=${SONAR_HOST_URL} \
                        -Dsonar.token=$SONAR_TOKEN \
                        -Dsonar.sources=backend,frontend
                    """
                }
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                sh """
                    echo "Building backend image..."
                    docker build -t ${IMAGE_BACKEND}:latest ./backend
                    docker image ls
                """
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                sh """
                    echo "Building frontend image..."
                    docker build -t ${IMAGE_FRONTEND}:latest ./frontend
                    docker image ls
                """
            }
        }

        stage('Login to Nexus Registry') {
            steps {
                sh """
                echo "Logging in to Nexus..."
                docker login -u admin -p Changeme@2025 nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085
                """
            }
        }

        stage('Tag & Push Images to Nexus') {
            steps {
                sh """
                    docker tag ${IMAGE_BACKEND}:latest ${NEXUS_DOCKER_REPO}/${IMAGE_BACKEND}:v1
                    docker tag ${IMAGE_FRONTEND}:latest ${NEXUS_DOCKER_REPO}/${IMAGE_FRONTEND}:v1

                    docker push ${NEXUS_DOCKER_REPO}/${IMAGE_BACKEND}:v1
                    docker push ${NEXUS_DOCKER_REPO}/${IMAGE_FRONTEND}:v1
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                dir('k8s-deployment') {
                    sh """
                        kubectl apply -f deployment.yaml
                        kubectl rollout status deployment/restaurant-backend -n 2401020
                        kubectl rollout status deployment/restaurant-frontend -n 2401020
                    """
                }
            }
        }
    }

    post {
        always {
            sh """
            echo "List Docker images:"
            docker images
            """
        }
    }
}
