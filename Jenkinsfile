pipeline {
    agent any

    environment {
        GOOGLE_CLOUD_PROJECT = "project-73bd9651-4490-4776-91a"
        IMAGE_NAME = "hello"
        IMAGE_TAG = "1.0.${BUILD_NUMBER}"
        GITHUB_TOKEN = credentials('github-token')
        SCANNER_HOME = tool 'sonarqube'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Git Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/E-commerce-com/flipkart-project.git'
            }
        }

        stage('Authenticate with Google Cloud') {
            steps {
                sh '''
                    echo "Checking GCP authentication"

                    gcloud auth list

                    gcloud config set project ${GOOGLE_CLOUD_PROJECT}

                    gcloud auth configure-docker asia-south1-docker.pkg.dev --quiet
                '''
            }
        }

        stage('Scan Filesystem using Trivy') {
            steps {
                sh '''
                    trivy fs .
                '''
            }
        }


        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {

                    sh '''
                    ${SCANNER_HOME}/bin/sonar-scanner \
                    -Dsonar.projectName=app \
                    -Dsonar.projectKey=app
                    '''

                }
            }
        }


        stage('Quality Gate') {
            steps {
                script {

                    waitForQualityGate(
                        abortPipeline: false,
                        credentialsId: 'Sonar-token'
                    )

                }
            }
        }


        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                    -t ${IMAGE_NAME}:latest .
                '''
            }
        }


        stage('Push Image to Artifact Registry') {

            steps {

                sh '''

                IMAGE_PATH=asia-south1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/docker-repo/${IMAGE_NAME}

                docker tag ${IMAGE_NAME}:latest \
                ${IMAGE_PATH}:${IMAGE_TAG}


                docker push \
                ${IMAGE_PATH}:${IMAGE_TAG}



                docker tag ${IMAGE_NAME}:latest \
                ${IMAGE_PATH}:latest


                docker push \
                ${IMAGE_PATH}:latest


                docker rmi ${IMAGE_PATH}:${IMAGE_TAG} || true

                docker rmi ${IMAGE_NAME}:latest || true


                '''

            }
        }


        stage('Scan Docker Image') {

            steps {

                sh '''

                trivy image \
                asia-south1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/docker-repo/${IMAGE_NAME}:${IMAGE_TAG}

                '''

            }
        }



        stage('Checkout Helm Repository') {

            steps {

                cleanWs()

                git branch: 'main',
                credentialsId: 'github-token',
                url: 'https://github.com/E-commerce-com/helm-chart.git'

            }

        }



        stage('Update Helm Image Tag') {

            steps {

                sh '''

                git config user.email "bandirakesh.info2026@gmail.com"

                git config user.name "Rakeshbandi9596"


                echo "Before update"

                cat helm/values.yaml



                sed -i \
                "s|image:.*|image: asia-south1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/docker-repo/${IMAGE_NAME}:${IMAGE_TAG}|" \
                helm/values.yaml



                echo "After update"

                cat helm/values.yaml



                git add helm/values.yaml


                if git diff --cached --quiet

                then

                    echo "No changes"

                else

                    git commit \
                    -m "Updated image tag ${IMAGE_TAG}"


                    git push \
                    https://${GITHUB_TOKEN}@github.com/E-commerce-com/helm-chart.git \
                    HEAD:main

                fi


                '''

            }

        }



        stage('Deployment Update Complete') {

            steps {

                echo "Docker image updated successfully for CD"

            }

        }

    }
}
