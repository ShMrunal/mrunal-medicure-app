pipeline {
    agent any
    
    parameters{

        choice(name: 'action', choices: 'create\ndelete', description: 'Choose create/Destroy')
        
    }

    stages {
        stage('Checkout git') {
            steps {
              git 'https://github.com/ShMrunal/mrunal-medicure-app.git'
            }
        }
        
        stage ('Build & JUnit Test') {
            steps {
                sh 'mvn clean package' 
            }
        }
        
        stage("Build Docker Image") {
            steps {
                echo "Building the image"
                catchError(buildResult: 'UNSTABLE') {
                    sh "docker build -t ${env.dockerHubUser}/medicure-app ."
                }
            }
        }
        
        stage("Push To Docker Hub") {
            steps {
                echo "pushing to docker hub"
                withCredentials([usernamePassword(credentialsId:"dockerHub",passwordVariable:"dockerHubPass",usernameVariable:"dockerHubUser")]){
                sh "docker tag medicure-app ${env.dockerHubUser}/medicure-app:latest"
                sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPass}"
                sh "docker push ${env.dockerHubUser}/medicure-app:latest"
                }
            }
        }
        stage('Create EKS Cluster : Terraform'){
        
            //when { expression {  params.action == 'create' } }
            steps{
                script{

                    dir('eks_module') {
                       withCredentials([usernamePassword(credentialsId:"awsCredentials",passwordVariable:"SECRET_KEY",usernameVariable:"ACCESS_KEY")]){
                           sh """
                          
                          terraform init 
                          terraform plan -var 'access_key=${env.ACCESS_KEY}' -var 'secret_key=${env.SECRET_KEY}'  --var-file=./config/terraform.tfvars
                          terraform apply -var 'access_key=${env.ACCESS_KEY}' -var 'secret_key=${env.SECRET_KEY}'  --var-file=./config/terraform.tfvars --auto-approve
                          """
                        }    
                      
                    }
                }
            }
        }
        
        stage('Connect to EKS '){
        
            //when { expression {  params.action == 'create' } }
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId:"awsCredentials",passwordVariable:"SECRET_KEY",usernameVariable:"ACCESS_KEY")]){
                        sh """
                        aws configure set aws_access_key_id "${env.ACCESS_KEY}"
                        aws configure set aws_secret_access_key "${env.SECRET_KEY}"
                        aws configure set region ap-south-1
                        aws eks --region ap-south-1 update-kubeconfig --name EKS-cluster
                        """
                    }
                }
            }
        }
        
        stage('Deployment on test-EKS Cluster'){
            when { expression {  params.action == 'create' } }
            steps{
                script{
                  
                  def apply = false

                  try{
                    input message: 'please confirm to deploy on test-eks cluster', ok: 'Ready to apply the config ?'
                    apply = true
                  }catch(err){
                    apply= false
                    currentBuild.result  = 'UNSTABLE'
                  }
                  if(apply){

                    sh """
                      kubectl apply -f test-cluster-deployment.yaml
                    """
                  }
                }
            }
        } 
        
        
        stage ("wait_for_application to come up"){
            steps {
              sh 'sleep 40'
            }
        }
        
        stage('Selenium test cases') {
            steps {
              sh 'java -jar Selenium.jar'
            }
        }

        stage('publish reports'){
            steps {
            
                publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, includes: 'screenshot.png', keepAll: false, reportDir: '/var/lib/jenkins/workspace/medicure-pipeline', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: '', useWrapperFileDirectly: true])
            }
        }
        
        stage('Deployment on Prod-EKS Cluster'){
            when { expression {  params.action == 'create' } }
            steps{
                script{
                  
                  def apply = false

                  try{
                    input message: 'please confirm to deploy on prod-eks-cluster', ok: 'Ready to apply the config ?'
                    apply = true
                  }catch(err){
                    apply= false
                    currentBuild.result  = 'UNSTABLE'
                  }
                  if(apply){

                    sh """
                      kubectl apply -f prod-cluster-deployment.yaml
                    """
                  }
                }
            }
        } 

    }
}
