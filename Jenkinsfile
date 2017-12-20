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
        parallel (
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
          }
        )
      }
    }
    stage('Deploy services') {
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
  }
}
