#!/usr/bin/env python3
"""
Unit tests for Flask CI/CD Demo Application
"""

import pytest
import json
import os
import sys

# Add the parent directory to the path to import the app
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app

@pytest.fixture
def client():
    """Create a test client for the Flask application"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        with app.app_context():
            yield client

class TestFlaskApp:
    """Test class for Flask application endpoints"""

    def test_index_page(self, client):
        """Test the main index page"""
        response = client.get('/')
        assert response.status_code == 200
        assert b'Flask CI/CD Pipeline Demo' in response.data
        assert b'Application is running successfully!' in response.data

    def test_health_endpoint(self, client):
        """Test the health check endpoint"""
        response = client.get('/health')
        assert response.status_code == 200

        data = json.loads(response.data)
        assert data['status'] == 'healthy'
        assert 'timestamp' in data
        assert data['service'] == 'flask-cicd-demo'

    def test_api_status_endpoint(self, client):
        """Test the API status endpoint"""
        response = client.get('/api/status')
        assert response.status_code == 200

        data = json.loads(response.data)
        assert data['status'] == 'running'
        assert 'version' in data
        assert 'timestamp' in data
        assert 'environment' in data

    def test_api_info_endpoint(self, client):
        """Test the API info endpoint"""
        response = client.get('/api/info')
        assert response.status_code == 200

        data = json.loads(response.data)
        assert data['application'] == 'Flask CI/CD Demo'
        assert 'version' in data
        assert 'environment' in data
        assert 'host' in data
        assert 'port' in data
        assert 'timestamp' in data
        assert 'uptime' in data

    def test_404_error_handler(self, client):
        """Test 404 error handling"""
        response = client.get('/nonexistent-page')
        assert response.status_code == 404

        data = json.loads(response.data)
        assert data['error'] == 'Not Found'
        assert data['status_code'] == 404

    def test_health_endpoint_structure(self, client):
        """Test health endpoint returns proper JSON structure"""
        response = client.get('/health')
        data = json.loads(response.data)

        required_fields = ['status', 'timestamp', 'service']
        for field in required_fields:
            assert field in data

    def test_api_endpoints_return_json(self, client):
        """Test that API endpoints return valid JSON"""
        endpoints = ['/health', '/api/status', '/api/info']

        for endpoint in endpoints:
            response = client.get(endpoint)
            assert response.status_code == 200
            assert response.content_type == 'application/json'

            # Ensure valid JSON
            try:
                json.loads(response.data)
            except json.JSONDecodeError:
                pytest.fail(f"Endpoint {endpoint} did not return valid JSON")

    def test_environment_variables(self, client):
        """Test application handles environment variables"""
        # Test with environment variables set
        os.environ['APP_VERSION'] = '2.0.0'
        os.environ['ENVIRONMENT'] = 'testing'

        response = client.get('/api/info')
        data = json.loads(response.data)

        assert data['version'] == '2.0.0'
        assert data['environment'] == 'testing'

        # Clean up
        del os.environ['APP_VERSION']
        del os.environ['ENVIRONMENT']

    def test_main_page_contains_endpoints_info(self, client):
        """Test that main page contains information about available endpoints"""
        response = client.get('/')
        assert response.status_code == 200

        # Check for endpoint documentation
        assert b'/health' in response.data
        assert b'/api/status' in response.data
        assert b'/api/info' in response.data

    def test_cors_headers(self, client):
        """Test CORS headers are not restricting access"""
        response = client.get('/api/status')
        assert response.status_code == 200
        # Flask doesn't add CORS headers by default, which is fine for this demo

if __name__ == '__main__':
    pytest.main(['-v', '--cov=app', '--cov-report=html', '--cov-report=term-missing'])