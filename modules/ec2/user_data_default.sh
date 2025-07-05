#!/bin/bash
yum update -y
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple index page with instance information
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>EC2 Instance - ${instance_name}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f0f0f0; }
        .container { background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #232f3e; }
        .info { background-color: #e8f4fd; padding: 15px; border-radius: 4px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to ${instance_name}</h1>
        <div class="info">
            <h3>Instance Information:</h3>
            <p><strong>Instance Name:</strong> ${instance_name}</p>
            <p><strong>Private IP:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)</p>
            <p><strong>Public IP:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "Not available")</p>
            <p><strong>Availability Zone:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
            <p><strong>Instance ID:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
        </div>
        <p>This EC2 instance is running in a ${instance_type} subnet.</p>
    </div>
</body>
</html>
EOF

# Set proper permissions
chown apache:apache /var/www/html/index.html
chmod 644 /var/www/html/index.html
