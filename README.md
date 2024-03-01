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

      Then in Ubuntu you can open additional drivers and select the optimal nvidia drivers. Install, reboot and check the fluidity of GUI response.
      Better use this command to install the gpu drivers. (CHECK THE VERSION & REPLACE ACCORDINGLY)

                     sudo apt-get install nvidia-driver-535 (Replace 525 with required or latest one)

      BEWARE: CHECK THE OPTIMAL DRIVERS FOR THE PARTICULAR FRAMEWORK (CUDA Version,Release,etc) IF YOUR BUIDLING THEM FROM SOURCE! MAY CAUSE BUILD FAILURES OR RUNTIME ISSUES.

      Now we have to install CUDA Tool Kit for CUDA Ops with C++/Python API support. Now the existing driver install may be replaced by the version required by the toolkit. But installing without the driver onboard can cause issues related to kernel.
      Go to https://developer.nvidia.com/cuda-downloads and CHECK the version of the CUDA with Update release. If its too advance than your requirement kindly do google Search for the optimal version and get the link. (Eg: Nvidia cuda toolkit 12.x ubuntu )

      Select the the required architecture (x86_64 or ARM64, PowerPC) and select the distribution and the version of it.
      Better choose the deb(local) for ubuntu and do the installation manually.
      Follow the installation commands sequentially and complete the update and apt-get install cuda-toolkit-xx.x.
      This is an example isntallation procedure given b nvidia for cuda toolkit 12.2 (driver 535)

                  wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
                  sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
                  wget https://developer.download.nvidia.com/compute/cuda/12.2.0/local_installers/cuda-repo-ubuntu2204-12-2-local_12.2.0-535.54.03-1_amd64.deb
                  sudo dpkg -i cuda-repo-ubuntu2204-12-2-local_12.2.0-535.54.03-1_amd64.deb
                  sudo cp /var/cuda-repo-ubuntu2204-12-2-local/cuda-*-keyring.gpg /usr/share/keyrings/
                  sudo apt-get update
                  sudo apt-get -y install cuda

      Now get into ~/.bashrc file (gedit ~/.bashrc) to reference the cuda version installed to the PATH so that we can use them. (VERY IMPORTANT STEP)

            export PATH=/usr/local/cuda-<version>/bin${PATH:+:${PATH}}

      Now add this line to add lib64 to the PATH (C/C++ lib for CUDA) (Change <version> according to your install)

            export LD_LIBRARY_PATH=/usr/local/cuda-<version>/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

      Now save the .bashrc file and source it.

            source ~/.bashrc

   3) CUDNN Installation - CUDA NEURAL NETWORK lib for optimal NN performance on RTX GPUs (NOT VERSION AGNOSTIC!)

      Go to https://developer.nvidia.com/rdp/cudnn-download and login with nvidia developer account.
      Then find an optimal version of cudnn version with your desired framework. Can cause runtime issues if not matched properly from source.
      You should also math the appropriate CUDA toolkit version with the cudnn installer package.

      

      
      


      
      

        




