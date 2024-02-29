This repo page lists down the effective installation guideline for Workstations with NVIDIA GPUs for AI/DL/NN workloads and Robotics Environment supporting frameworks such as 
TensorFlow/Pytorch/ROS2 etc.

Part of this process can be followed for NVIDIA Omniverse setup with ISAAC ROS and GYM capabilities.

This installation guide targets only LINUX/UNIX Operating Systems ie. Ubuntu LTS, RHEL, etc.



Initial Step after operating system install:

   1) Disable / Blacklist nouveau (default nvidia driver mostly on ubuntu)

                      sudo nautilus
      Press Ctrl+l
      get into /etc/modprobe.d/blacklist.conf as root

      add these lines at the last of the file
      
                      blacklist nouveau
                      options nouveau modeset=0
      save and close the file
      then enter update the initramfs using this command

                     sudo update-initramfs -u
                     sudo reboot


      
      

        




