#!/bin/bash

# NVIDIA Complete Wipeout Script for Ubuntu 24.04
# Removes all NVIDIA drivers, CUDA, and Secure Boot MOK keys
# Created: 2025-11-03

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="/var/log/nvidia-wipeout-$(date +%Y%m%d-%H%M%S).log"

# Function to log and print
log_print() {
    echo -e "${2}${1}${NC}" | tee -a "$LOG_FILE"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

log_print "========================================" "$GREEN"
log_print "NVIDIA Complete Wipeout Script Started" "$GREEN"
log_print "========================================" "$GREEN"
log_print "Log file: $LOG_FILE" "$YELLOW"
log_print "Date: $(date)" "$YELLOW"
log_print "" ""

# Stop any NVIDIA services
log_print "[1/10] Stopping NVIDIA services..." "$YELLOW"
systemctl stop nvidia-persistenced 2>/dev/null || true
systemctl disable nvidia-persistenced 2>/dev/null || true
systemctl stop nvidia-powerd 2>/dev/null || true
systemctl disable nvidia-powerd 2>/dev/null || true
log_print "✓ NVIDIA services stopped" "$GREEN"

# Unload NVIDIA kernel modules
log_print "[2/10] Unloading NVIDIA kernel modules..." "$YELLOW"
rmmod nvidia_uvm 2>/dev/null || true
rmmod nvidia_drm 2>/dev/null || true
rmmod nvidia_modeset 2>/dev/null || true
rmmod nvidia 2>/dev/null || true
log_print "✓ NVIDIA kernel modules unloaded" "$GREEN"

# Remove all NVIDIA and CUDA packages
log_print "[3/10] Removing NVIDIA and CUDA packages..." "$YELLOW"
apt-get remove --purge -y '^nvidia-.*' 2>&1 | tee -a "$LOG_FILE"
apt-get remove --purge -y '^libnvidia-.*' 2>&1 | tee -a "$LOG_FILE"
apt-get remove --purge -y '^cuda-.*' 2>&1 | tee -a "$LOG_FILE"
apt-get remove --purge -y '^libcuda.*' 2>&1 | tee -a "$LOG_FILE"
apt-get remove --purge -y '^cudnn.*' 2>&1 | tee -a "$LOG_FILE"
apt-get remove --purge -y '^libnccl.*' 2>&1 | tee -a "$LOG_FILE"
apt-get remove --purge -y '^libcublas.*' 2>&1 | tee -a "$LOG_FILE"
apt-get remove --purge -y '^libcufft.*' 2>&1 | tee -a "$LOG_FILE"
apt-get remove --purge -y '^libcurand.*' 2>&1 | tee -a "$LOG_FILE"
apt-get remove --purge -y '^libcusolver.*' 2>&1 | tee -a "$LOG_FILE"
apt-get remove --purge -y '^libcusparse.*' 2>&1 | tee -a "$LOG_FILE"
apt-get remove --purge -y '^nsight-.*' 2>&1 | tee -a "$LOG_FILE"
apt-get autoremove -y 2>&1 | tee -a "$LOG_FILE"
apt-get autoclean 2>&1 | tee -a "$LOG_FILE"
log_print "✓ Packages removed" "$GREEN"

# Remove NVIDIA repositories
log_print "[4/10] Removing NVIDIA repositories..." "$YELLOW"
rm -f /etc/apt/sources.list.d/cuda*.list 2>&1 | tee -a "$LOG_FILE"
rm -f /etc/apt/sources.list.d/nvidia*.list 2>&1 | tee -a "$LOG_FILE"
rm -f /etc/apt/sources.list.d/graphics-drivers*.list 2>&1 | tee -a "$LOG_FILE"
apt-key del 7fa2af80 2>/dev/null || true
apt-key del 3bf863cc 2>/dev/null || true
log_print "✓ Repositories removed" "$GREEN"

# Clean apt cache
log_print "[5/10] Cleaning apt cache..." "$YELLOW"
apt-get clean 2>&1 | tee -a "$LOG_FILE"
rm -rf /var/cache/apt/archives/nvidia* 2>&1 | tee -a "$LOG_FILE"
rm -rf /var/cache/apt/archives/cuda* 2>&1 | tee -a "$LOG_FILE"
log_print "✓ Apt cache cleaned" "$GREEN"

# Remove NVIDIA configuration files
log_print "[6/10] Removing NVIDIA configuration files..." "$YELLOW"
rm -f /etc/modprobe.d/nvidia*.conf 2>&1 | tee -a "$LOG_FILE"
rm -f /etc/modprobe.d/blacklist-nvidia*.conf 2>&1 | tee -a "$LOG_FILE"
rm -f /etc/X11/xorg.conf.d/*nvidia*.conf 2>&1 | tee -a "$LOG_FILE"
rm -f /etc/X11/xorg.conf 2>&1 | tee -a "$LOG_FILE"
rm -rf /etc/nvidia 2>&1 | tee -a "$LOG_FILE"
log_print "✓ Configuration files removed" "$GREEN"

# Remove NVIDIA files from system directories
log_print "[7/10] Removing NVIDIA files from system directories..." "$YELLOW"
rm -rf /usr/local/cuda* 2>&1 | tee -a "$LOG_FILE"
rm -rf /usr/lib/nvidia* 2>&1 | tee -a "$LOG_FILE"
rm -rf /usr/lib32/nvidia* 2>&1 | tee -a "$LOG_FILE"
rm -rf /usr/lib/x86_64-linux-gnu/libnvidia* 2>&1 | tee -a "$LOG_FILE"
rm -rf /usr/lib/x86_64-linux-gnu/libcuda* 2>&1 | tee -a "$LOG_FILE"
rm -rf /usr/lib/i386-linux-gnu/libnvidia* 2>&1 | tee -a "$LOG_FILE"
rm -rf /usr/lib/i386-linux-gnu/libcuda* 2>&1 | tee -a "$LOG_FILE"
rm -rf /usr/share/nvidia 2>&1 | tee -a "$LOG_FILE"
rm -rf /opt/cuda* 2>&1 | tee -a "$LOG_FILE"
log_print "✓ System files removed" "$GREEN"

# Remove NVIDIA MOK keys (Secure Boot)
log_print "[8/10] Removing NVIDIA Secure Boot MOK keys..." "$YELLOW"
if command -v mokutil &> /dev/null; then
    # List enrolled keys
    log_print "Current MOK keys:" "$YELLOW"
    mokutil --list-enrolled 2>&1 | tee -a "$LOG_FILE"
    
    # Remove NVIDIA MOK keys
    # Note: This may require reboot and user interaction at MOK Manager
    shopt -s nullglob
    for cert in /var/lib/shim-signed/mok/*.der; do
        if [ -f "$cert" ]; then
            log_print "Removing MOK certificate: $cert" "$YELLOW"
            mokutil --delete "$cert" 2>&1 | tee -a "$LOG_FILE" || true
        fi
    done
    shopt -u nullglob
    
    # Remove MOK key storage
    rm -rf /var/lib/shim-signed/mok/nvidia* 2>&1 | tee -a "$LOG_FILE"
    rm -rf /var/lib/dkms/mok* 2>&1 | tee -a "$LOG_FILE"
    
    log_print "✓ MOK keys removal initiated" "$GREEN"
    log_print "  Note: You may need to confirm MOK deletion at next boot in MOK Manager" "$YELLOW"
else
    log_print "  mokutil not found, skipping MOK cleanup" "$YELLOW"
fi

# Update initramfs
log_print "[9/10] Updating initramfs..." "$YELLOW"
update-initramfs -u -k all 2>&1 | tee -a "$LOG_FILE"
log_print "✓ Initramfs updated" "$GREEN"

# Update GRUB
log_print "[10/10] Updating GRUB..." "$YELLOW"
update-grub 2>&1 | tee -a "$LOG_FILE"
log_print "✓ GRUB updated" "$GREEN"

# Final cleanup and verification
log_print "" ""
log_print "========================================" "$GREEN"
log_print "Cleanup Summary" "$GREEN"
log_print "========================================" "$GREEN"

# Check for remaining NVIDIA packages
REMAINING=$(dpkg -l | grep -i nvidia | wc -l)
log_print "Remaining NVIDIA packages: $REMAINING" "$YELLOW"
if [ "$REMAINING" -gt 0 ]; then
    log_print "Remaining packages:" "$YELLOW"
    dpkg -l | grep -i nvidia | tee -a "$LOG_FILE"
fi

# Check for remaining CUDA packages
REMAINING_CUDA=$(dpkg -l | grep -i cuda | wc -l)
log_print "Remaining CUDA packages: $REMAINING_CUDA" "$YELLOW"
if [ "$REMAINING_CUDA" -gt 0 ]; then
    log_print "Remaining CUDA packages:" "$YELLOW"
    dpkg -l | grep -i cuda | tee -a "$LOG_FILE"
fi

# Check loaded kernel modules
log_print "" ""
log_print "Loaded NVIDIA kernel modules:" "$YELLOW"
lsmod | grep nvidia | tee -a "$LOG_FILE" || log_print "  None (Good!)" "$GREEN"

log_print "" ""
log_print "========================================" "$GREEN"
log_print "NVIDIA Wipeout Completed Successfully!" "$GREEN"
log_print "========================================" "$GREEN"
log_print "" ""
log_print "Next Steps:" "$YELLOW"
log_print "1. Reboot your system" "$YELLOW"
log_print "2. If prompted, confirm MOK key deletion in MOK Manager" "$YELLOW"
log_print "3. After reboot, install CUDA 13 Toolkit with drivers" "$YELLOW"
log_print "" ""
log_print "After re-installing Drivers, Toolkit make sure to enroll MOK for Secure Boot (if enabled)" "$YELLOW"
log_print "Use the below commands to make sure the MOK keys are present and re-enroll for signing of the device to the drivers" "$YELLOW"
log_print "ls -la /var/lib/shim-signed/mok/" "$GREEN"
log_print "If exists, Enroll them to prompt for MOK during the reboot" "$YELLOW"
log_print "sudo mokutil --import /var/lib/shim-signed/mok/MOK.der" "$GREEN"
log_print "Full log saved to: $LOG_FILE" "$GREEN"
log_print "" ""
