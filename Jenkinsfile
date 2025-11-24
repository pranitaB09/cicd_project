pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: jnlp
      image: jenkins/inbound-agent
      args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']

    - name: scanner
      image: sonarsource/sonar-scanner-cli:latest
      command: ['cat']
      tty: true

    - name: dind
      image: docker:dind
      securityContext:
        privileged: true
      env:
        - name: DOCKER_TLS_CERTDIR
          value: ""
      tty: true

    - name: kubectl
      image: bitnami/kubectl:latest
      command: ['cat']
      tty: true
"""
        }
    }

    environment {
        SONARQUBE_SERVER = 'sonarqube'
        SONAR_HOST_URL = 'http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000'

        NEXUS_DOCKER_REPO = "nexus.mycompany.com:8083"
        IMAGE_FRONTEND = "notes-frontend"
        IMAGE_BACKEND = "notes-backend"

        DEPLOY_SERVER = "ubuntu@10.0.0.15"
        DEPLOY_PATH = "/home/ubuntu/notes-app"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/pranitaB09/cicd_project'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                container('scanner') {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh """
                            sonar-scanner \
                                -Dsonar.projectKey=${2401020_Restaurant_Reservation} \
                                -Dsonar.host.url=${SONAR_HOST_URL} \
                                -Dsonar.login=$SONAR_TOKEN \
                                -Dsonar.sources=.
                        """
                    }
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                container('dind') {
                    sh """
                        sleep 10
                        docker build -t ${IMAGE_BACKEND}:latest ./backend
                        docker build -t ${IMAGE_FRONTEND}:latest ./frontend
                        docker image ls
                    """
                }
            }
        }

        stage('Tag & Push Images') {
            steps {
                container('dind') {
                    sh """
                        docker tag ${IMAGE_BACKEND}:latest ${NEXUS_DOCKER_REPO}/${IMAGE_BACKEND}:v1
                        docker tag ${IMAGE_FRONTEND}:latest ${NEXUS_DOCKER_REPO}/${IMAGE_FRONTEND}:v1

                        docker login ${NEXUS_DOCKER_REPO} -u admin -p Changeme@2025

                        docker push ${NEXUS_DOCKER_REPO}/${IMAGE_BACKEND}:v1
                        docker push ${NEXUS_DOCKER_REPO}/${IMAGE_FRONTEND}:v1
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    script {
                        dir(DEPLOY_DIR) {
                            sh """
                                kubectl apply -f backend-deployment.yaml -n ${K8S_NAMESPACE}
                                kubectl apply -f frontend-deployment.yaml -n ${K8S_NAMESPACE}

                                kubectl rollout status deployment/backend -n ${K8S_NAMESPACE}
                                kubectl rollout status deployment/frontend -n ${K8S_NAMESPACE}
                            """
                        }
                    }
                }
            }
        }
    }
}
