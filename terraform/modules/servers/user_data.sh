#!/bin/bash

# Update system
yum update -y

# Install basic tools
yum install -y \
    wget \
    curl \
    git \
    vim \
    htop \
    unzip \
    jq

# Set hostname
hostnamectl set-hostname ${hostname}

# Configure SSH for better security
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Create CloudWatch config
cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json << 'EOF'
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "/aws/ec2/{instance_id}/messages",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
                "metrics_collection_interval": 60,
                "totalcpu": false
            },
            "disk": {
                "measurement": ["used_percent"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
            },
            "diskio": {
                "measurement": ["io_time"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
            },
            "mem": {
                "measurement": ["mem_used_percent"],
                "metrics_collection_interval": 60
            },
            "netstat": {
                "measurement": ["tcp_established", "tcp_time_wait"],
                "metrics_collection_interval": 60
            },
            "swap": {
                "measurement": ["swap_used_percent"],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Create welcome message
cat > /etc/motd << EOF
Welcome to ${hostname}
Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type)
Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)
Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
EOF

# Install Docker (for public instances that might need it)
if [[ "${hostname}" == *"public"* ]]; then
    yum install -y docker
    systemctl enable docker
    systemctl start docker
    usermod -a -G docker ec2-user
fi

echo "User data script completed for ${hostname}" 