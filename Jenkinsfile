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
                    command:
                    - sleep
                    args:
                    - 99d
                    tty: true
                  - name: kaniko
                    image: gcr.io/kaniko-project/executor:debug
                    imagePullPolicy: Always
                    command:
                    - sleep
                    args:
                    - 99d
                    tty: true
                    volumeMounts:
                    - name: docker-config
                      mountPath: /kaniko/.docker
                  - name: helm
                    image: alpine/helm:3.12.0
                    command:
                    - sleep
                    args:
                    - 99d
                    tty: true
                  - name: kubectl
                    image: bitnami/kubectl:latest
                    command:
                    - sleep
                    args:
                    - 99d
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
        // Application settings
        APP_NAME = 'flask-cicd-demo'
        APP_VERSION = "${BUILD_NUMBER}"
        DOCKER_HUB_REPO = 'elfkid'  // Replace with your Docker Hub username
        IMAGE_TAG = "${DOCKER_HUB_REPO}/${APP_NAME}:${APP_VERSION}"
        IMAGE_LATEST = "${DOCKER_HUB_REPO}/${APP_NAME}:latest"

        // Kubernetes settings
        K8S_NAMESPACE = 'default'
        HELM_RELEASE_NAME = 'flask-app'

        // SonarQube settings (configure as needed)
        SONARQUBE_SERVER = 'sonarqube'
        SONAR_PROJECT_KEY = 'flask-cicd-demo'

        // Notification settings
        SLACK_CHANNEL = '#devops'  // Configure your Slack channel
        EMAIL_RECIPIENTS = 'devops@company.com'  // Configure email recipients
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
        ansiColor('xterm')
    }

    triggers {
        // Trigger on push to main branch or pull requests
        pollSCM('H/5 * * * *')  // Poll every 5 minutes
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    env.BUILD_DATE = sh(
                        script: 'date -u +"%Y-%m-%dT%H:%M:%SZ"',
                        returnStdout: true
                    ).trim()
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

                // Archive test results
                publishTestResults testResultsPattern: 'test-results.xml'

                // Archive coverage reports
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
                        // Install SonarQube scanner
                        sh '''
                            pip install sonar-scanner

                            # Create sonar-project.properties if it doesn't exist
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

                        // Run SonarQube analysis
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

                        echo "Docker image built and pushed successfully!"
                        echo "Image: ${IMAGE_TAG}"
                    '''
                }
            }
        }

        stage('Helm Chart Lint') {
            steps {
                container('helm') {
                    sh '''
                        echo "Linting Helm chart..."
                        helm lint helm/flask-app

                        echo "Validating Helm templates..."
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
                        echo "Deploying application to Kubernetes..."

                        # Update Helm dependencies (if any)
                        helm dependency update helm/flask-app

                        # Deploy with Helm
                        helm upgrade --install ${HELM_RELEASE_NAME} helm/flask-app \\
                            --namespace ${K8S_NAMESPACE} \\
                            --create-namespace \\
                            --set image.repository=${DOCKER_HUB_REPO}/${APP_NAME} \\
                            --set image.tag=${APP_VERSION} \\
                            --set appVersion=${APP_VERSION} \\
                            --set fullnameOverride=${APP_NAME} \\
                            --wait --timeout=5m

                        echo "Deployment completed successfully!"

                        # Display deployment status
                        helm status ${HELM_RELEASE_NAME} -n ${K8S_NAMESPACE}
                    '''
                }
            }
        }

        stage('Application Verification') {
            when {
                anyOf {
                    branch 'main'
                    branch 'task_6'
                }
            }
            steps {
                container('kubectl') {
                    sh '''
                        echo "Waiting for application to be ready..."
                        kubectl wait --for=condition=ready pod -l app=${APP_NAME} -n ${K8S_NAMESPACE} --timeout=300s

                        echo "Getting service information..."
                        kubectl get services -n ${K8S_NAMESPACE} -l app=${APP_NAME}

                        # Get the service URL (for Minikube)
                        SERVICE_URL=$(kubectl get service ${APP_NAME} -n ${K8S_NAMESPACE} -o jsonpath='{.spec.clusterIP}:{.spec.ports[0].port}')
                        echo "Service URL: http://${SERVICE_URL}"

                        # Verification tests
                        echo "Running application verification tests..."

                        # Test 1: Health check
                        echo "Testing health endpoint..."
                        kubectl run curl-test --image=curlimages/curl --rm -i --restart=Never -- \\
                            curl -f http://${SERVICE_URL}/health

                        # Test 2: Main page
                        echo "Testing main page..."
                        kubectl run curl-test --image=curlimages/curl --rm -i --restart=Never -- \\
                            curl -f -s http://${SERVICE_URL}/ | grep -q "Flask CI/CD Pipeline Demo"

                        # Test 3: API endpoints
                        echo "Testing API endpoints..."
                        kubectl run curl-test --image=curlimages/curl --rm -i --restart=Never -- \\
                            curl -f http://${SERVICE_URL}/api/status

                        kubectl run curl-test --image=curlimages/curl --rm -i --restart=Never -- \\
                            curl -f http://${SERVICE_URL}/api/info

                        echo "All verification tests passed!"
                    '''
                }
            }
        }

        stage('Smoke Tests') {
            when {
                anyOf {
                    branch 'main'
                    branch 'task_6'
                }
            }
            steps {
                container('python') {
                    sh '''
                        echo "Running smoke tests..."

                        # Install requests library for smoke tests
                        pip install requests

                        # Get service URL
                        SERVICE_IP=$(kubectl get service ${APP_NAME} -n ${K8S_NAMESPACE} -o jsonpath='{.spec.clusterIP}')
                        SERVICE_PORT=$(kubectl get service ${APP_NAME} -n ${K8S_NAMESPACE} -o jsonpath='{.spec.ports[0].port}')
                        BASE_URL="http://${SERVICE_IP}:${SERVICE_PORT}"

                        # Create and run smoke test script
                        cat > smoke_test.py << 'EOF'
import requests
import sys
import os
import time

def test_endpoint(url, expected_status=200, check_content=None):
    """Test an endpoint and return True if successful"""
    try:
        response = requests.get(url, timeout=10)
        print(f"Testing {url} - Status: {response.status_code}")

        if response.status_code != expected_status:
            print(f"ERROR: Expected {expected_status}, got {response.status_code}")
            return False

        if check_content and check_content not in response.text:
            print(f"ERROR: Expected content '{check_content}' not found")
            return False

        print(f"✓ {url} - SUCCESS")
        return True
    except Exception as e:
        print(f"ERROR: {url} - {str(e)}")
        return False

def main():
    base_url = os.environ.get('BASE_URL', 'http://localhost:5000')
    print(f"Running smoke tests against: {base_url}")

    tests = [
        (f"{base_url}/health", 200, "healthy"),
        (f"{base_url}/api/status", 200, "running"),
        (f"{base_url}/api/info", 200, "Flask CI/CD Demo"),
        (f"{base_url}/", 200, "Flask CI/CD Pipeline Demo"),
    ]

    results = []
    for url, status, content in tests:
        time.sleep(1)  # Brief pause between requests
        results.append(test_endpoint(url, status, content))

    if all(results):
        print("\\n🎉 All smoke tests passed!")
        return 0
    else:
        print("\\n❌ Some smoke tests failed!")
        return 1

if __name__ == "__main__":
    sys.exit(main())
EOF

                        BASE_URL="http://${SERVICE_IP}:${SERVICE_PORT}" python smoke_test.py
                    '''
                }
            }
        }
    }

    post {
        always {
            // Archive artifacts
            archiveArtifacts artifacts: 'test-results.xml,coverage.xml,sonar-project.properties',
                           allowEmptyArchive: true

            // Clean up workspace
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
*Status:* FAILED ❌

Please check the build logs for details.
Build URL: ${env.BUILD_URL}
"""

                // Send Slack notification (requires Slack plugin)
                try {
                    slackSend(
                        channel: env.SLACK_CHANNEL,
                        color: 'danger',
                        message: message
                    )
                } catch (Exception e) {
                    echo "Slack notification failed: ${e.getMessage()}"
                }

                // Send email notification (requires Email Extension plugin)
                try {
                    emailext(
                        subject: "❌ Pipeline Failed: ${env.JOB_NAME} - Build ${env.BUILD_NUMBER}",
                        body: message,
                        to: env.EMAIL_RECIPIENTS
                    )
                } catch (Exception e) {
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

Some tests may have failed or quality gates not met.
Build URL: ${env.BUILD_URL}
"""

                try {
                    slackSend(
                        channel: env.SLACK_CHANNEL,
                        color: 'warning',
                        message: message
                    )
                } catch (Exception e) {
                    echo "Slack notification failed: ${e.getMessage()}"
                }
            }
        }
    }
}durationString}
*Status:* SUCCESS ✅

Application deployed successfully to Kubernetes!
"""

                // Send Slack notification (requires Slack plugin)
                try {
                    slackSend(
                        channel: env.SLACK_CHANNEL,
                        color: 'good',
                        message: message
                    )
                } catch (Exception e) {
                    echo "Slack notification failed: ${e.getMessage()}"
                }

                // Send email notification (requires Email Extension plugin)
                try {
                    emailext(
                        subject: "✅ Pipeline Success: ${env.JOB_NAME} - Build ${env.BUILD_NUMBER}",
                        body: message,
                        to: env.EMAIL_RECIPIENTS
                    )
                } catch (Exception e) {
                    echo "Email notification failed: ${e.getMessage()}"
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
*Duration:* ${currentBuild.