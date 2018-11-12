# Graph from RRD

**Story:**

We were looking for a "first look" troubleshooting/monitoring tool to cover our multivendor storage environment.
Criteria to meet:
1. Must be multivendor
2. Must be able keep trends (Capacity, IO, etc) up to 1 year
3. Must have alerting/reporting capabilities
4. Must be well supported, free'ish and have be future proof
5. Nice to have - Low maintenance and easy to use/configure
6. Nice to have – Support(paid or free) from vendor to modify pull scripts or add new arrays.

There was no one app out there to fill all the criteria, but we came close anough with using stor2rrd, Grafana and Graphite. The rest of the readme covers the lessosn learned and the end results that is my current working solution. This document will be focused around INFINIDAT monitoring, reporting and alerting.



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



**Grafana**

Grafana is a better graphical tool to represent the data captured by Stor2rrd. Grafana cannot directly read RRD databases, but Graphite can and as it happens Grafana can read from Graphite and whola, we have graphs.

![Grafana](https://github.com/gleeman2/Graph-RRD/blob/master/Graph-RRD.png "Grafana Dashboard example")



**Putting it together**

A lot of work has already been done on the indiviual packages, so not to reinvent the wheel, we went the docker way and used pre confgured images.

1. Get docker up and running. Make sure that docker-compose are part of your install.
  - Here is how to intall it on Ubuntu 18.x https://computingforgeeks.com/installing-docker-ce-ubuntu-debian-fedora-arch-centos/
2. Git the compose file and relevent configuration files from https://github.com/gleeman2/Graph-RRD/ by either cloning (git https://github.com/gleeman2/Graph-RRD.git) or download the zip file.
  - See " Cloning and Existing Repository" at https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository
  - Create new direcorty and cd into it.
  - Run "_git clone https://github.com/gleeman2/Graph-RRD.git_"
3. To start the containers run _#docker-compose up -d_ in the folder the docker-compose.yml file is located.
  - web GUI on http://localhost:8080
    - set timezone for running container
  - continue to STOR2RRD http://localhost:8080/stor2rrd and use admin/admin as username/password
  - or continue to Graphite http://localhost:8081
  - or continue to Grafana on port http://localhost:3000 and use admin/admin as username/password
  - Persistent volumes are located at _./rrddata_ and _./rrdetc_ on local system (it contains the RRD and etc files)
4. Stor2rrd setup
  - Follow instructions from http://www.stor2rrd.com/INFINIDAT-Infinibox-monitoring.htm
  - Create encrypted stor2rrd password
    - $ cd /home/stor2rrd/stor2rrd
    - $ perl bin/spasswd.pl
  - example of Infinibox entryin etc files (etc file is stored at _/home/stor2rrd/stor2rrd/etc/storage-config.cfg_)
    - _Infinibox_2990:INFINIBOX:192.168.0.11:stor2rrd:KT4mXVIssss0BUPjZdVQo=_
  - Check new config:
    - $ cd /home/stor2rrd/stor2rrd
    - $ ./bin/config_check.sh Infinibox_2990
4. Grafana setup.
  - Login http://localhost:3000 and use admin/admin
  - Goto Configuration/Data sources
    - Name = Stor2RRD
    - URL = http://localhost:8080
    - Access = Server
    - Select "Save & Test"



**Lets Use it!**

1. Login to http://localhost:8080/stor2rrd
  -
2. Login to http://localhost:3000
3.



**Lessons Learned**

- Not to reinvent the wheel and use what has already been proved stable.
- Password for user(_lpar2rrd_) polling the array:

```
 $ cd /home/stor2rrd/stor2rrd
 $ perl bin/spasswd.pl

    Encode password for storage authentication:
    -------------------------------------------
    Enter password:
    Re-enter password:

    Copy the following string to the password field of the corresponding line in etc/storage-list.cfg:

    //KT4mXVI9N0BUPjZdVQo=\\

```
- Symlinks for Stor2rrd to Graphite to Grapana
 Grafana has to read from Graphite and Graphite is rading from the stor2rrd RRD database at /home/stor2rrd/stor2rrd/data

4. Connect to image http://localhost:8080





**XoruX/Grafana Docker and GitHub Image**

Git repo of the Docker image for XoruX applications - LPAR2RRD & STOR2RRD.(https://github.com/gleeman2/Graph-RRD)

This docker image is based on official Debian 8 (jessie) with all necessary dependencies installed.

Using images from graphite-project/docker-graphite-statsd forked from hopsoft/docker-graphite-statsd

Quick start:
_#docker-compose up -d_
- web GUI on http://localhost/stor2rrd
- set timezone for running container
- continue to LPAR2RRD and use admin/admin as username/password
- or continue to STOR2RRD and use admin/admin as username/password
- or continue to Graphite http://localhost:8081
- or continue to Grafana on port http://localhost:3000 and use admin/admin as username/password
