// pipeline {
//     agent {
//         kubernetes {
//             yaml """
// apiVersion: v1
// kind: Pod
// spec:
//   containers:
//     - name: jnlp
//       image: jenkins/inbound-agent
//       args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']

//     - name: scanner
//       image: sonarsource/sonar-scanner-cli:latest
//       command: ['cat']
//       tty: true
//       resources:
//         requests:
//           memory: "1Gi"
//           cpu: "500m"
//         limits:
//           memory: "2Gi"
//           cpu: "1"

//     - name: docker
//       image: docker:dind
//       securityContext:
//         privileged: true
//       command: ['cat']
//       tty: true

//     - name: kubectl
//       image: bitnami/kubectl:latest
//       command: ['cat']
//       tty: true
//       securityContext:
//         runAsUser: 0
//         readOnlyRootFilesystem: false
//       volumeMounts:
//         - name: kubeconfig-secret
//           mountPath: /kube/config
//           subPath: kubeconfig

//   volumes:
//     - name: kubeconfig-secret
//       secret:
//         secretName: kubeconfig-secret
// """
//         }
//     }

//     environment {
//         SONAR_HOST_URL = 'http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000'
//         SONAR_PROJECT_KEY = '2401020_Restaurant_Reservation'
//         NEXUS_DOCKER_REPO = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085/ajinkya-project"
//         IMAGE_FRONTEND = "restaurant-frontend"
//         IMAGE_BACKEND = "restaurant-backend"
//     }

//     stages {

//         stage('Checkout Code') {
//             steps {
//                 git branch: 'main', url: 'https://github.com/pranitaB09/cicd_project'
//             }
//         }

//        stage('SonarQube Analysis') {
//     steps {
//         container('scanner') {
//             withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
//                 sh '''
//                     sonar-scanner \
//                         -Dsonar.projectKey=2401020_Restaurant_Reservation \
//                         -Dsonar.host.url=$SONAR_HOST_URL \
//                         -Dsonar.token=$SONAR_TOKEN \
//                         -Dsonar.sources=backend,frontend
//                 '''
//             }
//         }
//     }
// }


//         stage('Build Backend Docker Image') {
//             steps {
//                 container('docker') {
//                     sh """
//                         docker build -t ${IMAGE_BACKEND}:latest ./backend
//                         docker image ls
//                     """
//                 }
//             }
//         }

//         stage('Build Frontend Docker Image') {
//             steps {
//                 container('docker') {
//                     sh """
//                         docker build -t ${IMAGE_FRONTEND}:latest ./frontend
//                         docker image ls
//                     """
//                 }
//             }
//         }

//         stage('Login to Nexus Docker Registry') {
//             steps {
//                 container('docker') {
//                     sh 'docker login -u admin -p Changeme@2025 nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085'
//                 }
//             }
//         }

//         stage('Tag & Push Docker Images') {
//             steps {
//                 container('docker') {
//                     sh """
//                         docker tag ${IMAGE_BACKEND}:latest ${NEXUS_DOCKER_REPO}/${IMAGE_BACKEND}:v1
//                         docker tag ${IMAGE_FRONTEND}:latest ${NEXUS_DOCKER_REPO}/${IMAGE_FRONTEND}:v1
//                         docker push ${NEXUS_DOCKER_REPO}/${IMAGE_BACKEND}:v1
//                         docker push ${NEXUS_DOCKER_REPO}/${IMAGE_FRONTEND}:v1
//                     """
//                 }
//             }
//         }

//         stage('Deploy Application') {
//             steps {
//                 container('kubectl') {
//                     dir('k8s-deployment') {
//                         sh """
//                             kubectl apply -f deployment.yaml
//                             kubectl rollout status deployment/restaurant-backend -n 2401020
//                             kubectl rollout status deployment/restaurant-frontend -n 2401020
//                         """
//                     }
//                 }
//             }
//         }
//     }
// }


pipeline {

    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: docker
      image: docker:dind
      securityContext:
        privileged: true
      command:
        - dockerd-entrypoint.sh
      args:
        - "--host=unix:///var/run/docker.sock"
      tty: true
      volumeMounts:
        - name: docker-lib
          mountPath: /var/lib/docker
  volumes:
    - name: docker-lib
      emptyDir: {}
"""
        }
    }
    agent any

    environment {
        // Change as needed
        IMAGE_NAME = "restaurant-backend"
        DOCKER_USER = "your-dockerhub-username"
        // ----- SONAR -----
        SONARQUBE_ENV = 'SonarQubeServer'
        SONAR_PROJECT_KEY = '2401020_Restaurant_Reservation'
        SONAR_HOST_URL = 'http://sonarqube.imcc.com'

        // ----- DOCKER -----
        IMAGE_BACKEND = "restaurant-backend"
        IMAGE_FRONTEND = "restaurant-frontend"

        // ----- NEXUS -----
        NEXUS_REPO = "nexus.imcc.com:8085"
        
        // ----- DEPLOY -----
        DEPLOY_SERVER = "ubuntu@10.0.0.15"
        DEPLOY_PATH = "/home/ubuntu/restaurant_app"
    }

    stages {

        stage("Checkout") {
        stage('Checkout Source Code') {
            steps {
                checkout scm
                git branch: 'main',
                    url: 'https://github.com/pranitaB09/cicd_project'
            }
        }

        stage("Build Image") {
        stage('SonarQube Analysis') {
            steps {
                container('docker') {
                    withEnv(["DOCKER_HOST=unix:///var/run/docker.sock"]) {
                withSonarQubeEnv(SONARQUBE_ENV) {
                    withCredentials([string(credentialsId: '2401020_sonar', variable: 'SONAR_TOKEN')]) {
                        sh """
                            echo "=== Checking Docker Connection ==="
                            docker info

                            echo "=== Building Docker Image ==="
                            docker build -t ${IMAGE_NAME}:latest ./backend
                            sonar-scanner \
                                -Dsonar.projectKey=$SONAR_PROJECT_KEY \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=$SONAR_HOST_URL \
                                -Dsonar.login=$SONAR_TOKEN
                        """
                    }
                }
            }
        }

        stage("DockerHub Login") {
        stage("Quality Gate") {
            steps {
                container('docker') {
                    withEnv(["DOCKER_HOST=unix:///var/run/docker.sock"]) {
                        withCredentials([usernamePassword(
                            credentialsId: 'dockerhub-creds',
                            usernameVariable: 'USER',
                            passwordVariable: 'PASS'
                        )]) {
                            sh """
                                echo "$PASS" | docker login -u "$USER" --password-stdin
                            """
                        }
                    }
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage("Tag & Push Image") {
        stage('Build Backend Docker Image') {
            steps {
                container('docker') {
                    withEnv(["DOCKER_HOST=unix:///var/run/docker.sock"]) {
                        sh """
                            echo "=== Tagging Image ==="
                            docker tag ${IMAGE_NAME}:latest ${DOCKER_USER}/${IMAGE_NAME}:latest
                sh """
                    docker build -t $IMAGE_BACKEND:latest ./backend
                """
            }
        }

                            echo "=== Pushing Image to DockerHub ==="
                            docker push ${DOCKER_USER}/${IMAGE_NAME}:latest
                        """
                    }
        stage('Build Frontend Docker Image') {
            steps {
                sh """
                    docker build \
                        --build-arg REACT_APP_BACKEND_URL=http://backend:4000 \
                        -t $IMAGE_FRONTEND:latest ./frontend
                """
            }
        }

        stage('Login to Nexus Registry') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'nexus-creds', 
                    usernameVariable: 'NEXUS_USER', 
                    passwordVariable: 'NEXUS_PASS'
                )]) {
                    sh """
                        docker login $NEXUS_REPO -u $NEXUS_USER -p $NEXUS_PASS
                    """
                }
            }
        }

        stage("Deploy (Optional)") {
        stage('Tag & Push Images to Nexus') {
            steps {
                sh """
                    docker tag $IMAGE_BACKEND:latest $NEXUS_REPO/$IMAGE_BACKEND:latest
                    docker tag $IMAGE_FRONTEND:latest $NEXUS_REPO/$IMAGE_FRONTEND:latest

                    docker push $NEXUS_REPO/$IMAGE_BACKEND:latest
                    docker push $NEXUS_REPO/$IMAGE_FRONTEND:latest
                """
            }
        }

        stage('Deploy to Remote Server') {
            steps {
                echo "Add deployment steps here (Kubernetes apply / SSH deploy / etc.)"
                sshagent(['deploy-ssh']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no $DEPLOY_SERVER '
                            mkdir -p $DEPLOY_PATH &&
                            cd $DEPLOY_PATH &&
                            docker pull $NEXUS_REPO/$IMAGE_BACKEND:latest &&
                            docker pull $NEXUS_REPO/$IMAGE_FRONTEND:latest &&
                            docker compose down || true &&
                            docker compose up -d
                        '
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning Docker..."
            sh "docker system prune -f || true"
        }
        success {
            echo "🎉 CI/CD pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}