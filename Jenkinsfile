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
    - name: jnlp
      image: jenkins/inbound-agent
      args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']

    - name: docker
      image: docker:24.0-dind
      securityContext:
        privileged: true
      command: ['dockerd-entrypoint.sh']
      tty: true
      resources:
        requests:
          memory: "2Gi"
          cpu: "1"
        limits:
          memory: "4Gi"
          cpu: "2"

    - name: sonar-scanner
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
"""
        }
    }

    environment {
        SONAR_HOST_URL = 'http://sonarqube.imcc.com'
        NEXUS_DOCKER_REPO = "nexus.mycompany.com:8083"
        IMAGE_FRONTEND = "notes-frontend"
        IMAGE_BACKEND = "notes-backend"
        DEPLOY_SERVER = "ubuntu@10.0.0.15"
        DEPLOY_PATH = "/home/ubuntu/restaurant_reservation"
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
                container('sonar-scanner') {
                    withSonarQubeEnv('SonarQubeServer') {
                        withCredentials([string(credentialsId: '2401020_sonar', variable: 'SONAR_AUTH_TOKEN')]) {
                            sh '''
                                sonar-scanner \
                                -Dsonar.projectKey=2401020_Restaurant_Reservation \
                                -Dsonar.projectName=2401020_Restaurant_Reservation \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=$SONAR_HOST_URL \
                                -Dsonar.login=$SONAR_AUTH_TOKEN
                            '''
                        }
                    }
                }
            }
        }


        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                container('docker') {
                    sh """
                        sleep 15

                        docker build -t ${IMAGE_BACKEND}:latest ./notes-backend

                        docker build --build-arg REACT_APP_BACKEND_URL=http://backend:4000 \
                            -t ${IMAGE_FRONTEND}:latest ./notes-frontend
                    """
                }
            }
        }

        stage('Tag & Push Images to Nexus') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'nexus-creds', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                        sh """
                            docker login ${NEXUS_DOCKER_REPO} -u $NEXUS_USER -p $NEXUS_PASS

                            docker tag ${IMAGE_BACKEND}:latest ${NEXUS_DOCKER_REPO}/${IMAGE_BACKEND}:latest
                            docker tag ${IMAGE_FRONTEND}:latest ${NEXUS_DOCKER_REPO}/${IMAGE_FRONTEND}:latest

                            docker push ${NEXUS_DOCKER_REPO}/${IMAGE_BACKEND}:latest
                            docker push ${NEXUS_DOCKER_REPO}/${IMAGE_FRONTEND}:latest
                        """
                    }
                }
            }
        }

        stage('Deploy to Server') {
            steps {
                sshagent(['DEPLOY_SERVER_SSH']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} '
                            cd ${DEPLOY_PATH} &&
                            docker compose pull &&
                            docker compose down &&
                            docker compose up -d
                        '
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up dangling Docker images...'
            container('docker') {
                sh 'docker system prune -f || true'
            }
        }
        success {
            echo 'CI/CD pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs!'
        }
    }
}