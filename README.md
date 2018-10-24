## Graph from RRD

**Story:**

AAAA


**XoruX Docker Image**
This is the Git repo of the Docker image for XoruX applications - LPAR2RRD & STOR2RRD.

This docker image is based on official Debian 8 (Jessie) with all necessary dependencies installed.

Quick start:

docker run -d -p 8080:80 xorux/apps
- web GUI on http://localhost:8080
- set timezone for running container
- continue to LPAR2RRD and use admin/admin as username/password
- or continue to STOR2RRD and use admin/admin as username/password
