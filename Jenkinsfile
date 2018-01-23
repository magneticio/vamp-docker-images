pipeline {
  agent any

  options {
    buildDiscarder logRotator(daysToKeepStr: '30', numToKeepStr: '30')
    disableConcurrentBuilds()
    ansiColor('xterm')
  }

  parameters {
    booleanParam(name: 'BUILD', defaultValue: false, description: 'Flag that enables only manual builds')
    string(name: 'VAMP_GIT_ROOT', defaultValue: '', description: 'GitHub account URL')
    string(name: 'VAMP_GIT_BRANCH', defaultValue: '', description: 'Branch name')
  }

  stages {

    stage('Build images') {
      when { expression { return params.BUILD } }
      steps {
        sh '''
        if [ -z "$VAMP_GIT_ROOT" ]; then
          export VAMP_GIT_ROOT=$(git remote -v | grep fetch | awk '{ print $2 }' | awk -F '/' '{ print "git@" $3 ":" $4 }')
        fi

        if [ -z "$VAMP_GIT_BRANCH" ]; then
          export VAMP_GIT_BRANCH=$BRANCH_NAME
        fi

        if [[ $( git describe --tags --abbrev=0 ) = $( git describe --tags ) ]] ; then
          vamp_version="$( git describe --tags )"
        else
          if [[ "$VAMP_GIT_BRANCH" != "" && "$VAMP_GIT_BRANCH" != "master" ]]; then
            vamp_version=$VAMP_GIT_BRANCH
          else
            vamp_version="katana"
          fi
        fi

        cd tests/docker

        mkdir -p ${WORKSPACE}/.cache/bower ${WORKSPACE}/.ivy2 ${WORKSPACE}/.node-gyp ${WORKSPACE}/.npm ${WORKSPACE}/.sbt/boot ${WORKSPACE}/.m2/repository
        env HOME=$WORKSPACE ./build.sh
        ./push.sh $vamp_version
        '''
      }
    }
  }

  post {
    always {
      sh '''
      set +e

      if [[ $( git describe --tags --abbrev=0 ) = $( git describe --tags ) ]] ; then
        vamp_version="$( git describe --tags )"
      else
        if [[ "$VAMP_GIT_BRANCH" != "" && "$VAMP_GIT_BRANCH" != "master" ]]; then
          vamp_version=$VAMP_GIT_BRANCH
        else
          vamp_version="katana--"
        fi
      fi

      exited_containers=$(docker ps -a -f status=exited -q)
      dead_containers=$(docker ps -a -f status=dead -q)
      test -n "${exited_containers}" -o -n "${dead_containers}" && docker rm ${exited_containers} ${dead_containers}

      remote_images=$(docker image ls -f reference="magneticio/vamp*:${vamp_version}*" --format '{{.Repository}}:{{.Tag}}')
      local_images=$(docker image ls -f reference="vamp*:${vamp_version}*" --format '{{.Repository}}:{{.Tag}}')
      test -n "${remote_images}" -o -n "${local_images}" && docker rmi -f ${remote_images} ${local_images}

      dangling_images=$(docker image ls -f dangling=true -q)
      test -n "${dangling_images}" && docker rmi -f ${dangling_images}

      docker volume rm packer 2>/dev/null
      dangling_volumes=$(docker volume ls -f dangling=true -q | grep -vEe '^packer')
      test -n "${dangling_volumes}" && docker volume rm ${dangling_volumes}

      exit 0
      '''
    }
  }
}
