pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: sonar-scanner
    image: sonarsource/sonar-scanner-cli
    command: ["cat"]
    tty: true

  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["cat"]
    tty: true
    securityContext:
      runAsUser: 0
      readOnlyRootFilesystem: false
    env:
    - name: KUBECONFIG
      value: /kube/config
    volumeMounts:
    - name: kubeconfig-secret
      mountPath: /kube/config
      subPath: kubeconfig

  - name: dind
    image: docker:24-dind
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
    command:
    - dockerd-entrypoint.sh
    args:
    - --host=unix:///var/run/docker.sock
    - --storage-driver=overlay2
    - --insecure-registry=nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085
    volumeMounts:
    - name: docker-storage
      mountPath: /var/lib/docker

  volumes:
  - name: docker-storage
    emptyDir: {}
  - name: kubeconfig-secret
    secret:
      secretName: kubeconfig-secret
'''
        }
    }

    environment {
        PROJECT_KEY   = "2401020_Restaurant_project"
        PROJECT_NAME  = "2401020_Restaurant_project"
        SONAR_URL     = "http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000"
        SONAR_SOURCES = "frontend,backend"

        NEXUS_REGISTRY = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085"
        REPO_NAME      = "my-repository"

        //IMAGE_TAG      = "${BUILD_NUMBER}" // Unique version per build
        BACKEND_IMAGE  = "${NEXUS_REGISTRY}/${REPO_NAME}/mern-backend:latest"
        FRONTEND_IMAGE = "${NEXUS_REGISTRY}/${REPO_NAME}/mern-frontend:latest"

        NAMESPACE      = "2401020"
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
                        sonar-scanner \
                          -Dsonar.projectKey=${PROJECT_KEY} \
                          -Dsonar.projectName=${PROJECT_NAME} \
                          -Dsonar.sources=${SONAR_SOURCES} \
                          -Dsonar.host.url=${SONAR_URL} \
                          -Dsonar.login=${SONAR_TOKEN}
                        '''
                    }
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                container('dind') {
                    sh '''
                    until docker info > /dev/null 2>&1; do sleep 3; done
                    echo "Building Backend Image..."
                    docker build -t ${BACKEND_IMAGE} -f Dockerfile.backend .
                    echo "Building Frontend Image..."
                    docker build -t ${FRONTEND_IMAGE} -f Dockerfile.frontend .
                    docker images
                    '''
                }
            }
        }

        stage('Login to Docker Registry') {
            steps {
                container('dind') {
                    sh 'docker --version'
                    sh 'sleep 10'
                    sh 'docker login nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085 -u admin -p Changeme@2025'
                }
            }
        }

        stage('Push Images to Nexus') {
            steps { 
                        sh '''

                        echo "Pushing Backend Image..."
                        docker push ${BACKEND_IMAGE}

                        echo "Pushing Frontend Image..."
                        docker push ${FRONTEND_IMAGE}
                        '''
                    }
                }
            
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                    echo "Applying Kubernetes manifests..."
                    kubectl apply -f k8s/ -n ${NAMESPACE}

                    echo "Waiting for Backend deployment..."
                    kubectl rollout status deployment/backend -n ${NAMESPACE}

                    echo "Waiting for Frontend deployment..."
                    kubectl rollout status deployment/frontend -n ${NAMESPACE}
                    '''
                }
            }
        }
    }
}
