FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    git \
    apt-transport-https \
    unixodbc \
    unixodbc-dev \
    gcc \
    g++

RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg

RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" \
    > /etc/apt/sources.list.d/mssql-release.list

# Install the Microsoft ODBC Driver for SQL Server
RUN apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY mssql_migration/ .

ENV DBT_SQL_SERVER=host.docker.internal\\SQLEXPRESS
ENV DBT_SQL_PORT=1433

#However, if your profiles.yml is stored in your project folder, then you need to tell dbt where to find it
RUN dbt deps --profiles-dir .

# sh = the shell program
# -c = “execute the following command string”
# the last argument is the command to run

ENTRYPOINT ["sh", "-c", "dbt debug --profiles-dir . && dbt run --profiles-dir ."]