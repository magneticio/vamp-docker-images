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

    stage('Build images') {
      when {
        expression { params.RELEASE_TAG == '' }
      }
      steps {
        sh '''
        if [ "$VAMP_GIT_ROOT" = "" ]; then
          export VAMP_GIT_ROOT=$(git remote -v | grep fetch | awk '{ print $2 }' | awk -F '/' '{ print $1 "//" $3 "/" $4 }')
        fi

        if [ "$VAMP_GIT_BRANCH" = "" ]; then
          export VAMP_GIT_BRANCH=$(echo $BRANCH_NAME | sed 's/[^a-z0-9_-]/-/gi')
        fi

        git pull
        cd tests/docker
        ./build.sh
        ./push.sh $VAMP_GIT_BRANCH
        if [ "$VAMP_GIT_BRANCH" == "master" ]; then
          ./push.sh katana
        fi
        cd ../dcos
        ./vamp-ui-rspec.sh build
        '''
      }
    }

    stage('Deploy DC/OS') {
      when {
        expression { params.RELEASE_TAG == '' }
      }
      steps {
        sh '''
        cd tests/dcos
        ./dcos-acs.sh create
        ./dcos-acs.sh clean
        ./dcos-acs.sh install
        '''
      }
    }

    stage('Test') {
      when {
        expression { params.RELEASE_TAG == '' }
      }
      steps {
        sh '''
        cd tests/dcos
        ./vamp-runner.sh run
        ./vamp-ui-rspec.sh run
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

  post {
    always {
      sh '''
      if [ "$VAMP_GIT_BRANCH" = "" ]; then
        export VAMP_GIT_BRANCH=$(echo $BRANCH_NAME | sed 's/[^a-z0-9_-]/-/gi')
      fi

      cd tests/docker
      ./remove.sh $VAMP_GIT_BRANCH || true
      docker rm -v $(docker ps -a | grep Exited | awk '{ print $1 }')

      cd ../dcos
      ./dcos-acs.sh delete || true

      cd ../..
      ./build.sh -c
      docker run --rm -v $(realpath $PWD/..):/vol alpine sh -c "rm -rf /vol/$(basename $WORKSPACE)"
      '''
    }
  }
}
