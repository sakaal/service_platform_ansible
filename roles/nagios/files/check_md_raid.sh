#!/bin/bash
#
# Source:
# https://exchange.nagios.org/directory/Plugins/Operating-Systems/Linux/check_md_raid/details
#
# Created by Sebastian Grewe, Jammicron Technology
#

# Get count of raid arrays
RAID_DEVICES=`grep ^md -c /proc/mdstat`

# Get count of degraded arrays
#RAID_STATUS=`grep "\[.*_.*\]" /proc/mdstat -c`
RAID_STATUS=`egrep "\[.*(=|>|\.).*\]" /proc/mdstat -c`

# Is an array currently recovering, get percentage of recovery
RAID_RECOVER=`grep recovery /proc/mdstat | awk '{print $4}'`
RAID_RESYNC=`grep resync /proc/mdstat | awk '{print $4}'`
RAID_CHECK=`grep check /proc/mdstat | awk '{print $4}'`

# Check raid status
# RAID recovers --> Warning
if [[ $RAID_RECOVER ]]; then
STATUS="WARNING - Checked $RAID_DEVICES arrays, recovering : $RAID_RECOVER"
EXIT=1
elif [[ $RAID_RESYNC ]]; then
STATUS="WARNING - Checked $RAID_DEVICES arrays, resync : $RAID_RESYNC"
EXIT=1
elif [[ $RAID_CHECK ]]; then
STATUS="OK - Checked $RAID_DEVICES arrays, check : $RAID_CHECK"
EXIT=0
# RAID ok
elif [[ $RAID_STATUS == "0" ]]; then
STATUS="OK - Checked $RAID_DEVICES arrays."
EXIT=0
# All else critical, better save than sorry
else
EXTEND_RAID_STATUS=`egrep "\[.*(=|>|\.|_).*\]" /proc/mdstat | awk '{print $2}' | uniq -c | xargs echo`
STATUS="WARNING- Checked $RAID_DEVICES arrays, $RAID_STATUS have failed check: $EXTEND_RAID_STATUS "
EXIT=1
fi

# Status and quit
echo $STATUS
exit $EXIT
