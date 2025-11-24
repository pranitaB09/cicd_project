pipeline {

    agent any

    environment {
        SONARQUBE_SERVER = 'sonarqube'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git 'https://github.com/pranitaB09/cicd_project'
            }
        }

        stage('Install Sonar Scanner') {
            steps {
                sh '''
                    echo "Installing Sonar Scanner..."

                    apk update
                    apk add wget unzip

                    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-5.0.1.3006-linux.zip
                    unzip sonar-scanner-*.zip

                    mv sonar-scanner-*/ /opt/sonar-scanner

                    export PATH=$PATH:/opt/sonar-scanner/bin
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh '''
                        export PATH=$PATH:/opt/sonar-scanner/bin
                        sonar-scanner
                    '''
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
