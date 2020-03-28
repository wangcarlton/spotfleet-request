#! /bin/bash
sudo -i
apt-get update -y
apt-get install clamav
pkill freshclam
clamscan > scannedreport.docx