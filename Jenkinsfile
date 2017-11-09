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
              export VAMP_GIT_BRANCH=$BRANCH_NAME
            fi

            echo $VAMP_GIT_BRANCH | grep -qvEe '^PR-[0-9]+$' || { env; exit 0; }

            git pull
            cd tests/docker

            for image in $(docker image ls --format='{{.Repository}}:{{.Tag}}' | grep -ve 'vamp'); do
              docker pull ${image} || true
            done

            export PACKER="packer-$(git describe --all | sed 's,/,_,g')"
            ./build.sh
            tag=$(echo $VAMP_GIT_BRANCH | sed 's,/,_,g')
            if [ "$VAMP_GIT_BRANCH" = "master" ]; then
              tag=katana
            fi
            ./push.sh $tag

            # cd ../dcos
            # ./vamp-ui-rspec.sh build
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
      set +e

      if [ "$VAMP_GIT_BRANCH" = "" ]; then
        export VAMP_GIT_BRANCH=$BRANCH_NAME
      fi

      tag=$(echo $VAMP_GIT_BRANCH | sed 's,/,_,g')
      if [ "$VAMP_GIT_BRANCH" = "master" ]; then
        tag="katana"
      fi

      exited_containers=$(docker ps -a -f status=exited -q)
      dead_containers=$(docker ps -a -f status=dead -q)
      test -n "${exited_containers}" -o -n "${dead_containers}" && docker rm ${exited_containers} ${dead_containers}

      remote_images=$(docker image ls -f reference="magneticio/vamp*:${tag}*" --format '{{.Repository}}:{{.Tag}}')
      local_images=$(docker image ls -f reference="vamp*:${tag}*" --format '{{.Repository}}:{{.Tag}}')
      test -n "${remote_images}" -o -n "${local_images}" && docker rmi -f ${remote_images} ${local_images}

      dangling_images=$(docker image ls -f dangling=true -q)
      test -n "${dangling_images}" && docker rmi -f ${dangling_images}

      docker volume rm "packer-$(git describe --all | sed 's,/,_,g')" 2>/dev/null
      dangling_volumes=$(docker volume ls -f dangling=true -q | grep -vEe '^packer')
      test -n "${dangling_volumes}" && docker volume rm ${dangling_volumes}

      exit 0
      '''
    }
  }
}
