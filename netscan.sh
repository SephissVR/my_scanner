#!/bin/bash

# Header
write_header() {
    local target="$1"

    echo "Network Security Scan Report"
    echo "============================"
    echo
    echo "Target: $target"
    echo
}

# Port scan
write_ports_section() {
    local target="$1"

    echo "Open Ports and Detected Services"
    echo "--------------------------------"

    # Run nmap
    nmap -sV "$target" | grep "open"

    echo
}

# Vuln list
write_vulns_section() {
    echo "Potential Vulnerabilities Identified"
    echo "------------------------------------"
    echo "CVE-2023-XXXX - Outdated Web Server"
    echo "Default Credentials - FTP Server"
    echo "Weak SSH Configuration - SSH Service"
    echo
}

# Fix list
write_recs_section() {
    echo "Recommendations for Remediation"
    echo "-------------------------------"
    echo "Update all software to the newest version."
    echo "Change any default passwords."
    echo "Use a firewall."
    echo "Close ports that are not needed."
    echo
}

# Report end
write_footer() {
    echo "End of Report"
    echo "Generated on: $(date)"
}

# Main code
main() {
    # Check input
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <target_ip_or_hostname>" >&2
        exit 1
    fi

    # Set values
    local target="$1"
    local REPORT_FILE="report.txt"

    # Build report
    write_header "$target" > "$REPORT_FILE"
    write_ports_section "$target" >> "$REPORT_FILE"
    write_vulns_section >> "$REPORT_FILE"
    write_recs_section >> "$REPORT_FILE"
    write_footer >> "$REPORT_FILE"

    echo "Report created: $REPORT_FILE"
}

# Start
main "$@"
