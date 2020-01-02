#Script developed to troubleshoot the Platform Service Related Issues on VxRail

#KB - 517433 498849
echo "This script is trying to automate the steps to isolate issue in KB 517433 & 498849"

#It is developed & maintained by VxRail Support - Rajat Kumar
#This is to be run under the supervision of Dell EMC VxRail Support


# Script version:
script_version="0.1"
run_time=$(date)

echo " Current Date / Time:    "$run_time
echo " Script version: "$script_version

# Check if Platform service is initialized

echo "******************************************************************************"
echo "********************************CHECK 1***************************************"

if_initial=$(esxcli vxrail agent get | awk '/true/ {print $2}')
if [ -n "$if_initial" ]
then
	echo "Platform service is initialized"
fi


if_initialized=$(esxcli vxrail agent get | awk '/false/ {print $2}')
if [ -n "$if_initialized" ]
then
	echo "Platform service not initialized, will try to restart Platform Service and check again"
	/etc/init.d/vxrail-pservice restart
	if_initialized_again=$(esxcli vxrail agent get | awk '/false/ {print $2}')
	if [ -n "$if_initialized_again" ]
    then
	    echo "Platform service not initialized, Check KB 517433"
	fi
	
fi



echo "********************************CHECK 2***************************************"

#During Upgrade we use this to get current firmware version and schedule upgrade after comparing the value with Upgrade Bundle files 


firmware_list=$(esxcli vxrail firmware list | grep -i bios)
if [ -n "$firmware_list" ]
then
    echo "Firmware is listed as expected, good ["$firmware_list"]"
else
    echo "ALERT!! Firmware query result empty!"
fi

echo "If the Agent is still listed as false,check logs located at /var/log/platform_svc.log"


#Checking that all users are configured as expected

echo "********************************CHECK 3***************************************"

/opt/vxrail/tools/ipmitool user list 1 | awk '{if (NR==3) print $0; if (NR==16) print $0;if (NR==17) print $0}'


echo "*******************************************************************************"


echo "If the above output contains vxpsvc & PTAdmin and in enabled state then its good else check KB 498837"

#Check of iSM is working correctly with vUSB IP

echo "********************************CHECK 4***************************************"
ping 169.254.0.1

echo "******************************************************************************"

echo "If the ping is unsuccessful , then check the iDRAC vswitch configuration"


echo "********************************CHECK 5***************************************"

#This is to check if PTAgent is able to listen.

pt_initialized=$(esxcli network ip connection list | grep LISTEN | grep Dell | awk '{print $4}')

if [ -n "$pt_initialized" ]
then
    echo "This is working and PTAgent is able to listen : $pt_initialized"
	
else
    echo "PTAgent is not able to listen will restart Respective services & reset iDRAC"
	/etc/init.d/DellPTAgent restart
	/etc/init.d/dcism-netmon-watchdog restart
	/opt/dell/DellPTAgent/bin/ipmitool_static mc reset cold
    echo "Checking the rest_ip config"
	less /scratch/dell/config/PTAgent.config | grep -i rest_ip
fi

echo "Check PTAgent KB - 498849 if the above listen command is still return Null"
