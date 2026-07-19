# Network Vulnerability Scanner and Report Generator

## Overview

This project is a Bash script that uses Nmap to scan a network target. It finds open ports and running services and saves the information into a text report.

## Purpose and Learning

I made this project for my Bash scripting class. It helped me learn Linux commands, Bash scripting, Nmap, network security, Git, GitHub, and how to automate tasks.

## Current Status

The scanner is working and can create a text report. The report shows the target, open ports, detected services, possible security problems, recommendations, and the date it was created.

## Features

* Scans an IP address or hostname.
* Finds open ports and running services.
* Shows service version information.
* Lists possible security problems.
* Creates a text report with basic recommendations.

## Prerequisites

You need these programs installed:

* Bash
* Nmap

## Usage

Make the scripts executable:

    chmod +x netscan.sh scan_report.sh

Run the scanner:

    ./netscan.sh <target_ip_or_hostname>

Example:

    ./netscan.sh scanme.nmap.org

The results will be saved into a text report.

## Future Goals

I want to add better input checking, more accurate vulnerability detection, clearer error messages, and more detailed reports.

## Ethical Considerations

This project is only for school, learning, and authorized security testing. Only scan computers or networks that you own or have permission to test. Scanning without permission can be illegal.

## Author

SephissVR
