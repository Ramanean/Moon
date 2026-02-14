PDS4 Dimension Extractor (pds-dims)
A high-performance Bash utility designed to recursively scan directories for ISRO Chandrayaan-2 (PDS4) XML labels and extract critical image dimensions (Lines and Samples).

🚀 Features
Recursive Scan: Automatically traverses folders and subfolders to find every .xml file.

Dependency-Free: Built using raw shell commands (grep, sed)—no external XML libraries or Python required.

Namespace-Aware Logic: Specifically designed to navigate the structure of PDS4 observational products used by ISRO.

Tabulated Output: Generates a clean, readable table ideal for terminal viewing or piping into a .csv for Excel.

📋 Prerequisites
The script uses standard Unix utilities available on all Ubuntu/Linux distributions:

bash

grep

sed

find

⚙️ Installation
You can install this as a standalone program on your local Ubuntu machine using our automated installer.

1. Download and Install
Run the following command to download the installer and set up the program in your local path:

Bash
curl -sSL https://raw.githubusercontent.com/Ramanean/Moon/main/scripts/ISRO/install-pds-dims.sh | bash
2. Activate
After installation, refresh your shell to recognize the new command:

Bash
source ~/.bashrc
📖 Usage
Once installed, you can run the program from any directory by typing pds-dims.

Scan Current Directory
Bash
pds-dims .
Scan a Specific Data Folder
Bash
pds-dims /path/to/isro/data
Export Results to CSV
Bash
pds-dims /path/to/data > dimensions_report.csv
🛠️ How it Works
The script targets the Axis_Array components of the PDS4 XML schema. It identifies the specific axis (Line or Sample) and extracts the numeric value from the associated <elements> tag using a contextual search logic:

Targeting Lines: Searches for the value immediately following <axis_name>Line</axis_name>.

Targeting Samples: Searches for the value immediately following <axis_name>Sample</axis_name>.

🤝 Contributing
Feel free to fork this repository and submit pull requests for any improvements, such as adding support for metadata like start_date_time or spacecraft_altitude.

📄 License
This project is open-source and available under the MIT License.