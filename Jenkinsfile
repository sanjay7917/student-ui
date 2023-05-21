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
        stage('code-pulling') {
            steps {
                slackSend channel: 'prod', message: 'Job Started'
                git branch: 'main', credentialsId: 'ubuntu', url: 'https://github.com/sanjay7917/springboot-app.git'
                slackSend channel: 'prod', message: 'Code Pulled Successfully'
            }
        }
        stage("build-maven"){
            steps{
                slackSend channel: 'prod', message: 'Building Artifact'
                sh 'mvn clean package'
                slackSend channel: 'prod', message: 'Artifact Build Successfully'
            }    
        }
        stage('sonarqube-integration'){
            steps{
                withSonarQubeEnv('sonarqube-9.9') { 
                    sh "mvn sonar:sonar"
                }
                slackSend channel: 'prod', message: 'Code Quality Check Report Transfered On SonarQube Server'
            }
        }
        stage('artifact-to-s3') {
            steps {
                slackSend channel: 'prod', message: 'Sending Artifact On AWS S3 Bucket'
                withAWS(credentials: 'aws', region: 'us-east-2') {
                    sh'''
                    sudo apt update -y
                    sudo apt install awscli -y
                    aws s3 ls
                    aws s3 mb s3://buck12312344 --region us-east-2
                    sudo mv /var/lib/jenkins/workspace/test/target/studentapp-2.2-SNAPSHOT.war /tmp/studentapp-2.2-SNAPSHOT${BUILD_ID}.war
                    aws s3 cp /tmp/studentapp-2.2-SNAPSHOT${BUILD_ID}.war  s3://buck12312344/
                    sudo rm -rvf /tmp/studentapp-2.2-SNAPSHOT${BUILD_ID}.war
                    '''
                }
                slackSend channel: 'prod', message: 'Artifact Stored On AWS S3 Bucket'
            }     
        }
        stage("pull-artifact"){
            steps{
                slackSend channel: 'prod', message: 'Pulling Artifact From AWS S3 Bucket'
                withAWS(credentials: 'aws', region: 'us-east-2') {
                    script {
                        sh 'aws s3 cp s3://buck12312344/studentapp-2.2-SNAPSHOT${BUILD_ID}.war .'
                        sh 'mv studentapp-2.2-SNAPSHOT${BUILD_ID}.war student.war'
                    }
                }
                slackSend channel: 'prod', message: 'Artifact Pulled Successfully'
            }    
        }
        stage("build-docker-image"){
            steps{
                slackSend channel: 'prod', message: 'Building Docker Image From Dockerfile'
                withAWS(credentials: 'aws', region: 'us-east-2') {
                    script {
                        sh 'docker build -t ${IMAGE_REPO_NAME} .'
                    }
                }
                slackSend channel: 'prod', message: 'Docker Image Build Successfully'
            }    
        }
        stage("push-docker-image-to-ecr"){
            steps{
                slackSend channel: 'prod', message: 'Sending Docker Image To AWS ECR'
                script {
                    sh "docker tag ${IMAGE_REPO_NAME} ${REPOSITORY_URI}:${IMAGE_TAG}"
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                }
                slackSend channel: 'prod', message: 'Docker Image Pushed On AWS ECR'
            }
        }
        stage('send-k8s-manifest') {
            steps {
                slackSend channel: 'prod', message: 'Sending K8S Deployment Manifest To EKS Cluster Server'
                sshagent(['ubuntu']) {
                    sh "scp -o StrictHostKeyChecking=no deploysvc.yml ubuntu@18.218.137.135:/home/ubuntu"
                }
                slackSend channel: 'prod', message: 'K8S Deployment Manifest Transfered Successfully'
            }
        }
        stage('k8s-cluster-creation-and-deploy') {
            steps {
                slackSend channel: 'prod', message: 'Creating AWS EKS Cluster, Nodegroup and Deploying K8S Manifest On Slave Nodes'
                withCredentials([sshUserPrivateKey(credentialsId: 'ubuntu', keyFileVariable: 'id_rsa', usernameVariable: 'eks')]) {
                    sh'''
                    sudo ssh -i ${id_rsa} -T -o StrictHostKeyChecking=no ubuntu@18.218.137.135<<EOF
                    pwd
                    ls
                    kubectl version --short --client
                    eksctl create cluster --name=eksdemo1 \
                                        --region=us-east-2 \
                                        --zones=us-east-2a,us-east-2b \
                                        --without-nodegroup
                    eksctl utils associate-iam-oidc-provider \
                        --region us-east-2 \
                        --cluster eksdemo1 \
                        --approve
                    eksctl create nodegroup --cluster=eksdemo1 \
                                        --region=us-east-2 \
                                        --name=eksdemo1-ng-public1 \
                                        --node-type=t3.medium \
                                        --nodes=2 \
                                        --nodes-min=2 \
                                        --nodes-max=4 \
                                        --node-volume-size=20 \
                                        --ssh-access \
                                        --ssh-public-key=kube-demo \
                                        --managed \
                                        --asg-access \
                                        --external-dns-access \
                                        --full-ecr-access \
                                        --appmesh-access \
                                        --alb-ingress-access
                    eksctl get cluster
                    kubectl get nodes -o wide
                    kubectl apply -f deploysvc.yml
                    '''
                }
                slackSend channel: 'prod', message: 'Cluster And Nodegroup Created Successfully, And Spring Boot Application Deployed On K8S Cluster'
            }
        }
    }
    post{
        always{
            echo "Production Enviroment EKS Spring Boot Application Deployment Pipeline"
        }
        success{
            slackSend channel: 'prod', message: 'Pipeline Executed Successfully'
        }
        failure{
            slackSend channel: 'prod', message: 'Pipeline Failed to Execute'
        }
    }
}
