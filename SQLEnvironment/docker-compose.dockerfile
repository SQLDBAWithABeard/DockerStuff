version: '1.0'

services:
    sql2012:
        image: dbafromthecold/sqlserver2012dev
            ports:
      - "15589:1433"
    environment:
      SA_PASSWORD: "Password0!"
      ACCEPT_EULA: "Y"
          healthcheck:
      test: sqlcmd -S sql2012 -U SA -P 'Password0!' -Q 'select 1'
    networks:
      mynetwork:
        aliases:
          - sql2012

networks:
  mynetwork:
    driver: bridge