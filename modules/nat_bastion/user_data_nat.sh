#!/bin/bash
yum update -y
yum install -y iptables-services

# Enable IP forwarding for NAT functionality
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Configure iptables for NAT
/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
/sbin/iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT

# Save iptables rules
/sbin/service iptables save

# Enable iptables service
systemctl enable iptables
systemctl start iptables

# Install and start httpd for testing connectivity
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create a simple index page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>NAT Instance</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f0f8ff; }
        .container { background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #ff6600; }
        .info { background-color: #ffe6cc; padding: 15px; border-radius: 4px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>NAT Instance</h1>
        <div class="info">
            <h3>Instance Information:</h3>
            <p><strong>Private IP:</strong> $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)</p>
            <p><strong>Public IP:</strong> $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</p>
            <p><strong>Availability Zone:</strong> $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
            <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
            <p><strong>IP Forwarding:</strong> $(cat /proc/sys/net/ipv4/ip_forward)</p>
        </div>
        <p>This instance is configured as a NAT server for private subnet instances.</p>
    </div>
</body>
</html>
EOF