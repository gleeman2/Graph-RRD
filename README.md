## Graph from RRD

**Story:**

We were looking for a "first look" troubleshooting/monitoring tool to cover our multivendor storage environment.
Criteria to meet:
1. Must be multivendor
2. Must be able keep trends up to 1 year
3. Must have alerting/reporting capabilities
4. Must be well supported, free and have be future proof
5. Nice to have - Low maintenance and easy to use/configure
6. Nice to have – Support(paid or free) from vendor to modify pull scripts or add new arrays.



**XoruX Docker Image**

Git repo of the Docker image for XoruX applications - LPAR2RRD & STOR2RRD.

This docker image is based on official Debian 8 (Jessie) with all necessary dependencies installed.

Quick start:
#docker run -d -p 8080:80 xorux/apps
- web GUI on http://localhost:8080
- set timezone for running container
- continue to LPAR2RRD and use admin/admin as username/password
- or continue to STOR2RRD and use admin/admin as username/password
