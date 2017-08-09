pipeline {
  agent any

  options {
    buildDiscarder logRotator(daysToKeepStr: '30', numToKeepStr: '30')
    disableConcurrentBuilds()
    ansiColor('xterm')
  }

  parameters {
    string(name: 'RELEASE_TAG', defaultValue: '', description: 'Release tag')
    string(name: 'VAMP_GIT_ROOT', defaultValue: '', description: 'GitHub account URL')
    string(name: 'VAMP_GIT_BRANCH', defaultValue: '', description: 'Branch name')
  }

  stages {

    stage('Clean') {
      steps {
        sh '''
        ./build.sh -c
        docker run --rm -v $PWD:/vol alpine sh -c "rm -rf /vol/target"
        '''
      }
    }

    stage('Build') {
      steps {
        sh '''
        if [ "$VAMP_GIT_BRANCH" = "" ]; then
          export VAMP_GIT_BRANCH=$BRANCH_NAME
        fi

        ./build.sh -b -i=clique-base
        ./build.sh -b -i=clique-zookeeper
        ./build.sh -b -i=clique-zookeeper-marathon
        ./build.sh -b -i=quick-start
        ./build.sh -b -i=vamp
        ./build.sh -b -i=vamp-*
        '''
      }
    }

    stage('Release') {
      when {
        expression { params.RELEASE_TAG != '' }
      }
      steps {
        sh '''
        ./release-tag.sh ${RELEASE_TAG} push
        ./release-build.sh ${RELEASE_TAG}
        ./release-push.sh ${RELEASE_TAG}
        '''
      }
    }
  }
}
