# using image
FROM microsoft/mssql-server-windows-developer 

# create directory within SQL container for database files
RUN powershell -Command (mkdir C:\\SQLServer)

COPY DBA-Admin.mdf C:\\SQLServer
COPY DBA-Admin_log.ldf C:\\SQLServer

# set environment variables
ENV sa_password=Testing11@@

ENV ACCEPT_EULA=Y

ENV attach_dbs="[{'dbName':'DBA-Admin','dbFiles':['C:\\SQLServer\\DBA-Admin.mdf','C:\\SQLServer\\DBA-ADmin_log.ldf']}]"