#Live_CSI_Activity_Recognition  
Activity Recognition using Channel State Information  

You must have intel 5300 Network Interface Card and Ubuntu 12-14 for this.  
Finding the right version of Ubuntu can be a pain. Version 14.04.01 LTS worked for me process CSI in real time.  
You also need a fast laptop (preferably with an SSD to )  

First, install intel 5300 CSI tool from here and set it up in monitor mode:  
https://dhalperi.github.io/linux-80211n-csitool/  

An easier tutorial for laymen can be found here (use google translate)  
https://www.smwenku.com/a/5bd3b1ad2b717778ac20b508/  
https://blog.csdn.net/qq_20604671/article/details/53996239  

After sucessfully installing CSI tool and making sure its working, install this to record and decode and plot CSI in real-time:  
https://github.com/lubingxian/Realtime-processing-for-csitool  
Note: Open matlab using "sudo ./matlab -softwareopengl" for this to work.  

After Live CSI is achieved, now you have to train a ML model which can classify activities.  
You can either train you own model and use it or use the model I have trained in the models folder. (To use your own model, replace the files in /matlab/model)
To go through the process of data pre-processing and model training, you can use this python notebook.  
(I used this dataset :https://github.com/ermongroup/Wifi_Activity_Recognition)

After getting a trained model, now you need to put this model to work.  
For that you will need a later version of matlab. R2018b would be preferable.  
Install Deep Learning Toolbox from Matlab Addons.

Import your model into matlab using importKerasNetwork() function and inputting the .json file for archituecture and .h5 file
for the weights and make sure it imports correctly.  
Note: If matlab is not importing your model, try renaming keras version in the json file to you keras version (remove "-tf" in the end of the version)  

Now you need the files in this repo (note these need to go into linux-80211n-csitool-supplementary)  
and follow these steps:

1.SET UP Monitor Mode on the receiver  
cd linux-80211n-csitool-supplementary/injection/  
sudo ./setup_monitor_csi.sh 64 HT20  

2.SET UP injection mod on the transmitter and start injecting packets:  
cd /home/user_name/linux-80211n-csitool-supplementary/injection  
sudo ./setup_inject.sh 64 HT20  
sudo su  
echo 0x4101 | sudo tee `find /sys -name monitor_tx_rate`

sudo ./random_packets 1 100 1
#1st parameter = No of packets
2nd parameter = packet size
3rd parameter = mode of transmission (keep it 1)
4th parameter = delay between samples in micro seconds

For example if you want to transmit for 20s at a freq of 1k,
there would be a total of 20*1k = 20000 samples. Therefore,
1st paraemeter = 20000. 2nd parameter = 1, 3rd parameter =1
Now, 4th parameter = 1000 (because 20000 * 1000 * 1micro = 20s) 


3.Run Matlab on Receiver and run the experiment.m code
cd /usr/local/MATLAB/R2018b/bin
sudo ./matlab
live_activity.m

4.Provide CSI socket to matlab and start receiving CSI data
cd /home/user_name/linux-80211n-csitool-supplementary/netlink
sudo ./log_to_server 127.0.0.1 8090
