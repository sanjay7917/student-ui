pipeline {
    agent any
    tools {
        maven 'Maven'
    }
    // parameters { 
    //     choice(name: 'EKS_AWS_REGION', description: 'Provide AWS Region', choices: ['us-east-1', 'us-east-2', 'us-west-2', 'ap-east-1', 'ap-south-1', 'ap-northeast-2', 'ap-southeast-1', 'ap-southeast-2', 'ap-northeast-1', 'ca-central-1', 'eu-central-1', 'eu-west-1', 'eu-west-2', 'eu-west-3', 'eu-north-1', 'me-south-1', 'sa-east-1'])
    //     string(name: "EKS_CLUSTER_NAME", defaultValue: "", description: "Provide The Name Of Cluster")
    //     choice(name: 'EKS_NODE_TYPE', description: 'Provide Node Type', choices: ['t2.medium', 't2.micro', 't2.small'])
    //     choice(name: 'EKS_NODE_COUNT', description: 'Provide The Node Count', choices: ['1', '2', '3'])
    // }
    // environment {
    //     AWS_ACCOUNT_ID="385685296160"
    //     AWS_DEFAULT_REGION="us-east-2"
    //     IMAGE_REPO_NAME="aws_k8s_image"
    //     IMAGE_TAG="Version_1"
    //     REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    // }
    stages {
        // stage('code-pulling') {
        //     steps {
        //         git credentialsId: 'ubuntu', url: 'https://github.com/sanjay7917/student-ui.git'
        //     }
        // }
        stage("build-maven"){
            steps{
                sh 'mvn clean package' 
            }    
        }
        // stage("build-docker-image"){
        //     steps{
        //         script {  
        //             sh 'docker build -t ${IMAGE_REPO_NAME} .'
        //         }
        //     }    
        // }
        // stage("push-docker-image-to-ecr"){
        //     steps{
        //         script {
        //             sh "docker tag ${IMAGE_REPO_NAME} ${REPOSITORY_URI}:${IMAGE_TAG}"
        //             withCredentials([string(credentialsId: 'dockpass', variable: 'dockpass')]) {
        //                 sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
        //             }
        //             sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
        //         }
        //     }
        // }
        stage ('cluster-create'){
            agent {
                docker {
                    // image '${REPOSITORY_URI}:${IMAGE_TAG}'
                    image 'ubuntu'
                    reuseNode true
                }
            }
            steps {
                withAWS(credentials: 'aws', region: 'us-east-2') {
                    script {
                        sh '''
                        apt update -y
                        apt install unzip -y && apt install curl -y
                        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                        unzip awscliv2.zip
                        ./aws/install
                        aws s3 mb s3://buck12312344 --region us-east-2
                        '''
                        // sh 'eksctl create cluster --name ${EKS_CLUSTER_NAME} --region ${EKS_AWS_REGION} --node-type ${EKS_NODE_TYPE} --nodes ${EKS_NODE_COUNT}'
                        // sh 'eksctl delete cluster <Cluster_Name>' //Uncomment This For Deleting Cluster And Comment Above Command
                    }   
                }
            }
        }
    }
}
