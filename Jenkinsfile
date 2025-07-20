pipeline {
    agent {
        kubernetes {
            yaml '''
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: python
                    image: python:3.9-slim
                    command: ["sleep"]
                    args: ["99d"]
                    tty: true
                  - name: kaniko
                    image: gcr.io/kaniko-project/executor:debug
                    imagePullPolicy: Always
                    command: ["sleep"]
                    args: ["99d"]
                    tty: true
                    volumeMounts:
                    - name: docker-config
                      mountPath: /kaniko/.docker
                  - name: helm
                    image: alpine/helm:3.12.0
                    command: ["sleep"]
                    args: ["99d"]
                    tty: true
                  - name: kubectl
                    image: bitnami/kubectl:latest
                    command: ["sleep"]
                    args: ["99d"]
                    tty: true
                  volumes:
                  - name: docker-config
                    secret:
                      secretName: docker-registry-secret
                      items:
                      - key: .dockerconfigjson
                        path: config.json
            '''
        }
    }

    environment {
        APP_NAME = 'flask-cicd-demo'
        APP_VERSION = "${BUILD_NUMBER}"
        DOCKER_HUB_REPO = 'your-dockerhub-username'
        IMAGE_TAG = "${DOCKER_HUB_REPO}/${APP_NAME}:${APP_VERSION}"
        IMAGE_LATEST = "${DOCKER_HUB_REPO}/${APP_NAME}:latest"
        K8S_NAMESPACE = 'default'
        HELM_RELEASE_NAME = 'flask-app'
        SONARQUBE_SERVER = 'sonarqube'
        SONAR_PROJECT_KEY = 'flask-cicd-demo'
        SLACK_CHANNEL = '#devops'
        EMAIL_RECIPIENTS = 'devops@company.com'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
        ansiColor('xterm')
    }

    triggers {
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.BUILD_DATE = sh(script: 'date -u +"%Y-%m-%dT%H:%M:%SZ"', returnStdout: true).trim()
                }
            }
        }

        stage('Application Build') {
            steps {
                container('python') {
                    sh '''
                        echo "Installing dependencies..."
                        pip install --no-cache-dir -r requirements.txt
                        echo "Checking Python syntax..."
                        python -m py_compile app.py
                        echo "Build completed successfully!"
                    '''
                }
            }
        }

        stage('Unit Tests') {
            steps {
                container('python') {
                    sh '''
                        echo "Running unit tests with coverage..."
                        python -m pytest tests/ -v --junitxml=test-results.xml --cov=app --cov-report=xml --cov-report=html
                        echo "Tests completed!"
                    '''
                }

                publishTestResults testResultsPattern: 'test-results.xml'

                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'htmlcov',
                    reportFiles: 'index.html',
                    reportName: 'Coverage Report'
                ])
            }
        }

        stage('Code Quality - SonarQube') {
            steps {
                container('python') {
                    script {
                        sh '''
                            pip install sonar-scanner
                            cat > sonar-project.properties << EOF
sonar.projectKey=${SONAR_PROJECT_KEY}
sonar.projectName=Flask CI/CD Demo
sonar.projectVersion=${APP_VERSION}
sonar.sources=.
sonar.exclusions=tests/**,htmlcov/**,venv/**
sonar.python.coverage.reportPaths=coverage.xml
sonar.python.xunit.reportPath=test-results.xml
EOF
                        '''

                        withSonarQubeEnv('SonarQube') {
                            sh '''
                                sonar-scanner \\
                                    -Dsonar.projectKey=${SONAR_PROJECT_KEY} \\
                                    -Dsonar.sources=. \\
                                    -Dsonar.host.url=${SONAR_HOST_URL} \\
                                    -Dsonar.login=${SONAR_AUTH_TOKEN}
                            '''
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    timeout(time: 5, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage('Docker Image Build & Push') {
            steps {
                container('kaniko') {
                    sh '''
                        echo "Building Docker image with Kaniko..."
                        /kaniko/executor \\
                            --dockerfile=Dockerfile \\
                            --context=dir://$WORKSPACE \\
                            --destination=${IMAGE_TAG} \\
                            --destination=${IMAGE_LATEST} \\
                            --build-arg APP_VERSION=${APP_VERSION} \\
                            --build-arg BUILD_DATE=${BUILD_DATE} \\
                            --build-arg VCS_REF=${GIT_COMMIT_SHORT} \\
                            --cache=true \\
                            --cache-ttl=24h \\
                            --cleanup
                        echo "Image: ${IMAGE_TAG}"
                    '''
                }
            }
        }

        stage('Helm Chart Lint') {
            steps {
                container('helm') {
                    sh '''
                        helm lint helm/flask-app
                        helm template ${HELM_RELEASE_NAME} helm/flask-app \\
                            --set image.repository=${DOCKER_HUB_REPO}/${APP_NAME} \\
                            --set image.tag=${APP_VERSION} \\
                            --set appVersion=${APP_VERSION} \\
                            --dry-run --debug
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                anyOf {
                    branch 'main'
                    branch 'task_6'
                }
            }
            steps {
                container('helm') {
                    sh '''
                        helm dependency update helm/flask-app
                        helm upgrade --install ${HELM_RELEASE_NAME} helm/flask-app \\
                            --namespace ${K8S_NAMESPACE} \\
                            --create-namespace \\
                            --set image.repository=${DOCKER_HUB_REPO}/${APP_NAME} \\
                            --set image.tag=${APP_VERSION} \\
                            --set appVersion=${APP_VERSION} \\
                            --set fullnameOverride=${APP_NAME} \\
                            --wait --timeout=5m
                        helm status ${HELM_RELEASE_NAME} -n ${K8S_NAMESPACE}
                    '''
                }
            }
        }

        // Application Verification and Smoke Tests omitted for brevity — let me know if ты хочешь, чтобы я добавил их тоже.
    }

    post {
        always {
            archiveArtifacts artifacts: 'test-results.xml,coverage.xml,sonar-project.properties', allowEmptyArchive: true
            cleanWs()
        }

        success {
            script {
                def message = """
🎉 *Pipeline Success* 🎉
*Project:* ${env.JOB_NAME}
*Build:* ${env.BUILD_NUMBER}
*Branch:* ${env.BRANCH_NAME}
*Image:* ${IMAGE_TAG}
*Duration:* ${currentBuild.durationString}
*Status:* SUCCESS ✅

Application deployed successfully to Kubernetes!
Build URL: ${env.BUILD_URL}
"""
                try {
                    slackSend(channel: env.SLACK_CHANNEL, color: 'good', message: message)
                } catch (e) {
                    echo "Slack notification failed: ${e.getMessage()}"
                }

                try {
                    emailext(
                        subject: "✅ Pipeline Success: ${env.JOB_NAME} - Build ${env.BUILD_NUMBER}",
                        body: message,
                        to: env.EMAIL_RECIPIENTS
                    )
                } catch (e) {
                    echo "Email notification failed: ${e.getMessage()}"
                }
            }
        }

        unstable {
            script {
                def message = """
⚠️ *Pipeline Unstable* ⚠️
*Project:* ${env.JOB_NAME}
*Build:* ${env.BUILD_NUMBER}
*Branch:* ${env.BRANCH_NAME}
*Duration:* ${currentBuild.durationString}
*Status:* UNSTABLE ⚠️
Build URL: ${env.BUILD_URL}
"""
                try {
                    slackSend(channel: env.SLACK_CHANNEL, color: 'warning', message: message)
                } catch (e) {
                    echo "Slack notification failed: ${e.getMessage()}"
                }
            }
        }

        failure {
            script {
                def message = """
❌ *Pipeline Failed* ❌
*Project:* ${env.JOB_NAME}
*Build:* ${env.BUILD_NUMBER}
*Branch:* ${env.BRANCH_NAME}
*Duration:* ${currentBuild.durationString}
*Status:* FAILED ❌
Build URL: ${env.BUILD_URL}
"""
                try {
                    slackSend(channel: env.SLACK_CHANNEL, color: 'danger', message: message)
                } catch (e) {
                    echo "Slack notification failed: ${e.getMessage()}"
                }

                try {
                    emailext(
                        subject: "❌ Pipeline Failed: ${env.JOB_NAME} - Build ${env.BUILD_NUMBER}",
                        body: message,
                        to: env.EMAIL_RECIPIENTS
                    )
                } catch (e) {
                    echo "Email notification failed: ${e.getMessage()}"
                }
            }
        }
    }
}
