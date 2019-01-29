pipeline {
    agent any
    environment {
      ORG               = 'jenkins-x'
      DOCKER_ORG        = 'jenkinsxio'
      APP_NAME          = 'jenkins-x-serverless'
      GIT_PROVIDER      = 'github.com'
      GKE_SA            = credentials('gke-sa')
    }
    stages {
      stage('CI Build and push snapshot') {
        when {
          branch 'PR-*'
        }
        environment {
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME-$BUILD_NUMBER".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          checkout scm
          sh 'export VERSION=$PREVIEW_VERSION'
          sh './jx-docker-build.sh $PREVIEW_VERSION $DOCKER_ORG pr'

          sh "gcloud auth activate-service-account --key-file $GKE_SA"
          sh "gcloud container clusters get-credentials anthorse --zone europe-west1-b --project jenkinsx-dev"

          dir('jenkins-x-serverless') {
            sh 'sed -i.bak -e "s/tag: .*/tag: ${PREVIEW_VERSION}/" values.yaml'
            sh 'rm values.yaml.bak'
            sh 'cat values.yaml'
          }

          sh 'jx/scripts/test.sh'
        }
      }
      stage('Build Release') {
        when {
          branch 'master'
        }
        steps {
          git 'https://github.com/jenkins-x/jenkins-x-serverless.git'
          sh "git config --global credential.helper store"
          sh "jx step validate --min-jx-version 1.1.73"
          sh "jx step git credentials"
          sh "echo \$(jx-release-version) > VERSION"
          sh 'export VERSION=`cat VERSION`'
          sh "jx step validate --min-jx-version 1.2.36"
          sh './jx-docker-build.sh `cat VERSION` $DOCKER_ORG release'
        }
      }
    }
  }
