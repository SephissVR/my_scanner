#!/bin/bash

write_header() {
    target="$1"

    echo "Network Security Scan Report"
    echo "============================"
    echo ""
    echo "Target: $target"
    echo ""
}

write_ports_section() {
    echo "Open Ports and Detected Services"
    echo "--------------------------------"
    echo "Port 80/tcp - http"
    echo "Port 443/tcp - https"
    echo "Port 22/tcp - ssh"
    echo ""
}

write_vulns_section() {
    echo "Potential Vulnerabilities Identified"
    echo "------------------------------------"
    echo "CVE-2023-XXXX - Outdated Web Server"
    echo "Default Credentials - FTP Server"
    echo "Weak SSH Configuration - SSH Service"
    echo ""
}

write_recs_section() {
    echo "Recommendations for Remediation"
    echo "-------------------------------"
    echo "Update all software to the newest version."
    echo "Change any default passwords."
    echo "Use a firewall."
    echo "Close ports that are not needed."
    echo ""
}

write_footer() {
    echo "End of Report"
    echo "Generated on: $(date)"
}

main() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <target_ip_or_hostname>" >&2
        exit 1
    fi

    target="$1"
    REPORT_FILE="report.txt"

    write_header "$target" > "$REPORT_FILE"
    write_ports_section >> "$REPORT_FILE"
    write_vulns_section >> "$REPORT_FILE"
    write_recs_section >> "$REPORT_FILE"
    write_footer >> "$REPORT_FILE"

    echo "Report made and saved to $REPORT_FILE"
}

main "$@"
