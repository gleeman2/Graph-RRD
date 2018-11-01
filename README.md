## Graph from RRD

**Story:**

We were looking for a "first look" troubleshooting/monitoring tool to cover our multivendor storage environment.
Criteria to meet:
1. Must be multivendor
2. Must be able keep trends (Capacity, IO, etc) up to 1 year
3. Must have alerting/reporting capabilities
4. Must be well supported, free'ish and have be future proof
5. Nice to have - Low maintenance and easy to use/configure
6. Nice to have – Support(paid or free) from vendor to modify pull scripts or add new arrays.

There was no one app out there to full all the criteria, but we came close anough with using stor2rrd, Grafana and Graphite. The rest of the readme covers the lessosn learned and the end results that is my current working solution. This document will be focused around INFINIDAT.



**STOR2RRD**

The product actually supports these storages arrays:
INFINIDAT InfiniBox
IBM
Hitachi
NetApp FAS (7-mode, C-mode)
NetApp E-series
HPE
Dell EMC²
Dell SC series (Compellent)
Dell MD 3000
DotHiLL
Lenovo Storage S Series (S2200/S3200)
Pure Storage
Huawei OceanStore
Fujitsu ETERNUS
Quantum StorNext
Dot Hill/Seagate AssuredSAN
LSI / Engenio based storages
DataCore SANSymphony

The product supports SAN monitoring:
Brocade SAN switches and all their re-brands
Brocade Network Advisor
Cisco MDS SAN switches
Cisco Nexus switches
QLogic



**Install and Configure the Environment**

The following needs to be in place
1. Install docker.
2. Pull down GraphRRD
3. Run GraphRRD docker image (docker run -d -p 8080:80 graph-rrd)
4. Connect to image http://localhost:8080


**XoruX Docker Image**

Git repo of the Docker image for XoruX applications - LPAR2RRD & STOR2RRD.

This docker image is based on official Debian 9 (Strech) with all necessary dependencies installed.

Quick start:
#docker pull graph-rrd/apps
#docker run -d -p 8080:80 -p 8081:8081 -p 3000:3000 graph-rrd/apps
- web GUI on http://localhost:8080
- set timezone for running container
- continue to LPAR2RRD and use admin/admin as username/password
- or continue to STOR2RRD and use admin/admin as username/password
- or continue to Grafan on port 3000 and use admin/admin as username/password
