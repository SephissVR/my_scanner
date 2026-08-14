# Network Vulnerability Scanner

## Overview

This project is a Bash script that uses Nmap to scan an IP address or hostname. It finds open ports, running services, possible vulnerabilities, and creates a report.txt file.

## Features

- Scans an IP address or hostname
- Finds open ports and services
- Detects service versions
- Uses Nmap NSE vulnerability scripts
- Checks service versions for known vulnerabilities
- Uses the NVD API to find CVEs
- Shows CVE IDs, descriptions, and severity
- Creates a report.txt file
- Gives basic security recommendations
- Includes input validation and error handling

## Requirements

You need:

- Bash
- Nmap
- curl
- jq
- Internet access for the NVD API

## How to Run

Make the script executable:

    chmod +x netscan.sh

Run it with an IP address or hostname:

    ./netscan.sh <target>

Example:

    ./netscan.sh 127.0.0.1

## Nmap Commands

The script uses:

    nmap -sV --script vuln <target>

`-sV` detects the service and version running on open ports.

`--script vuln` runs Nmap NSE scripts that look for possible vulnerabilities.

## How Vulnerabilities Are Found

The script checks the services and versions found by Nmap. It can match known vulnerable versions with CVEs.

It also uses Nmap NSE scripts and the National Vulnerability Database (NVD) API. The NVD lookup can return CVE IDs, descriptions, and severity levels.

These results are possible vulnerabilities. A CVE match does not always mean the computer can actually be exploited.

## Report

The script creates a report.txt file that includes:

- Target IP or hostname
- Open ports
- Detected services
- Possible vulnerabilities
- NVD CVE results
- Severity
- Security recommendations
- Date the report was created

## Recommendations

Some recommendations the scanner can give are:

- Update old software
- Install security patches
- Change default passwords
- Close ports that are not needed
- Use a firewall

## Ethical Considerations

Only scan computers or networks that you own or have permission to test. Scanning systems without permission can be illegal. This project was made for school, learning, and authorized security testing.

## Author

Anastasia Casagrande
