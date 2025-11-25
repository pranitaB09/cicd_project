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
      image: jenkins/inbound-agent:latest
      args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']

    - name: sonar
      image: sonarsource/sonar-scanner-cli:latest
      command: ['cat']
      tty: true
      resources:
        requests:
          memory: "256Mi"
          cpu: "100m"
        limits:
          memory: "512Mi"
          cpu: "300m"

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
          memory: "512Mi"
          cpu: "200m"
        limits:
          memory: "1Gi"
          cpu: "500m"

  volumes:
    - name: docker-lib
      emptyDir: {}
    - name: workspace
      emptyDir: {}
"""
    }
  }

  environment {
    SONAR_SERVER_NAME = "SonarQubeServer"
    SONAR_HOST_URL     = "http://sonarqube.imcc.com/"

    NEXUS_REGISTRY     = "nexus.imcc.com:8083"
    NEXUS_CREDENTIALS  = "nexus-creds"

    IMAGE_BACKEND      = "2401020_restaurant_backend"
    IMAGE_FRONTEND     = "2401020_restaurant_frontend"

    DEPLOY_SSH_CREDENTIAL = "deploy-ssh"
    DEPLOY_USER_HOST       = "ubuntu@10.0.0.15"
    DEPLOY_PATH            = "/home/ubuntu/restaurant_app"

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

    stage('SonarQube Analysis') {
      steps {
        container('sonar') {
          withSonarQubeEnv("${SONAR_SERVER_NAME}") {
            withCredentials([string(credentialsId: "${SONAR_TOKEN_CRED}", variable: 'SONAR_TOKEN')]) {
              sh '''
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
          sh 'echo "Waiting for dockerd..." && sleep 10 || true'
          withEnv(["DOCKER_HOST=unix:///var/run/docker.sock"]) {
            sh """
              docker build -t ${IMAGE_BACKEND}:latest ./backend
              docker build --build-arg REACT_APP_BACKEND_URL=http://backend:4000 -t ${IMAGE_FRONTEND}:latest ./frontend
            """
          }
        }
      }
    }

    stage('Push to Nexus') {
      steps {
        container('docker') {
          withEnv(["DOCKER_HOST=unix:///var/run/docker.sock"]) {
            withCredentials([usernamePassword(credentialsId: "${NEXUS_CREDENTIALS}", usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
              sh '''
                echo "$NEXUS_PASS" | docker login ${NEXUS_REGISTRY} -u "$NEXUS_USER" --password-stdin
                docker tag ${IMAGE_BACKEND}:latest ${NEXUS_REGISTRY}/${IMAGE_BACKEND}:latest
                docker tag ${IMAGE_FRONTEND}:latest ${NEXUS_REGISTRY}/${IMAGE_FRONTEND}:latest
                docker push ${NEXUS_REGISTRY}/${IMAGE_BACKEND}:latest
                docker push ${NEXUS_REGISTRY}/${IMAGE_FRONTEND}:latest
              '''
            }
          }
        }
      }
    }

    stage('Deploy to Server') {
      steps {
        sshagent([ "${DEPLOY_SSH_CREDENTIAL}" ]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER_HOST} '
              docker pull ${NEXUS_REGISTRY}/${IMAGE_BACKEND}:latest
              docker pull ${NEXUS_REGISTRY}/${IMAGE_FRONTEND}:latest

              docker stop restaurant-backend || true
              docker rm restaurant-backend || true
              docker run -d --name restaurant-backend -p 4000:4000 ${NEXUS_REGISTRY}/${IMAGE_BACKEND}:latest

              docker stop restaurant-frontend || true
              docker rm restaurant-frontend || true
              docker run -d --name restaurant-frontend -p 80:3000 ${NEXUS_REGISTRY}/${IMAGE_FRONTEND}:latest
            '
          """
        }
      }
    }
  }

  post {
    always {
      container('docker') {
        withEnv(["DOCKER_HOST=unix:///var/run/docker.sock"]) {
          sh 'docker system prune -af || true'
        }
      }
    }
  }
}
