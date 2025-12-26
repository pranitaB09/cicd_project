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

        // ---------- SONAR CONFIG ----------
        PROJECT_KEY   = "2401020_Restaurant_project"
        PROJECT_NAME  = "2401020_Restaurant_project"
        SONAR_URL     = "http://sonarqube.sonarqube.svc.cluster.local:9000"
        SONAR_SOURCES = "frontend,backend"

        // ---------- DOCKER CONFIG ----------
        BACKEND_IMAGE  = "mern-backend:latest"
        FRONTEND_IMAGE = "mern-frontend:latest"

        // ---------- K8S CONFIG ----------
        NAMESPACE = "2401020"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/pranitaB09/cicd_project.git',
                    branch: 'main'
            }
        }

        stage('Build Docker Images') {
            steps {
                container('dind') {
                    sh '''
                        echo "⏳ Waiting for Docker..."
                        until docker info > /dev/null 2>&1; do
                          sleep 3
                        done

                        echo "🐳 Building Backend Image..."
                        docker build -t ${BACKEND_IMAGE} -f Dockerfile.backend .

                        echo "🐳 Building Frontend Image..."
                        docker build -t ${FRONTEND_IMAGE} -f Dockerfile.frontend .

                        docker images
                    '''
                }
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
                      -Dsonar.projectKey=2401020_Restaurant_project \
                      -Dsonar.projectName=2401020_Restaurant_project \
                      -Dsonar.sources=frontend,backend \
                      -Dsonar.host.url=http://sonarqube.sonarqube.svc.cluster.local:9000 \
                      -Dsonar.token=${SONAR_TOKEN}
                '''
            }
        }
    }
}

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                        echo "🚀 Deploying MERN Application..."
                        kubectl apply -f k8s/ -n ${NAMESPACE}

                        kubectl rollout status deployment/backend -n ${NAMESPACE}
                        kubectl rollout status deployment/frontend -n ${NAMESPACE}

                        echo "✅ MERN Application Deployed Successfully"
                    '''
                }
            }
        }
    }
}
