pipeline {
  agent any

  parameters {
    choice(
      name: 'ACTION',
      choices: ['create', 'destroy'],
      description: 'Choose whether to create or destroy the ECS infrastructure.'
    )
  }

  environment {
    AWS_REGION = 'ap-south-1'
    APP_NAME   = 'ecs-ci-cd-app'
    IMAGE_TAG  = "${BUILD_NUMBER}"
    ECR_REPO   = '977076879209.dkr.ecr.ap-south-1.amazonaws.com/ecs-app-repo'
  }

  stages {

    stage('📥 Clone GitHub Repo') {
      steps {
        git url: 'https://github.com/nenavathsrinu/devops-cicd-ecs.git', branch: 'main'
      }
    }

    stage('🐳 Build & Push Docker Image to ECR') {
      when {
        expression { return params.ACTION == 'create' }
      }
      steps {
        dir('app') {
          sh """
            echo "🔐 Logging in to ECR..."
            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO

            echo "🔨 Building Docker image..."
            docker build -t $APP_NAME:$IMAGE_TAG .

            echo "📦 Tagging and pushing Docker image to ECR..."
            docker tag $APP_NAME:$IMAGE_TAG $ECR_REPO:$IMAGE_TAG
            docker push $ECR_REPO:$IMAGE_TAG
          """
        }
      }
    }

    stage('🛠️ Terraform Create/Destroy ECS Infra') {
      steps {
        dir('terraform') {
          withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-credentials'
          ]]) {
            script {
              if (params.ACTION == 'destroy') {
                sh """
                  echo "⚠️ Destroying ECS Infrastructure..."
                  terraform init
                  terraform destroy -auto-approve
                """
              } else {
                sh """
                  echo "🚀 Creating/Updating ECS Infrastructure..."
                  terraform init
                  terraform apply -auto-approve -var="image_url=$ECR_REPO:$IMAGE_TAG"
                """
              }
            }
          }
        }
      }
    }

    stage('🔁 Force ECS Service Update') {
      when {
        expression { return params.ACTION == 'create' }
      }
      steps {
        sh """
          echo "🔄 Updating ECS service with new image..."
          aws ecs update-service \
            --cluster ${APP_NAME}-cluster \
            --service ${APP_NAME}-service \
            --force-new-deployment \
            --region $AWS_REGION
        """
      }
    }
  }

  post {
    success {
      echo "✅ CI/CD pipeline (${params.ACTION.toUpperCase()}) completed successfully!"
    }
    failure {
      echo "❌ Pipeline failed during ${params.ACTION.toUpperCase()} operation. Check logs!"
    }
  }
}