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
     AZURE_ADMIN_PASS = credentials('azure-test-pass')
  }

  stages {

    stage('Build images') {
      when {
        expression { params.RELEASE_TAG == '' }
      }
      steps {
        parallel (
/*  
          "deploy-dcos-1.9": {
            sh '''
            cd tests/dcos
            ./dcos-acs.sh create
            ./dcos-acs.sh clean
            '''
          },
          "deploy-dcos-1.10": {
            sh '''
              cd tests/dcos/azure
              az group create --name ci-dcos-1.10 --location westeurope
              az group deployment create \
                --name ci-dcos-1.10 \
                --resource-group ci-dcos-1.10 \
                --template-file template.json \
                --parameters @parameters.json \
                  windowsAdminPassword="${AZURE_ADMIN_PASS}" \
                  linuxAdminPassword="${AZURE_ADMIN_PASS}"
            '''
          },
*/
          "build-images": {
            sh '''
            if [ "$VAMP_GIT_ROOT" = "" ]; then
              export VAMP_GIT_ROOT=$(git remote -v | grep fetch | awk '{ print $2 }' | awk -F '/' '{ print "git@" $3 ":" $4 }')
            fi

            if [ "$VAMP_GIT_BRANCH" = "" ]; then
              export VAMP_GIT_BRANCH=$(echo $BRANCH_NAME | sed 's/[^a-z0-9_-]/-/gi')
            fi

            git pull
            cd tests/docker
            ./build.sh
            ./push.sh $VAMP_GIT_BRANCH
            if [ "$VAMP_GIT_BRANCH" = "master" ]; then
              ./push.sh katana
            fi
            cd ../dcos
            ./vamp-ui-rspec.sh build
            '''
          }
        )
      }
    }
/*
    stage('Deploy services') {
      when {
        expression { params.RELEASE_TAG == '' }
      }
      steps {
        sh '''
        cd tests/dcos
        ./dcos-acs.sh install
        '''

        sh '''
        cd tests/dcos
        fqdn="magneticio-ci-dcos-master-1-10.westeurope.cloudapp.azure.com"
        ssh-keygen -R [${fqdn}]:2200 || true
        ssh -oStrictHostKeyChecking=no -fNL 0.0.0.0:18081:localhost:80 -p 2200 dcos@${fqdn}
        dcos config set core.dcos_url http://127.0.0.1:18081
        ./dcos-acs.sh install
        '''
      }
    }

    stage('Test') {
      when {
        expression { params.RELEASE_TAG == '' }
      }
      steps {
        parallel (
          "test-dcos-1.9": {
            sh '''
            cd tests/dcos
            ./vamp-runner.sh run http://127.0.0.1:18080/service/vamp
            ./vamp-ui-rspec.sh run http://127.0.0.1:18080/service/vamp
            '''
          },
          "test-dcos-1.10": {
            sh '''
            cd tests/dcos
            ./vamp-runner.sh run http://127.0.0.1:18081/service/vamp
            ./vamp-ui-rspec.sh run http://127.0.0.1:18081/service/vamp
            '''
          }
        )
      }
    }
*/
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
      docker rm -v $(docker ps -a | grep Exited | awk '{ print $1 }') || true

      tag=$VAMP_GIT_BRANCH
      if [ "$VAMP_GIT_BRANCH" = "master" ]; then
        tag="katana"
      fi

      docker rmi -f $(docker images | grep -E "magneticio/vamp.*${tag}.*" | awk '{ print $3 }') || true
      docker rmi $(docker images | grep none | awk '{ print $3 }') || true
      
      docker volume prune --force || true
      '''
/*
      sh '''
      if [ "$VAMP_GIT_BRANCH" = "" ]; then
        export VAMP_GIT_BRANCH=$(echo $BRANCH_NAME | sed 's/[^a-z0-9_-]/-/gi')
      fi

      cd tests/docker
      ./remove.sh $VAMP_GIT_BRANCH || true
      docker rm -v $(docker ps -a | grep Exited | awk '{ print $1 }')

      az group delete --name ci-dcos-1.10 -y --no-wait
      cd ../dcos
      ./dcos-acs.sh delete || true

      cd ../..
      docker run --rm -v $(realpath $PWD/..):/vol alpine sh -c "rm -rf /vol/$(basename $WORKSPACE)"

      tag=$VAMP_GIT_BRANCH
      if [ "$VAMP_GIT_BRANCH" = "master" ]; then
        tag="katana"
      fi

      docker rmi -f $(docker images | grep -E "magneticio/vamp.*${tag}.*" | awk '{ print $3 }') || true
      docker rmi $(docker images | grep none | awk '{ print $3 }') || true
      '''
*/
    }
  }
}
