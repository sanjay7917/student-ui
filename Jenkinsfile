pipeline {
    agent any
    tools {
        maven 'Maven'
    }
    parameters { 
        choice(name: 'EKS_AWS_REGION', description: 'Provide AWS Region', choices: ['us-east-1', 'us-east-2'])
        string(name: "EKS_CLUSTER_NAME", defaultValue: "", description: "Provide The Name Of Cluster")
        choice(name: 'EKS_NODE_TYPE', description: 'Provide Node Type', choices: ['t2.medium', 't2.micro'])
        choice(name: 'EKS_NODE_COUNT', description: 'Provide The Node Count', choices: ['1', '2'])
    }
    environment {
        AWS_ACCOUNT_ID="385685296160"
        AWS_DEFAULT_REGION="us-east-2"
        IMAGE_REPO_NAME="aws_k8s_image"
        IMAGE_TAG="Version_1"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }
    stages {
        // IF WE USE PIPELINE SCRIPE FROM SCM THEN WE DONT HAVE TO PULL CODE
        stage("build-maven"){
            steps{
                sh 'mvn clean package' 
            }    
        }
        stage("build-docker-image"){
            steps{
                script {  
                    sh 'docker build -t ${IMAGE_REPO_NAME} .'
                }
            }    
        }
        stage("push-docker-image-to-ecr"){
            steps{
                script {
                    sh "docker tag ${IMAGE_REPO_NAME} ${REPOSITORY_URI}:${IMAGE_TAG}"
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                }
            }
        }
        stage ('cluster-create'){
            agent {
                docker {
                    image '385685296160.dkr.ecr.us-east-2.amazonaws.com/aws_k8s_image:Version_1' // We Cant Use Variable For Image Name
                    reuseNode true
                }
            }
            steps {
                withAWS(credentials: 'aws', region: 'us-east-2') {
                    script {
                        // sh 'eksctl create cluster --name ${EKS_CLUSTER_NAME} --region ${EKS_AWS_REGION} --node-type ${EKS_NODE_TYPE} --nodes ${EKS_NODE_COUNT}'
                        sh 'eksctl delete cluster ${EKS_CLUSTER_NAME}' //Uncomment This For Deleting Cluster And Comment Above Command
                    }   
                }
            }
        }
    }
}
