pipeline {
    agent any

    tools { go 'go 1.19' } // Comes from the jenkins global config

    environment {
        ENV = "${env.BRANCH_NAME == 'master' ? 'PROD' : 'DEV'}"
        BRANCH = "${env.BRANCH_NAME}" // Needed by the deployment 
    }

    stages {
        stage('Send initial notification') {
            when {
                anyOf {
                    branch 'master';
                    branch 'develop'
                }
            }
            steps {
                slackSend channel: '#all-jenkins-lab',
                        message: "Build for job ${env.JOB_NAME} has started - (<${env.BUILD_URL}|Open>)"
            }
        }
        stage('Scan for secrets') {
            steps {
                sh '''
                    curl -LO https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_x64.tar.gz
                    tar -xzf gitleaks_8.30.1_linux_x64.tar.gz

                    ./gitleaks protect -v

                    rm -rf gitleaks*
                '''
            }
        }
        stage('Build'){
            steps {
                sh 'bash scripts/build.sh'
            }
        }
        stage('Test') {
            steps {
                sh 'bash scripts/test.sh'
            }
        }
        stage('Deploy'){
            when {
                anyOf {
                    branch 'master';
                    branch 'develop'
                }
            }
            steps {
                sh 'export JENKINS_NODE_COOKIE=do_not_kill ; bash scripts/deploy.sh'
            }
        }
    }
    post {
        always {
            slackSend channel: '#all-jenkins-lab',
                      color: "${currentBuild.currentResult == 'SUCCESS' ? 'good' : 'danger'}",
                      message: "Build for job ${env.JOB_NAME} finished with status ${currentBuild.currentResult} - (<${env.BUILD_URL}|Open>)"
        }
    }
}
