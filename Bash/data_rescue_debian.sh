#!/bin/bash
echo "Updating Repositories..."
sudo apt update -y
echo "Installing ddrescue and ddrescueview (for mapfiles)"
sudo apt install gddrescue ddrescueview -y
echo "Downloading DMDE 4.2.2"
wget https://dmde.com/download/dmde-4-2-2-816-lin64-gui.zip
echo "Unzipping to dmde"
sudo apt install unzip
unzip ./dmde-4-2-2-816-lin64-gui.zip -d ./dmde

