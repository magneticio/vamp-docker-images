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
    string(name: 'VAMP_CHANGE_TARGET', defaultValue: '', description: 'Target branch name for a PR')
    string(name: 'VAMP_CHANGE_URL', defaultValue: '', description: 'URL for a PR')
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
            if [ -z "$VAMP_GIT_ROOT" ]; then
              export VAMP_GIT_ROOT=$(git remote -v | grep fetch | awk '{ print $2 }' | awk -F '/' '{ print "git@" $3 ":" $4 }')
            fi

            if [ -n "$CHANGE_TARGET" ]; then
              export VAMP_CHANGE_TARGET=$CHANGE_TARGET
              export VAMP_CHANGE_URL=$CHANGE_URL
              export VAMP_TAG_PREFIX="pr-$(echo $CHANGE_URL | sed -e 's,.*/vamp-docker-images/pull/,,g')-"
            else
              export VAMP_TAG_PREFIX="build-$BUILD_NUMBER-"
            fi

            if [ -n "$VAMP_CHANGE_TARGET" ]; then
              export VAMP_GIT_BRANCH=$VAMP_CHANGE_TARGET
            fi

            if [ -z "$VAMP_GIT_BRANCH" ]; then
              export VAMP_GIT_BRANCH=$BRANCH_NAME
            fi

            if [ $VAMP_GIT_BRANCH = "master" ]; then
              unset VAMP_TAG_PREFIX
            fi

            git pull
            cd tests/docker

            for image in $(docker image ls --format='{{.Repository}}:{{.Tag}}' | grep -ve 'vamp' -ve 'magneticio/java'); do
              docker pull ${image} || true
            done

            export PACKER="packer-${VAMP_TAG_PREFIX}$(git describe --all | sed 's,/,_,g')"
            mkdir -p ${WORKSPACE}/.cache/bower ${WORKSPACE}/.ivy2 ${WORKSPACE}/.node-gyp ${WORKSPACE}/.npm ${WORKSPACE}/.sbt/boot ${WORKSPACE}/.m2/repository
            rm -rf ${WORKSPACE}/.ivy2/local
            env HOME=$WORKSPACE ./build.sh
            tag=$(echo $VAMP_GIT_BRANCH | sed 's,/,_,g')
            if [ "$VAMP_GIT_BRANCH" = "master" ]; then
              tag=katana
            fi
            tag="${VAMP_TAG_PREFIX}${tag}"

            if [ -z "$VAMP_CHANGE_TARGET" ]; then
              ./push.sh $tag
            fi

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

      if [ -n "$VAMP_CHANGE_TARGET" ]; then
        export VAMP_GIT_BRANCH=$VAMP_CHANGE_TARGET
      fi

      if [ -n "$CHANGE_TARGET" ]; then
        export VAMP_GIT_BRANCH=$CHANGE_TARGET
        export VAMP_TAG_PREFIX="pr-$(echo $CHANGE_URL | sed -e 's,.*/vamp-docker-images/pull/,,g')-"
      else
        export VAMP_TAG_PREFIX="build-$BUILD_NUMBER-"
      fi

      if [ -z "$VAMP_GIT_BRANCH" ]; then
        export VAMP_GIT_BRANCH=$BRANCH_NAME
      fi

      if [ $VAMP_GIT_BRANCH = "master" ]; then
        unset VAMP_TAG_PREFIX
      fi

      tag=$(echo $VAMP_GIT_BRANCH | sed 's,/,_,g')
      if [ "$VAMP_GIT_BRANCH" = "master" ]; then
        tag="katana--"
      fi
      tag="${VAMP_TAG_PREFIX}${tag}"

      exited_containers=$(docker ps -a -f status=exited -q)
      dead_containers=$(docker ps -a -f status=dead -q)
      test -n "${exited_containers}" -o -n "${dead_containers}" && docker rm ${exited_containers} ${dead_containers}

      remote_images=$(docker image ls -f reference="magneticio/vamp*:${tag}*" --format '{{.Repository}}:{{.Tag}}')
      local_images=$(docker image ls -f reference="vamp*:${tag}*" --format '{{.Repository}}:{{.Tag}}')
      test -n "${remote_images}" -o -n "${local_images}" && docker rmi -f ${remote_images} ${local_images}

      dangling_images=$(docker image ls -f dangling=true -q)
      while [ -n "${dangling_images}" ]; do
        docker rmi -f ${dangling_images}
        dangling_images=$(docker image ls -f dangling=true -q)
      done

      docker volume rm "packer-${VAMP_TAG_PREFIX}$(git describe --all | sed 's,/,_,g')" 2>/dev/null
      dangling_volumes=$(docker volume ls -f dangling=true -q | grep -vEe '^packer')
      test -n "${dangling_volumes}" && docker volume rm ${dangling_volumes}

      find ${WORKSPACE}/target -type d -name 'scala-2.*' | xargs -I {} find {} -maxdepth 1 -type f -name '*.jar' -print -delete

      exit 0
      '''
    }
  }
}
