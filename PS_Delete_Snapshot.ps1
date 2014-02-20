# Snapshot script NVM
# Author: Tom Meulensteen (tmeulensteen@mirabeau.nl)
# Date 19-02-2014

# The following is an array of Servernames for which you would like to create a snapshot. Just add servers as needed.
#$Servers=@("NVM-PROD-MAN","NVM-PROD01","NVM-PROD02","NVM-PROD03", "NVM-PROD05", "NVM-PROD07", "NVM-PROD20", "NVM-PROD30", "NVM-PROD31")
$Servers=@("NVM-PROD-MAN")

# Criteria to use to filter the results returned.
$daysBack = 30

# Now we will loop through the array and for each instanceid found a snapshot will be created.
foreach ($ServerName in $Servers)
{
	# Create a filter which we will use to make sure we're only getting EC2Instance info for one server
	$filter = (new-object Amazon.EC2.Model.Filter).WithName('tag:Name').WithValue($ServerName)
	# Get the InstanceID for ServerName
	$InstanceID = (Get-EC2Instance -Filter $filter) | Select -ExpandProperty RunningInstance | Select InstanceId
	
	# Query for volumes that are attached to the servers Instance Id
	$volumes = (Get-EC2Volume).Attachment | where {$_.InstanceId -eq $InstanceID.InstanceId } | Select VolumeId
	# Iterate through these volumes and snapshot each of them
	foreach ($volume in $volumes)
	{
        
        
        #Get Snapshots for this volume
        $filtersnapshots =  (get-EC2Snapshot -Owner self) | where {$_.VolumeId -eq $volume.VolumeId} | select SnapshotId,StartTime,Description
        
        #Setting Date
        $d = ([DateTime]::Now).AddDays(-$daysBack)

        #check date for this snapshot
        foreach ($s in $filtersnapshots)
        {
            
            if ([DateTime]::Compare($d, $s.StartTime) -gt 0)
            {
                #Remove-EC2Snapshot -SnapshotId $s.SnapshotId
                echo $s.Description

            }
        }
    }
}
