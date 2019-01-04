# Download and install docker
# pull the latest SQL Server image
# docker pull microsoft/mssql-server-windows-developer:2017-CU1
## want to create a SQL Server
docker run -d -p 15789:1433 --env ACCEPT_EULA=Y --env sa_password=Testing11@@ --name MyFirstContainer microsoft/mssql-server-windows-developer 
## container is running
## connect via SSMS, PowerShell, Ops Studio with 
## You need to get the IP Address with
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' MyFirstContainer 
## Its just SQL so do what you like
## simples
## and when you have finished
## Now remove it
docker stop MyFirstContainer
docker rm MyFirstContainer
## and its gone :-)
## Need 3 SQL instances ?
docker run -d -p 15789:1433 --env ACCEPT_EULA=Y --env sa_password=Testing11@@ --name MyFirstContainer microsoft/mssql-server-windows-developer 
docker run -d -p 15790:1433 --env ACCEPT_EULA=Y --env sa_password=Testing11@@ --name MySecondContainer microsoft/mssql-server-windows-developer 
docker run -d -p 15791:1433 --env ACCEPT_EULA=Y --env sa_password=Testing11@@ --name MyThirdContainer microsoft/mssql-server-windows-developer 

## inspect to get the IPs and connect and then
## Throw them away!!
docker stop MyFirstContainer
docker rm MyFirstContainer
docker stop MySecondContainer
docker rm MySecondContainer
docker stop MyThirdContainer
docker rm MyThirdContainer


## OK lets get more advanced
## Lets add our own database into the container using the files
## So maybe we restore a backup of Prod - clean it back it up and
## move the backup to a folder like
## explorer C:\Users\mrrob\OneDrive\Documents\GitHub\DockerStuff\DatabaseFiles

## Then we need to switch to linux containers, change settings for shared drives
## Need to enter credentials

## and we can create a container like

docker run -d -p 15793:1433 -v C:\Dockerfiles:C:\SQLServer --env ACCEPT_EULA=Y --env sa_password=Testing11@@ --name dbaadmincontainer microsoft/mssql-server-windows-developer
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'  dbaadmincontainer
## Connect to it in Ops Studio and run

<#
USE [master]
RESTORE DATABASE [DBA-Admin] 
FROM  DISK = N'C:\sqlserver\ROB-XPS_DBA-Admin_FULL_20171210_124529.bak' 
WITH  FILE = 1,  
MOVE N'DBA-Admin' 
TO N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\DBA-Admin.mdf',  
MOVE N'DBA-Admin_log' 
TO N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\DBA-Admin_log.ldf',  
NOUNLOAD,  REPLACE,  STATS = 5

GO
#>

docker stop dbaadmincontainer
docker rm dbaadmincontainer

## Lets add our own database into the container using the files
## So maybe we restore a backup of Prod - clean it and then shut 
## down the instance and copy the files to a folder like
## explorer C:\Dockerfiles

docker run -d -p 15793:1433 -v C:\Dockerfiles:C:\SQLServer --env ACCEPT_EULA=Y --env sa_password=Testing11@@ --name dbaadmincontainer microsoft/mssql-server-windows-developer
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'  dbaadmincontainer

<#

CREATE DATABASE Blah   
    ON (FILENAME = 'C:\SQLServer\DBA-Admin.mdf'),   
    (FILENAME = 'C:\SQLServer\DBA-Admin_Log.ldf')   
    FOR ATTACH; 

#>

## DOnt have or want to copy the ldf ?

<#
CREATE DATABASE AnotherBlah   
    ON (FILENAME = 'C:\SQLServer\DBA-Admin1.mdf')
FOR ATTACH_REBUILD_LOG
GO
#>

docker stop dbaadmincontainer
docker rm dbaadmincontainer

## Or we can build a dockerfile and build our own image like this

docker build -t dbaadmincontainer -f C:\Dockerfiles\builds\dockerfile.dockerfile C:\Dockerfiles\builds

# So now we have our own image we spin it up just like before

docker run -d -p 15788:1433  --name dbaadmincontainer dbaadmincontainer
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'  dbaadmincontainer

docker stop dbaadmincontainer
docker rm dbaadmincontainer


## With ay of those methods you can create an image - the last one created one.
## You can share it by pushing it up to the docker hub (probably not what you want)
## or

cd C:\Dockerfiles
# this will take a while
docker save -o dbaadmincontainer.tar dbaadmincontainer

# copy the resulting file and then on the new machine

docker load -i dbaadmincontainer.tar

## and away you can go