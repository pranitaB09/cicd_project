pipeline {
    agent {
        kubernetes {
            label '2401020-restaurant-reservation-12'
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
    volumeMounts:
      - mountPath: /home/jenkins/agent
        name: workspace-volume
  - name: docker
    image: docker:24-dind
    securityContext:
      privileged: true
    command:
      - dockerd-entrypoint.sh
      - --host=tcp://0.0.0.0:2375
      - --host=unix:///var/run/docker.sock
    tty: true
    volumeMounts:
      - mountPath: /home/jenkins/agent
        name: workspace-volume
  - name: scanner
    image: sonarsource/sonar-scanner-cli:latest
    command: ["cat"]
    tty: true
    volumeMounts:
      - mountPath: /home/jenkins/agent
        name: workspace-volume
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["cat"]
    tty: true
    volumeMounts:
      - mountPath: /home/jenkins/agent
        name: workspace-volume
  volumes:
  - name: workspace-volume
    emptyDir: {}
"""
        }
    }

    environment {
        SONAR_TOKEN = credentials('sqp_ef7a0be9b9821ae2b4f29a64fb8b1fc505932a05') // Replace with your SonarQube token ID
        DOCKER_REGISTRY = 'my-nexus-registry.com'  // Replace with your registry URL
        DOCKER_CREDENTIALS = 'nexus-docker'        // Replace with your Jenkins credential ID
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                container('scanner') {
                    withCredentials([string(credentialsId: 'sonar-token-id', variable: 'SONAR_TOKEN')]) {
                        sh """
                        sonar-scanner \
                        -Dsonar.projectKey=2401020_Restaurant_Reservation \
                        -Dsonar.host.url=http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000 \
                        -Dsonar.token=\$SONAR_TOKEN \
                        -Dsonar.sources=backend,frontend
                        """
                    }
                }
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                container('docker') {
                    sh '''
                    export DOCKER_HOST=tcp://localhost:2375
                    docker build -t restaurant-backend:latest ./backend
                    '''
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                container('docker') {
                    sh '''
                    export DOCKER_HOST=tcp://localhost:2375
                    docker build -t restaurant-frontend:latest ./frontend
                    '''
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh '''
                        export DOCKER_HOST=tcp://localhost:2375
                        echo $PASS | docker login $DOCKER_REGISTRY -u $USER --password-stdin
                        docker tag restaurant-backend:latest $DOCKER_REGISTRY/restaurant-backend:latest
                        docker tag restaurant-frontend:latest $DOCKER_REGISTRY/restaurant-frontend:latest
                        docker push $DOCKER_REGISTRY/restaurant-backend:latest
                        docker push $DOCKER_REGISTRY/restaurant-frontend:latest
                        '''
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                container('kubectl') {
                    sh '''
                    kubectl apply -f k8s/deployment.yaml
                    '''
                }
            }
        }
    }
}
