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

    environment {
        // Change as needed
        IMAGE_NAME = "restaurant-backend"
        DOCKER_USER = "your-dockerhub-username"
    }

    stages {

        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage("Build Image") {
            steps {
                container('docker') {
                    withEnv(["DOCKER_HOST=unix:///var/run/docker.sock"]) {
                        sh """
                            echo "=== Checking Docker Connection ==="
                            docker info

                            echo "=== Building Docker Image ==="
                            docker build -t ${IMAGE_NAME}:latest ./backend
                        """
                    }
                }
            }
        }

        stage("DockerHub Login") {
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
                }
            }
        }

        stage("Tag & Push Image") {
            steps {
                container('docker') {
                    withEnv(["DOCKER_HOST=unix:///var/run/docker.sock"]) {
                        sh """
                            echo "=== Tagging Image ==="
                            docker tag ${IMAGE_NAME}:latest ${DOCKER_USER}/${IMAGE_NAME}:latest

                            echo "=== Pushing Image to DockerHub ==="
                            docker push ${DOCKER_USER}/${IMAGE_NAME}:latest
                        """
                    }
                }
            }
        }

        stage("Deploy (Optional)") {
            steps {
                echo "Add deployment steps here (Kubernetes apply / SSH deploy / etc.)"
            }
        }
    }
}
