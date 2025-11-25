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
    agent any

    environment {
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
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: jnlp
      image: jenkins/inbound-agent:latest
      args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']

    - name: sonar
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
      image: docker:24.0-dind
      securityContext:
        privileged: true
      command: ['dockerd-entrypoint.sh']
      args:
        - "--host=unix:///var/run/docker.sock"
      tty: true
      volumeMounts:
        - name: docker-lib
          mountPath: /var/lib/docker
        - name: workspace
          mountPath: /home/jenkins/agent
      resources:
        requests:
          memory: "2Gi"
          cpu: "1"
        limits:
          memory: "4Gi"
          cpu: "2"

  volumes:
    - name: docker-lib
      emptyDir: {}
    - name: workspace
      emptyDir: {}
"""
    }
  }

    stages {
  environment {
    // Sonar
    SONAR_SERVER_NAME = "SonarQubeServer"          // must match Jenkins Sonar config name
    SONAR_HOST_URL     = "http://sonarqube.imcc.com/"

        stage('Checkout Source Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/pranitaB09/cicd_project'
            }
        }
    // Nexus (Docker registry)
    NEXUS_REGISTRY     = "nexus.imcc.com:8083"     // update if different
    NEXUS_CREDENTIALS  = "nexus-creds"            // Jenkins credentials ID for Nexus (username/password)

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv(SONARQUBE_ENV) {
                    withCredentials([string(credentialsId: '2401020_sonar', variable: 'SONAR_TOKEN')]) {
                        sh """
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
    // Images
    IMAGE_BACKEND      = "2401020_restaurant_backend"
    IMAGE_FRONTEND     = "2401020_restaurant_frontend"

        stage("Quality Gate") {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    // Deployment server (SSH)
    DEPLOY_SSH_CREDENTIAL = "deploy-ssh"          // Jenkins SSH credentials ID
    DEPLOY_USER_HOST       = "ubuntu@10.0.0.15"  // update to your server user@ip
    DEPLOY_PATH            = "/home/ubuntu/restaurant_app"

        stage('Build Backend Docker Image') {
            steps {
                sh """
                    docker build -t $IMAGE_BACKEND:latest ./backend
                """
            }
        }
    // Sonar token credential id
    SONAR_TOKEN_CRED = "2401020_sonar"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[url: 'https://github.com/pranitaB09/cicd_project']]
        ])
      }
    }

        stage('Build Frontend Docker Image') {
            steps {
                sh """
                    docker build \
                        --build-arg REACT_APP_BACKEND_URL=http://backend:4000 \
                        -t $IMAGE_FRONTEND:latest ./frontend
                """
    stage('SonarQube Analysis') {
      steps {
        container('sonar') {
          withSonarQubeEnv("${SONAR_SERVER_NAME}") {
            withCredentials([string(credentialsId: "${SONAR_TOKEN_CRED}", variable: 'SONAR_TOKEN')]) {
              sh '''
                # run sonar scanner inside sonar container
                sonar-scanner \
                  -Dsonar.projectKey=2401020_Restaurant_Reservation \
                  -Dsonar.projectName=2401020_Restaurant_Reservation \
                  -Dsonar.sources=. \
                  -Dsonar.host.url=${SONAR_HOST_URL} \
                  -Dsonar.login=${SONAR_TOKEN}
              '''
            }
          }
        }
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
    stage('Quality Gate') {
      steps {
        // Wait for SonarQube quality gate result. Abort pipeline if not OK.
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

        stage('Tag & Push Images to Nexus') {
            steps {
                sh """
                    docker tag $IMAGE_BACKEND:latest $NEXUS_REPO/$IMAGE_BACKEND:latest
                    docker tag $IMAGE_FRONTEND:latest $NEXUS_REPO/$IMAGE_FRONTEND:latest
    stage('Build Docker Images (backend & frontend)') {
      steps {
        container('docker') {
          // let dockerd fully start
          sh 'echo "Waiting for dockerd..." && sleep 10 || true'

                    docker push $NEXUS_REPO/$IMAGE_BACKEND:latest
                    docker push $NEXUS_REPO/$IMAGE_FRONTEND:latest
                """
            }
          // ensure docker CLI uses the socket inside the container
          withEnv(["DOCKER_HOST=unix:///var/run/docker.sock"]) {
            sh """
              echo "=== Building backend image ==="
              ls -la ./backend || true
              docker build -t ${IMAGE_BACKEND}:latest ./backend

              echo "=== Building frontend image ==="
              ls -la ./frontend || true
              docker build --build-arg REACT_APP_BACKEND_URL=http://backend:4000 -t ${IMAGE_FRONTEND}:latest ./frontend

              docker images --format 'table {{.Repository}}\\t{{.Tag}}\\t{{.ID}}\\t{{.Size}}'
            """
          }
        }
      }
    }

    stage('Login to Nexus & Push Images') {
      steps {
        container('docker') {
          withEnv(["DOCKER_HOST=unix:///var/run/docker.sock"]) {
            withCredentials([usernamePassword(credentialsId: "${NEXUS_CREDENTIALS}", usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
              sh '''
                echo "Logging in to Nexus Docker registry..."
                echo "$NEXUS_PASS" | docker login ${NEXUS_REGISTRY} -u "$NEXUS_USER" --password-stdin

        stage('Deploy to Remote Server') {
            steps {
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
                echo "Tagging images for Nexus..."
                docker tag ${IMAGE_BACKEND}:latest ${NEXUS_REGISTRY}/${IMAGE_BACKEND}:latest
                docker tag ${IMAGE_FRONTEND}:latest ${NEXUS_REGISTRY}/${IMAGE_FRONTEND}:latest

                echo "Pushing backend..."
                docker push ${NEXUS_REGISTRY}/${IMAGE_BACKEND}:latest

                echo "Pushing frontend..."
                docker push ${NEXUS_REGISTRY}/${IMAGE_FRONTEND}:latest
              '''
            }
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
    stage('Deploy to Remote Server') {
      steps {
        // Uses SSH private key credentials stored in Jenkins (id = DEPLOY_SSH_CREDENTIAL)
        sshagent([ "${DEPLOY_SSH_CREDENTIAL}" ]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER_HOST} '
              set -e
              mkdir -p ${DEPLOY_PATH}
              cd ${DEPLOY_PATH} || exit 1

              # Ensure the remote docker daemon trusts your Nexus registry if it's insecure (optional)
              # (This step is environment-specific and may require sudo)

              # Pull latest images
              docker pull ${NEXUS_REGISTRY}/${IMAGE_BACKEND}:latest
              docker pull ${NEXUS_REGISTRY}/${IMAGE_FRONTEND}:latest

              # If you have a docker-compose.yml at DEPLOY_PATH, bring the app down and up
              if [ -f docker-compose.yml ]; then
                docker compose pull || true
                docker compose down || true
                docker compose up -d --remove-orphans
              else
                # Fallback: run backend and frontend as standalone containers
                docker stop restaurant-backend || true
                docker rm restaurant-backend || true
                docker run -d --name restaurant-backend -p 4000:4000 ${NEXUS_REGISTRY}/${IMAGE_BACKEND}:latest

                docker stop restaurant-frontend || true
                docker rm restaurant-frontend || true
                docker run -d --name restaurant-frontend -p 80:3000 ${NEXUS_REGISTRY}/${IMAGE_FRONTEND}:latest
              fi

              echo "Deployment finished on remote host."
            '
          """
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
      }
    }
  }

  post {
    always {
      echo "Cleaning up docker system on the agent..."
      container('docker') {
        withEnv(["DOCKER_HOST=unix:///var/run/docker.sock"]) {
          sh 'docker system prune -af || true'
        }
      }
    }
    success {
      echo "✅ Pipeline succeeded!"
    }
    failure {
      echo "❌ Pipeline failed. Check the logs above."
    }
  }
}