#!/usr/bin/env python3
"""
Simple Flask Application for Jenkins CI/CD Pipeline Demo
"""

from flask import Flask, jsonify, render_template_string
import os
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# HTML template for the main page
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Flask CI/CD Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            color: #333;
            text-align: center;
            margin-bottom: 30px;
        }
        .status {
            background: #4CAF50;
            color: white;
            padding: 10px;
            border-radius: 5px;
            text-align: center;
            margin: 20px 0;
        }
        .info {
            background: #2196F3;
            color: white;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .endpoint {
            background: #ff9800;
            color: white;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Flask CI/CD Pipeline Demo</h1>
        </div>
        
        <div class="status">
            ✅ Application is running successfully!
        </div>
        
        <div class="info">
            <h3>Application Information:</h3>
            <p><strong>Version:</strong> {{ version }}</p>
            <p><strong>Environment:</strong> {{ environment }}</p>
            <p><strong>Timestamp:</strong> {{ timestamp }}</p>
            <p><strong>Host:</strong> {{ host }}</p>
        </div>
        
        <div class="endpoint">
            <h3>Available Endpoints:</h3>
            <ul>
                <li><strong>GET /</strong> - This main page</li>
                <li><strong>GET /health</strong> - Health check endpoint</li>
                <li><strong>GET /api/status</strong> - API status endpoint</li>
                <li><strong>GET /api/info</strong> - Application information</li>
            </ul>
        </div>
    </div>
</body>
</html>
"""

@app.route('/')
def index():
    """Main application page"""
    return render_template_string(HTML_TEMPLATE, 
                                version=os.getenv('APP_VERSION', '1.0.0'),
                                environment=os.getenv('ENVIRONMENT', 'development'),
                                timestamp=datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                                host=os.getenv('HOSTNAME', 'localhost'))

@app.route('/health')
def health():
    """Health check endpoint for Kubernetes probes"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'service': 'flask-cicd-demo'
    }), 200

@app.route('/api/status')
def api_status():
    """API status endpoint"""
    return jsonify({
        'status': 'running',
        'version': os.getenv('APP_VERSION', '1.0.0'),
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/api/info')
def api_info():
    """Application information endpoint"""
    return jsonify({
        'application': 'Flask CI/CD Demo',
        'version': os.getenv('APP_VERSION', '1.0.0'),
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'python_version': os.getenv('PYTHON_VERSION', '3.9'),
        'host': os.getenv('HOSTNAME', 'localhost'),
        'port': os.getenv('PORT', 5000),
        'timestamp': datetime.now().isoformat(),
        'uptime': 'Available since application start'
    }), 200

@app.errorhandler(404)
def not_found(error):
    """404 error handler"""
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested resource was not found on this server.',
        'status_code': 404
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """500 error handler"""
    logger.error(f"Internal server error: {error}")
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'An internal server error occurred.',
        'status_code': 500
    }), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug_mode = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    
    logger.info(f"Starting Flask application on port {port}")
    logger.info(f"Debug mode: {debug_mode}")
    logger.info(f"Environment: {os.getenv('ENVIRONMENT', 'development')}")
    
    app.run(
        host='0.0.0.0',
        port=port,
        debug=debug_mode
    )