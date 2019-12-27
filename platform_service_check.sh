
#Script developed to troubleshoot the Platform Service Related Issues on VxRail

#KB - 517433

echo "This script is trying to automate the steps to isolate issue in KB 517433"

#It is developed & maintained by VxRail Support - Rajat Kumar


# Script version:
script_version="0.1"
run_time=$(date)

echo "/// Date / Time:    "$run_time
echo "/// Script version: "$script_version

# Check if Platform service is initialized

echo "******************************************************************************"
echo "********************************CHECK 1***************************************"

if_initialized=$(esxcli vxrail agent get | awk '/false/ {print $2}')
if [ -n "$if_initialized" ]
then
	echo "Platform service not initialized, will try to restart Platform Service and check again"
	/etc/init.d/vxrail-pservice restart
	if_initialized_again=$(esxcli vxrail agent get | awk '/false/ {print $2}')
	if [ -n "$is_initialized_again" ]
    then
	    echo "Platform service not initialized, Check KB 517433"
	fi
fi


firmware_list=$(esxcli vxrail firmware list | grep -i bmc)
if [ -n "$firmware_list" ]
then
    echo "Firmware is listed as expected, good ["$firmware_list"]"
else
    echo "ALERT!! Firmware query result empty!"
fi

echo "If the Agent is still listed as false,check logs located at /var/log/platform_svc.log"


#Checking that all users are configured as expcted

echo "********************************CHECK 2***************************************"

/opt/vxrail/tools/ipmitool user list 1 | awk '{if (NR==3) print $0; if (NR==16) print $0;if (NR==17) print $0}'


echo "*******************************************************************************"


echo "If the above output contains vxpsvc & PTAdmin and in enabled state then its good else check KB 498837"

#Check of iSM is working correctly with vUSB IP

echo "********************************CHECK 3***************************************"
ping 169.254.0.1

echo "******************************************************************************"

echo "If the ping is unsuccessfull , then check the iDRAC vswitch configuration"



