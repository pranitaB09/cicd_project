pipeline {
    agent any

    environment {
        SONARQUBE_SERVER = 'sonarqube'  // Jenkins SonarQube server name
    }

    tools {
        nodejs "node18"              // NodeJS installation in Jenkins
        sonarScanner "sonar-scanner" // SonarQube Scanner installation
    }

    stages {
        stage('Checkout Code') {
            steps {
                deleteDir() // clean workspace
                git branch: 'main', url: 'https://github.com/pranitaB09/cicd_project'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'cd backend && npm install'
                sh 'cd frontend && npm install'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh '''
                        cd backend
                        sonar-scanner
                    '''
                }
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                sh 'docker build -t restaurant-backend ./backend'
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                sh 'docker build -t restaurant-frontend ./frontend'
            }
        }

        stage('Deploy') {
            steps {
                sh 'chmod +x deploy.sh'
                sh './deploy.sh'
            }
        }
    }

    post {
        always {
            deleteDir() // clean workspace after pipeline
        }
    }
}
