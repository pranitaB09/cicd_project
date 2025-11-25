pipeline {
    agent any

    environment {
        SONAR_HOST_URL = 'http://my-sonarqube-service.svc.cluster.local:9000'
        BACKEND_IMAGE = "nexus.local:8085/restaurant-backend:v1"
        FRONTEND_IMAGE = "nexus.local:8085/restaurant-frontend:v1"
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
                            -Dsonar.projectKey=2401020_Restaurant_Reservation \
                            -Dsonar.host.url=$SONAR_HOST_URL \
                            -Dsonar.token=$SONAR_TOKEN \
                            -Dsonar.sources=backend,frontend
                    """
                }
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                sh """
                    cd backend
                    docker build -t $BACKEND_IMAGE .
                """
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                sh """
                    cd frontend
                    docker build -t $FRONTEND_IMAGE .
                """
            }
        }

        stage('Login to Docker Registry') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'nexus-creds',
                        usernameVariable: 'REG_USER',
                        passwordVariable: 'REG_PASS'
                    )
                ]) {
                    sh """
                    echo "$REG_PASS" | docker login nexus.local:8085 \
                        -u "$REG_USER" --password-stdin
                    """
                }
            }
        }

        stage('Push Images') {
            steps {
                sh """
                    docker push $BACKEND_IMAGE
                    docker push $FRONTEND_IMAGE
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    kubectl apply -f k8s-deployment/deployment.yaml
                """
            }
        }
    }

    post {
        always {
            sh "docker images"
        }
    }
}
