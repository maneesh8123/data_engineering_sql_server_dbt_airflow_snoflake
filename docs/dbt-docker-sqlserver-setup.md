# dbt + Docker + SQL Server setup

## Summary
This project was adjusted so dbt can run inside a Docker container and connect to a SQL Server instance running on the host machine.

## What was fixed

### 1. Docker image dependencies
The Docker image was updated to install the required packages for dbt and SQL Server connectivity:
- git
- unixodbc
- unixodbc-dev
- gcc
- g++
- Microsoft ODBC Driver 17 for SQL Server

This was done in the Dockerfile so the container could run dbt successfully and establish ODBC connections.

### 2. dbt profile configuration
The dbt profile was updated to use SQL authentication instead of Windows integrated authentication, which works better from inside a Linux container.

The profile now uses:
- server: host.docker.internal\\SQLEXPRESS
- port: 1433
- database: fa9710018
- schema: dbo
- user: dbt_user
- password: YourStrongPassword@123

### 3. SQL Server login
A SQL Server login named dbt_user was created and granted access to the target database so the container could authenticate successfully.

## Verified commands
The setup was verified with:

```powershell
docker build -t dbt_img:0.1 .
docker run --rm dbt_img:0.1 debug --profiles-dir .
```

## Verified result
The final dbt check returned:
- Connection test: [OK connection ok]
- All checks passed

## Notes
- host.docker.internal is used because the SQL Server instance is running on the host machine and needs to be reachable from the container.
- If the database is moved to another host or container, the server value in the dbt profile may need to be updated.
