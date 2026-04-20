pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO = 'medical-chatbot'
        IMAGE_TAG = 'latest'
        SERVICE_NAME = 'llmops-medical-service'
    }

    stages {
        stage('Clone GitHub Repo') {
            steps {
                script {
                    echo 'Cloning GitHub repo to Jenkins...'
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-token', url: 'https://github.com/husnainasim/Medical-Chatbot.git']])
                }
            }
        }

        // stage('Build, Scan, and Push Docker Image to ECR') {
        //     steps {
        //         withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-token']]) {
        //             script {
        //                 def accountId = sh(script: "aws sts get-caller-identity --query Account --output text", returnStdout: true).trim()
        //                 def ecrUrl = "${accountId}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO}"
        //                 def imageFullTag = "${ecrUrl}:${IMAGE_TAG}"

        //                 sh """
        //                 set -e
                        
        //                 echo 'Logging into ECR...'
        //                 aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ecrUrl}
                        
        //                 echo 'Building Docker image...'
        //                 docker build -t ${env.ECR_REPO}:${IMAGE_TAG} .
                        
        //                 echo 'Tagging image...'
        //                 docker tag ${env.ECR_REPO}:${IMAGE_TAG} ${imageFullTag}
                        
        //                 echo 'Pushing to ECR...'
        //                 docker push ${imageFullTag}
                        
        //                 echo 'Running Trivy scan (vulnerability only, faster)...'
        //                 trivy image --scanners vuln --severity HIGH,CRITICAL --format json \
        //                     --timeout 5m -o trivy-report.json ${imageFullTag} || true
        //                 """

        //                 archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
        //             }
        //         }
        //     }
        // }

          stage('Build, Scan, and Push Docker Image to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-token']]) {
                    script {
                        def accountId = sh(script: "aws sts get-caller-identity --query Account --output text", returnStdout: true).trim()
                        def ecrUrl = "${accountId}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO}"
                        def imageFullTag = "${ecrUrl}:${IMAGE_TAG}"

                        sh """
                        set -e
                        
                        echo 'Logging into ECR...'
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ecrUrl}
                        
                        echo 'Building Docker image (timeout: 30 minutes)...'
                        timeout 1800 docker build \
                            --build-arg PIP_DEFAULT_TIMEOUT=300 \
                            --build-arg PIP_RETRIES=10 \
                            -t ${env.ECR_REPO}:${IMAGE_TAG} . || \
                        (echo "Build failed, retrying..." && \
                        timeout 1800 docker build \
                            --build-arg PIP_DEFAULT_TIMEOUT=300 \
                            --build-arg PIP_RETRIES=10 \
                            --no-cache \
                            -t ${env.ECR_REPO}:${IMAGE_TAG} .)
                        
                        echo 'Tagging image...'
                        docker tag ${env.ECR_REPO}:${IMAGE_TAG} ${imageFullTag}
                        
                        echo 'Pushing to ECR...'
                        docker push ${imageFullTag}
                        
                        echo 'Running Trivy scan...'
                        trivy image --scanners vuln --severity HIGH,CRITICAL --format json \
                            --timeout 5m -o trivy-report.json ${imageFullTag} || true
                        """

                        archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
                    }
                }
            }
        }
   
    

        //  stage('Deploy to AWS App Runner') {
        //     steps {
        //         withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-token']]) {
        //             script {
        //                 def accountId = sh(script: "aws sts get-caller-identity --query Account --output text", returnStdout: true).trim()
        //                 def ecrUrl = "${accountId}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO}"
        //                 def imageFullTag = "${ecrUrl}:${IMAGE_TAG}"

        //                 echo "Triggering deployment to AWS App Runner..."

        //                 sh """
        //                 SERVICE_ARN=\$(aws apprunner list-services --query "ServiceSummaryList[?ServiceName=='${SERVICE_NAME}'].ServiceArn" --output text --region ${AWS_REGION})
        //                 echo "Found App Runner Service ARN: \$SERVICE_ARN"

        //                 aws apprunner start-deployment --service-arn \$SERVICE_ARN --region ${AWS_REGION}
        //                 """
        //             }
        //         }
        //     }
        // }

    }
}