pipeline {
    agent {
        kubernetes {
            label '2401020-restaurant-reservation-multi'
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins/label: 2401020-restaurant-reservation-multi
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
    volumeMounts:
      - mountPath: /home/jenkins/agent
        name: workspace-volume
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
      - cat
    tty: true
    volumeMounts:
      - mountPath: /workspace
        name: workspace-volume
      - mountPath: /kaniko/.docker
        name: kaniko-secret
  - name: scanner
    image: sonarsource/sonar-scanner-cli:latest
    command:
      - cat
    tty: true
    volumeMounts:
      - mountPath: /home/jenkins/agent
        name: workspace-volume
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
      - cat
    tty: true
    volumeMounts:
      - mountPath: /home/jenkins/agent
        name: workspace-volume
  volumes:
    - name: workspace-volume
      emptyDir: {}
    - name: kaniko-secret
      secret:
        secretName: kaniko-secret
"""
        }
    }

    environment {
        DOCKER_REGISTRY = "my-nexus-registry.com"   // Replace with your registry
        DOCKER_CREDENTIALS_ID = "nexus-docker"      // Jenkins credentials ID
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
                    withCredentials([string(credentialsId: 'sonar-token-id', variable: 'SONAR_TOKEN')]) {
                        sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=2401020_Restaurant_Reservation \
                          -Dsonar.host.url=http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000 \
                          -Dsonar.token=$SONAR_TOKEN \
                          -Dsonar.sources=backend,frontend
                        '''
                    }
                }
            }
        }

        stage('Build & Push Backend Docker Image') {
            steps {
                container('kaniko') {
                    sh '''
                    /kaniko/executor \
                      --context /workspace/backend \
                      --dockerfile /workspace/backend/Dockerfile \
                      --destination $DOCKER_REGISTRY/restaurant-backend:latest \
                      --verbosity info \
                      --insecure \
                      --skip-tls-verify
                    '''
                }
            }
        }

        stage('Build & Push Frontend Docker Image') {
            steps {
                container('kaniko') {
                    sh '''
                    /kaniko/executor \
                      --context /workspace/frontend \
                      --dockerfile /workspace/frontend/Dockerfile \
                      --destination $DOCKER_REGISTRY/restaurant-frontend:latest \
                      --verbosity info \
                      --insecure \
                      --skip-tls-verify
                    '''
                }
            }
        }

        stage('Deploy Application') {
            steps {
                container('kubectl') {
                    sh 'kubectl apply -f k8s/'
                }
            }
        }

    } // stages
}
