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

  environment {
    AWS_REGION = 'us-east-1'
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

    stage('Build images') {
      steps {
        sh '''
        if [ "$VAMP_GIT_ROOT" = "" ]; then
          export VAMP_GIT_ROOT=$(git remote -v | grep fetch | awk '{ print $2 }' | awk -F '/' '{ print $1 "//" $3 "/" $4 }')
        fi

        if [ "$VAMP_GIT_BRANCH" = "" ]; then
          export VAMP_GIT_BRANCH=$(echo $BRANCH_NAME | sed 's/[^a-z0-9_-]/-/gi')
        fi

        git pull
        cd tests
        ./test-build.sh
        ./test-push.sh $VAMP_GIT_BRANCH
        ./vamp-ui-rspec.sh build
        cd -
        '''
      }
    }

    stage('Deploy DC/OS') {
      steps {
        sh '''
        cd tests/dcos
        ./get-dcos-templates.sh
        ./dcos-aws.sh create
        ./setup-dcos-cli.sh
        ./dcos-vamp.sh install
        cd -
        '''
      }
    }

    stage('Test') {
      steps {
        sh '''
        cd tests
        ./vamp-runner.sh run
        ./vamp-ui-rspec.sh run
        cd -
        '''
      }
    }

    stage('Destroy DC/OS') {
      steps {
        sh '''
        cd tests/dcos
        ./dcos-aws.sh delete
        cd -
        '''
      }
    }

    stage('Remove tags') {
      steps {
        sh '''
        if [ "$VAMP_GIT_BRANCH" = "" ]; then
          export VAMP_GIT_BRANCH=$(echo $BRANCH_NAME | sed 's/[^a-z0-9_-]/-/gi')
        fi

        cd tests
        ./test-remove.sh $VAMP_GIT_BRANCH
        cd -
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
