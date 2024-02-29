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
      BEWARE: CHECK THE OPTIMAL DRIVERS FOR THE PARTICULAR FRAMEWORK (CUDA Version,Release,etc) IF YOUR BUIDLING THEM FROM SOURCE! MAY CAUSE BUILD FAILURES OR RUNTIME ISSUES.

      Now we have to install CUDA Tool Kit for CUDA Ops with C++/Python API support.
      Go to https://developer.nvidia.com/cuda-downloads and CHECK the version of the CUDA with Update release. If its too advance than your requirement kindly do google Search for the optimal version and get the link. (Eg: Nvidia cuda toolkit 12.x ubuntu )

      Select the the required architecture (x86_64 or ARM64, PowerPC) and select the distribution and the version of it.
      Better choose the deb(local) for ubuntu and do the installation manually.
      Follow the installation commands sequentially and complete the update and apt-get install cuda-toolkit-xx.x.

      Now get into ~/.bashrc file (gedit ~/.bashrc) to reference the cuda version installed to the PATH so that we can use them. (VERY IMPORTANT STEP)

            export PATH=/usr/local/cuda-<version>/bin${PATH:+:${PATH}}

      Now add this line to add lib64 to the PATH (C/C++ lib for CUDA) (Change <version> according to your install)

            export LD_LIBRARY_PATH=/usr/local/cuda-<version>/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

      Now save the .bashrc file and source it.

            source ~/.bashrc

   2) CUDNN Installation - CUDA NEURAL NETWORK lib for optimal NN performance on RTX GPUs (NOT VERSION AGNOSTIC!)

      Go to https://developer.nvidia.com/rdp/cudnn-download and login with nvidia developer account.
      Then find an optimal version of cudnn version with your desired framework. Can cause runtime issues if not matched properly from source.
      You should also math the appropriate CUDA toolkit version with the cudnn installer package.

      

      
      


      
      

        




