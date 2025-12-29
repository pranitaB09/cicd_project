pipeline {

    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:

  # ---------- SONAR ----------
  - name: sonar-scanner
    image: sonarsource/sonar-scanner-cli
    command: ["cat"]
    tty: true

  # ---------- KUBECTL ----------
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["cat"]
    tty: true
    securityContext:
      runAsUser: 0
    env:
    - name: KUBECONFIG
      value: /kube/config
    volumeMounts:
    - name: kubeconfig-secret
      mountPath: /kube/config
      subPath: kubeconfig

  # ---------- DOCKER (DIND) ----------
  - name: dind
    image: docker:24-dind
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
    command: ["dockerd-entrypoint.sh"]
    args:
    - --host=unix:///var/run/docker.sock
    - --storage-driver=overlay2
    - --insecure-registry=nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085
    volumeMounts:
    - name: docker-storage
      mountPath: /var/lib/docker
    - name: docker-config
      mountPath: /etc/docker/daemon.json
      subPath: daemon.json

  volumes:
  - name: docker-storage
    emptyDir: {}
  - name: docker-config
    configMap:
      name: docker-daemon-config
  - name: kubeconfig-secret
    secret:
      secretName: kubeconfig-secret
'''
        }
    }

    environment {

        // ---------- SONAR ----------
        PROJECT_KEY   = "2401020_Restaurant_project"
        PROJECT_NAME  = "2401020_Restaurant_project"
        SONAR_URL     = "http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000"
        SONAR_SOURCES = "frontend,backend"

        // ---------- NEXUS ----------
        REGISTRY = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085"
        BACKEND_IMAGE  = "${REGISTRY}/2401020/mern-backend:latest"
        FRONTEND_IMAGE = "${REGISTRY}/2401020/mern-frontend:latest"

        // ---------- K8S ----------
        NAMESPACE = "2401020"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/pranitaB09/cicd_project.git', branch: 'main'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                container('sonar-scanner') {
                    withCredentials([
                        string(credentialsId: 'sonar-token-2401020', variable: 'SONAR_TOKEN')
                    ]) {
                        sh '''
                          echo "🔍 Running SonarQube Analysis..."
                          sonar-scanner \
                            -Dsonar.projectKey=${PROJECT_KEY} \
                            -Dsonar.projectName=${PROJECT_NAME} \
                            -Dsonar.sources=${SONAR_SOURCES} \
                            -Dsonar.host.url=${SONAR_URL} \
                            -Dsonar.token=${SONAR_TOKEN}
                        '''
                    }
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                container('dind') {
                    sh '''
                      echo "⏳ Waiting for Docker..."
                      until docker info > /dev/null 2>&1; do sleep 3; done

                      docker build -t mern-backend:latest -f Dockerfile.backend .
                      docker build -t mern-frontend:latest -f Dockerfile.frontend .
                    '''
                }
            }
        }

        stage('Push Images to Nexus') {
            steps {
                container('dind') {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'nexus-docker-creds',
                            usernameVariable: 'NEXUS_USER',
                            passwordVariable: 'NEXUS_PASS'
                        )
                    ]) {
                        sh '''
                          echo "🔐 Logging into Nexus..."
                          echo "${NEXUS_PASS}" | docker login ${REGISTRY} -u ${NEXUS_USER} --password-stdin

                          docker tag mern-backend:latest ${BACKEND_IMAGE}
                          docker tag mern-frontend:latest ${FRONTEND_IMAGE}

                          docker push ${BACKEND_IMAGE}
                          docker push ${FRONTEND_IMAGE}
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                      echo "🚀 Deploying application..."
                      kubectl apply -f k8s/ -n ${NAMESPACE}

                      kubectl rollout status deployment/backend -n ${NAMESPACE}
                      kubectl rollout status deployment/frontend -n ${NAMESPACE}
                    '''
                }
            }
        }
    }
}
