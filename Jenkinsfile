pipeline {
  agent any

  options {
    buildDiscarder logRotator(daysToKeepStr: '30', numToKeepStr: '30')
    disableConcurrentBuilds()
    ansiColor('xterm')
  }

  parameters {
    booleanParam(name: 'CLEAN', defaultValue: false, description: 'Clean build')
    string(name: 'VAMP_GIT_ROOT', defaultValue: '', description: 'GitHub account URL')
    string(name: 'VAMP_GIT_BRANCH', defaultValue: '', description: 'Branch name')
    string(name: 'VAMP_CHANGE_TARGET', defaultValue: '', description: 'Target branch name for a PR')
    string(name: 'VAMP_CHANGE_URL', defaultValue: '', description: 'URL for a PR')
  }

  stages {
    stage('Clean') {
      when { expression { return params.CLEAN } }
      steps {
        sh '''
        git clean -ffdx
        '''
      }
    }
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
        ./tests/push.sh
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
