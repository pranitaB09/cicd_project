@@ -1,141 +1,142 @@
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
      resources:
        requests:
          memory: "1Gi"
          cpu: "500m"
        limits:
          memory: "2Gi"
          cpu: "1"

    - name: docker
      image: docker:dind
      securityContext:
        privileged: true
      command: ['cat']
      tty: true

    - name: kubectl
      image: bitnami/kubectl:latest
      command: ['cat']
      tty: true
      securityContext:
        runAsUser: 0
        readOnlyRootFilesystem: false
      volumeMounts:
        - name: kubeconfig-secret
          mountPath: /kube/config
          subPath: kubeconfig

  volumes:
    - name: kubeconfig-secret
      secret:
        secretName: kubeconfig-secret
"""
        }
    }

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
                container('scanner') {
                    withCredentials([string(credentialsId: 'sonar-token-2401199', variable: 'SONAR_TOKEN')]) {
                        sh """
                            sonar-scanner \
                                -Dsonar.projectKey='${SONAR_PROJECT_KEY}' \
                                -Dsonar.host.url=${SONAR_HOST_URL} \
                                -Dsonar.login=$SONAR_TOKEN \
                                -Dsonar.sources=.
                        """
                    }
                }
       stage('SonarQube Analysis') {
    steps {
        container('scanner') {
            withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                sh '''
                    sonar-scanner \
                        -Dsonar.projectKey=2401020_Restaurant_Reservation \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.token=$SONAR_TOKEN \
                        -Dsonar.sources=backend,frontend
                '''
            }
        }
    }
}


        stage('Build Backend Docker Image') {
            steps {
                container('docker') {
                    sh """
                        docker build -t ${IMAGE_BACKEND}:latest ./backend
                        docker image ls
                    """
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                container('docker') {
                    sh """
                        docker build -t ${IMAGE_FRONTEND}:latest ./frontend
                        docker image ls
                    """
                }
            }
        }

        stage('Login to Nexus Docker Registry') {
            steps {
                container('docker') {
                    sh 'docker login -u admin -p Changeme@2025 nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085'
                }
            }
        }

        stage('Tag & Push Docker Images') {
            steps {
                container('docker') {
                    sh """
                        docker tag ${IMAGE_BACKEND}:latest ${NEXUS_DOCKER_REPO}/${IMAGE_BACKEND}:v1
                        docker tag ${IMAGE_FRONTEND}:latest ${NEXUS_DOCKER_REPO}/${IMAGE_FRONTEND}:v1
                        docker push ${NEXUS_DOCKER_REPO}/${IMAGE_BACKEND}:v1
                        docker push ${NEXUS_DOCKER_REPO}/${IMAGE_FRONTEND}:v1
                    """
                }
            }
        }

        stage('Deploy Application') {
            steps {
                container('kubectl') {
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
    }
}