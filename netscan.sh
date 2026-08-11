#!/bin/bash

SCAN_RESULTS=""

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
    echo "Open Ports and Detected Services"
    echo "--------------------------------"

    echo "$SCAN_RESULTS" | grep -E '^[0-9]+/(tcp|udp)[[:space:]]+open' || \
        echo "No open ports found."

    echo
}

# NVD lookup
query_nvd() {
    local product="$1"
    local version="$2"
    local results_limit=3

    echo
    echo "Querying NVD for vulnerabilities in: $product $version..."

    local search_query
    search_query=$(echo "$product $version" | sed 's/ /%20/g')

    local nvd_api_url

    # Exact CPE for OpenSSH 7.6p1
    if [ "$product" = "OpenSSH" ] && [ "$version" = "7.6p1" ]; then
        nvd_api_url="https://services.nvd.nist.gov/rest/json/cves/2.0?cpeName=cpe:2.3:a:openbsd:openssh:7.6:p1:*:*:*:*:*:*&resultsPerPage=${results_limit}"
    else
        nvd_api_url="https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=${search_query}&resultsPerPage=${results_limit}"
    fi

    local vulnerabilities_json

    # Get NVD data
    if ! vulnerabilities_json=$(curl -sS --fail --max-time 20 "$nvd_api_url"); then
        echo "  [!] Error: Failed to fetch data from NVD."
        return
    fi

    # JSON check
    if ! echo "$vulnerabilities_json" | jq -e . > /dev/null 2>&1; then
        echo "  [!] Error: Invalid JSON from NVD."
        return
    fi

    # API error
    local api_message
    api_message=$(echo "$vulnerabilities_json" | jq -r '.message // empty')

    if [ -n "$api_message" ]; then
        echo "  [!] NVD API Error: $api_message"
        return
    fi

    # No results
    if ! echo "$vulnerabilities_json" | \
        jq -e '.vulnerabilities | length > 0' > /dev/null 2>&1; then

        echo "  [+] No vulnerabilities found in NVD."
        return
    fi

    # CVE results
    echo "$vulnerabilities_json" | jq -r '
        .vulnerabilities[] |
        "  CVE ID: \(.cve.id)
  Description: \(([.cve.descriptions[]? |
      select(.lang=="en") |
      .value][0] // "No description") | gsub("\n"; " "))
  Severity: \(
      .cve.metrics.cvssMetricV40[0].cvssData.baseSeverity //
      .cve.metrics.cvssMetricV31[0].cvssData.baseSeverity //
      .cve.metrics.cvssMetricV30[0].cvssData.baseSeverity //
      .cve.metrics.cvssMetricV2[0].baseSeverity //
      "N/A"
  )
---"'
}

# Vuln list
write_vulns_section() {
    echo "Potential Vulnerabilities Identified"
    echo "------------------------------------"

    echo "NSE Vulnerability Results"
    echo

    echo "$SCAN_RESULTS" | grep "VULNERABLE" || \
        echo "No vulnerabilities directly found by NSE."

    echo
    echo "Analyzing Service Versions"
    echo

    # Local checks
    while IFS= read -r line; do

        case "$line" in

            *"vsftpd 2.3.4"*)
                echo "[!!] VULNERABILITY DETECTED: vsftpd 2.3.4"
                echo "Known backdoor - CVE-2011-2523"
                ;;

            *"Apache httpd 2.4.49"*)
                echo "[!!] VULNERABILITY DETECTED: Apache 2.4.49"
                echo "Path traversal - CVE-2021-41773"
                ;;

            *"ProFTPD 1.3.5"*)
                echo "[!!] VULNERABILITY DETECTED: ProFTPD 1.3.5"
                echo "mod_copy vulnerability - CVE-2015-3306"
                ;;

        esac

    done <<< "$SCAN_RESULTS"

    echo
    echo "Live NVD Vulnerability Lookup"
    echo "-----------------------------"

    local query_count=0
    local product_name=""
    local product_version=""

    # Service parsing
    while IFS= read -r line; do

        product_name=""
        product_version=""

        case "$line" in

            *"OpenSSH "*)
                product_name="OpenSSH"
                product_version=$(echo "$line" | \
                    sed -n 's/.*OpenSSH \([^ ]*\).*/\1/p')
                ;;

            *"Apache httpd "*)
                product_name="Apache httpd"
                product_version=$(echo "$line" | \
                    sed -n 's/.*Apache httpd \([^ ]*\).*/\1/p')
                ;;

            *"vsftpd "*)
                product_name="vsftpd"
                product_version=$(echo "$line" | \
                    sed -n 's/.*vsftpd \([^ ]*\).*/\1/p')
                ;;

            *"ProFTPD "*)
                product_name="ProFTPD"
                product_version=$(echo "$line" | \
                    sed -n 's/.*ProFTPD \([^ ]*\).*/\1/p')
                ;;

        esac

        if [ -n "$product_name" ] && [ -n "$product_version" ]; then

            query_nvd "$product_name" "$product_version"

            query_count=$((query_count + 1))

            if [ "$query_count" -ge 2 ]; then
                break
            fi
        fi

    done < <(
        echo "$SCAN_RESULTS" |
        grep -E '^[0-9]+/(tcp|udp)[[:space:]]+open'
    )

    if [ "$query_count" -eq 0 ]; then
        echo "No supported service versions found for NVD lookup."
    fi

    echo
}

# Fix list
write_recs_section() {
    echo "Recommendations for Remediation"
    echo "-------------------------------"
    echo
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

    # Check tools
    if ! command -v nmap > /dev/null 2>&1; then
        echo "Error: nmap is not installed."
        exit 1
    fi

    if ! command -v curl > /dev/null 2>&1; then
        echo "Error: curl is not installed."
        exit 1
    fi

    if ! command -v jq > /dev/null 2>&1; then
        echo "Error: jq is not installed."
        echo "Install with: sudo apt install jq"
        exit 1
    fi

    # Set values
    local target="$1"
    local REPORT_FILE="report.txt"

    echo "Scanning $target..."
    echo "This may take a while."

    # Nmap scan
    if ! SCAN_RESULTS=$(nmap -sV --script vuln \
        --script-timeout 30s "$target"); then

        echo "Nmap scan failed."
        exit 1
    fi

    # Build report
    write_header "$target" > "$REPORT_FILE"
    write_ports_section >> "$REPORT_FILE"
    write_vulns_section >> "$REPORT_FILE"
    write_recs_section >> "$REPORT_FILE"
    write_footer >> "$REPORT_FILE"

    echo "Report created: $REPORT_FILE"
}

# Start
main "$@"
