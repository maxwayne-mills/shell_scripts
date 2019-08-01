#!/usr/bin/env python3
# Author: Clarence Mils
''' Backup local Google drive to cloud ''' 

import os
import subprocess

backup_dirs = ['/home/cmills/Documents/google_drive_clarence_mills','/home/cmills/Documents/google_drive_oss']

def main():
    for backup_items in backup_dirs:
        subprocess.call('clear')
        print('Backuping up google drive: ' + backup_items + '\n')
        os.chdir(backup_dirs[0])
        #subprocess.Popen('make')
        subprocess.call('make')

# Run program
main()