pipeline {

    agent any

    environment {
        SONARQUBE_SERVER = 'sonarqube'   // Jenkins Sonar server name
    }

    stages {

        stage('Checkout Code') {
            steps {
                git 'https://github.com/pranitaB09/cicd_project'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh 'sonar-scanner'
                }
            }
        }

        stage('Build Backend Image') {
            steps {
                sh 'docker build -t restaurant-backend ./backend'
            }
        }

        stage('Build Frontend Image') {
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
}
