pipeline {
  agent any

  options {
    buildDiscarder logRotator(daysToKeepStr: '30', numToKeepStr: '30')
    disableConcurrentBuilds()
    ansiColor('xterm')
  }

  environment {
     AZURE_ADMIN_PASS = credentials('azure-test-pass')
  }

  stages {
    stage('Deploy DCOS on Azure') {
      steps {
        sh '''
        cd tests/dcos
        ./dcos-acs.sh create
        ./dcos-acs.sh clean
        '''
      }
    }
    stage('Deploy services') {
      steps {
        sh '''
        cd tests/dcos
        ./dcos-acs.sh install
        '''
      }
    }
  }
}
