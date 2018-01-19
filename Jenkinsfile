pipeline {
  agent any

  options {
    buildDiscarder logRotator(daysToKeepStr: '30', numToKeepStr: '30')
    disableConcurrentBuilds()
    ansiColor('xterm')
  }

  parameters {
    string(name: 'VAMP_GIT_ROOT', defaultValue: '', description: 'GitHub account URL')
    string(name: 'VAMP_GIT_BRANCH', defaultValue: '', description: 'Branch name')
    string(name: 'VAMP_CHANGE_TARGET', defaultValue: '', description: 'Target branch name for a PR')
    string(name: 'VAMP_CHANGE_URL', defaultValue: '', description: 'URL for a PR')
  }

  stages {
    stage('Build') {
      steps {
        sh '''
        ./tests/build.sh
        '''
      }
    }
    stage('Publish') {
      steps {
        sh '''
        bash -c "source tests/common.sh && test -z "$VAMP_CHANGE_TARGET" && ./tests/push.sh ${VAMP_VERSION}"
        '''
      }
    }
  }

  post {
    always {
      sh '''
      ./tests/clean.sh
      '''
    }
  }
}
