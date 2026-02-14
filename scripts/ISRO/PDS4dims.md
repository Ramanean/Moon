PDS4 Dimension Extractor
A lightweight Bash utility designed to recursively scan directories for Chandrayaan-2 (PDS4) XML labels and extract image dimensions (Lines and Samples) using XPath.

Features
Recursive Search: Automatically finds all .xml files in the target folder and all subfolders.

Namespace Aware: Correctly handles pds: and isda: XML namespaces.

Robust Parsing: Uses xmllint and XPath instead of fragile text-matching (like grep).

Clean Output: Generates a tab-separated table for easy viewing or redirection to a file.

Prerequisites
This script requires xmllint, which is part of the libxml2-utils package on Ubuntu.

Bash
sudo apt-get update
sudo apt-get install libxml2-utils
Installation
To install this script as a system-wide command:

Make the script executable:

Bash
chmod +x pds-dims
Move to your local bin directory:

Bash
mkdir -p ~/.local/bin
mv pds-dims ~/.local/bin/
Refresh your shell:

Bash
source ~/.profile
Usage
You can run the program from any directory.

Basic Command
Provide the path to the folder containing your XML files:

Bash
pds-dims /path/to/data
Exporting to CSV
If you want to save the results to a file for use in Excel:

Bash
pds-dims . > metadata_report.csv