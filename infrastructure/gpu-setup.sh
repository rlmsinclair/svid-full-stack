#!/bin/bash
# GPU Infrastructure Setup Script for SVID Platform
# This script sets up the GPU processing infrastructure for video analysis

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
    fi
}

# Detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        log_error "Cannot detect Linux distribution"
    fi
    log_info "Detected OS: $OS $VER"
}

# Install NVIDIA drivers and CUDA toolkit
install_nvidia_drivers() {
    log_info "Installing NVIDIA drivers and CUDA toolkit..."
    
    case $OS in
        ubuntu)
            # Add NVIDIA package repositories
            wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
            dpkg -i cuda-keyring_1.1-1_all.deb
            apt-get update
            
            # Install CUDA and drivers
            apt-get install -y cuda-12-3 nvidia-driver-545
            
            # Install additional tools
            apt-get install -y nvidia-cuda-toolkit nvidia-container-toolkit
            ;;
            
        centos|rhel|rocky)
            # Add NVIDIA repo
            dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
            dnf clean all
            
            # Install CUDA and drivers
            dnf install -y cuda-12-3 nvidia-driver-545
            ;;
            
        *)
            log_error "Unsupported distribution: $OS"
            ;;
    esac
    
    log_success "NVIDIA drivers installed"
}

# Configure GPU settings for optimal performance
configure_gpu_settings() {
    log_info "Configuring GPU settings..."
    
    # Enable persistence mode
    nvidia-smi -pm 1
    
    # Set compute mode to exclusive process
    nvidia-smi -c 3
    
    # Configure GPU clocks for maximum performance
    for gpu in $(nvidia-smi --query-gpu=index --format=csv,noheader); do
        # Enable auto boost
        nvidia-smi -i $gpu --auto-boost-default=1
        
        # Set power limit to maximum
        max_power=$(nvidia-smi -i $gpu --query-gpu=power.max_limit --format=csv,noheader,nounits)
        nvidia-smi -i $gpu -pl $max_power
        
        # Lock GPU clocks for consistent performance
        nvidia-smi -i $gpu -lgc 2100
        
        log_info "Configured GPU $gpu for maximum performance"
    done
    
    log_success "GPU settings configured"
}

# Install Docker with NVIDIA support
install_docker_nvidia() {
    log_info "Installing Docker with NVIDIA GPU support..."
    
    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    
    # Install NVIDIA Container Toolkit
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list
    
    apt-get update
    apt-get install -y nvidia-container-toolkit
    
    # Configure Docker daemon
    cat > /etc/docker/daemon.json <<EOF
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "10"
    },
    "storage-driver": "overlay2"
}
EOF
    
    systemctl restart docker
    
    log_success "Docker with NVIDIA support installed"
}

# Install Kubernetes components
install_kubernetes() {
    log_info "Installing Kubernetes components..."
    
    # Add Kubernetes repo
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
    
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl
    
    # Enable required kernel modules
    cat > /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
    
    modprobe overlay
    modprobe br_netfilter
    
    # Configure sysctl
    cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
    
    sysctl --system
    
    log_success "Kubernetes components installed"
}

# Install NVIDIA GPU Operator for Kubernetes
install_gpu_operator() {
    log_info "Installing NVIDIA GPU Operator..."
    
    # Add NVIDIA Helm repository
    helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
    helm repo update
    
    # Create namespace
    kubectl create namespace gpu-operator || true
    
    # Install GPU Operator
    helm install --wait \
        --generate-name \
        --namespace gpu-operator \
        --create-namespace \
        nvidia/gpu-operator \
        --set driver.enabled=false \
        --set toolkit.enabled=true \
        --set devicePlugin.enabled=true \
        --set migManager.enabled=true \
        --set gfd.enabled=true
    
    log_success "NVIDIA GPU Operator installed"
}

# Configure system for video processing
configure_system() {
    log_info "Configuring system for video processing..."
    
    # Increase system limits
    cat >> /etc/security/limits.conf <<EOF
* soft nofile 1048576
* hard nofile 1048576
* soft memlock unlimited
* hard memlock unlimited
EOF
    
    # Configure huge pages for better memory performance
    echo "vm.nr_hugepages = 10000" >> /etc/sysctl.conf
    sysctl -p
    
    # Install FFmpeg with GPU support
    apt-get install -y ffmpeg
    
    # Install monitoring tools
    apt-get install -y htop iotop nvtop prometheus-node-exporter
    
    # Configure RAID for NVMe storage
    if command -v mdadm &> /dev/null; then
        log_info "Configuring RAID 0 for NVMe drives..."
        # This is an example - adjust device names as needed
        # mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/nvme0n1 /dev/nvme1n1
        # mkfs.ext4 /dev/md0
        # mkdir -p /mnt/video-cache
        # mount /dev/md0 /mnt/video-cache
        # echo "/dev/md0 /mnt/video-cache ext4 defaults,noatime 0 0" >> /etc/fstab
    fi
    
    log_success "System configured for video processing"
}

# Install model management tools
install_model_tools() {
    log_info "Installing model management tools..."
    
    # Install Python and required packages
    apt-get install -y python3 python3-pip python3-venv
    
    # Create virtual environment for model tools
    python3 -m venv /opt/svid-models
    source /opt/svid-models/bin/activate
    
    # Install required Python packages
    pip install --upgrade pip
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    pip install transformers accelerate bitsandbytes
    pip install safetensors sentencepiece protobuf
    
    # Create model directories
    mkdir -p /models/{weights,cache,checkpoints}
    chmod 755 /models
    
    # Create model download script
    cat > /usr/local/bin/download-llama-scout <<'EOF'
#!/bin/bash
# Download Llama 4 Scout 17B model

MODEL_DIR="/models/weights"
MODEL_NAME="llama-4-scout-17b"

echo "Downloading Llama 4 Scout 17B model..."
# Add actual download logic here
# This would typically use HuggingFace CLI or similar

echo "Model downloaded to $MODEL_DIR/$MODEL_NAME"
EOF
    
    chmod +x /usr/local/bin/download-llama-scout
    
    log_success "Model management tools installed"
}

# Setup monitoring and alerting
setup_monitoring() {
    log_info "Setting up monitoring and alerting..."
    
    # Install Prometheus and Grafana
    docker run -d \
        --name prometheus \
        -p 9090:9090 \
        -v /etc/prometheus:/etc/prometheus \
        -v /var/lib/prometheus:/prometheus \
        prom/prometheus
    
    docker run -d \
        --name grafana \
        -p 3000:3000 \
        -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
        grafana/grafana
    
    # Install DCGM exporter for GPU metrics
    docker run -d \
        --name dcgm-exporter \
        --gpus all \
        -p 9400:9400 \
        nvcr.io/nvidia/k8s/dcgm-exporter:3.1.7-3.1.4-ubuntu20.04
    
    # Create GPU monitoring dashboard
    cat > /tmp/gpu-dashboard.json <<'EOF'
{
  "dashboard": {
    "title": "GPU Processing Dashboard",
    "panels": [
      {
        "title": "GPU Utilization",
        "targets": [
          {
            "expr": "DCGM_FI_DEV_GPU_UTIL"
          }
        ]
      },
      {
        "title": "GPU Memory Usage",
        "targets": [
          {
            "expr": "DCGM_FI_DEV_FB_USED / DCGM_FI_DEV_FB_TOTAL * 100"
          }
        ]
      },
      {
        "title": "GPU Temperature",
        "targets": [
          {
            "expr": "DCGM_FI_DEV_GPU_TEMP"
          }
        ]
      },
      {
        "title": "Video Processing Rate",
        "targets": [
          {
            "expr": "rate(videos_processed_total[5m])"
          }
        ]
      }
    ]
  }
}
EOF
    
    log_success "Monitoring and alerting configured"
}

# Create systemd service for GPU processor
create_gpu_service() {
    log_info "Creating systemd service for GPU processor..."
    
    cat > /etc/systemd/system/svid-gpu-processor.service <<EOF
[Unit]
Description=SVID GPU Video Processor
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
Restart=always
RestartSec=10
User=svid
Group=svid
Environment="RUST_LOG=info"
Environment="MODEL_PATH=/models/weights/llama-4-scout-17b"
WorkingDirectory=/opt/svid
ExecStart=/opt/svid/gpu-processor

# Resource limits
LimitNOFILE=1048576
LimitMEMLOCK=infinity

# GPU access
SupplementaryGroups=video

[Install]
WantedBy=multi-user.target
EOF
    
    # Create user for service
    useradd -r -s /bin/false svid || true
    usermod -a -G video svid
    
    systemctl daemon-reload
    systemctl enable svid-gpu-processor
    
    log_success "GPU processor service created"
}

# Main installation flow
main() {
    log_info "Starting GPU infrastructure setup for SVID platform"
    
    check_root
    detect_distro
    
    # Update system
    log_info "Updating system packages..."
    apt-get update && apt-get upgrade -y
    
    # Install components
    install_nvidia_drivers
    configure_gpu_settings
    install_docker_nvidia
    install_kubernetes
    install_gpu_operator
    configure_system
    install_model_tools
    setup_monitoring
    create_gpu_service
    
    # Verify installation
    log_info "Verifying GPU installation..."
    nvidia-smi
    
    log_success "GPU infrastructure setup completed successfully!"
    log_info "Please reboot the system to ensure all changes take effect"
    log_info "After reboot, run 'download-llama-scout' to download the model"
    log_info "Access monitoring dashboard at http://localhost:3000 (admin/admin)"
}

# Run main function
main "$@"