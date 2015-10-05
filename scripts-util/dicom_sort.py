#!/usr/bin/env python

import sys
import os, os.path
import dicom
import shutil
"""



"""
#This script will take a directory of dicoms and sort them into different subfolders within the output folder
#corresponding to their SeriesDescription


usage = """
Usage:
python dicom_sort.py originals_directory sorted_directory
"""


if __name__ == "__main__":
#if not 2 arguments, give usage
    if len(sys.argv) != 3:
        print usage
        sys.exit()

    arg1, arg2 = sys.argv[1:]
    if os.path.isdir(arg1):# is arg1 a legal directory?
        in_dir = arg1
        out_dir = arg2
        if os.path.exists(out_dir): # does the output directory exist?
            if not os.path.isdir(out_dir):#make sure there is not already a file with your intended output directory name
                raise IOError, "Input is directory; output name exists but is not a directory"
		print "Input is directory; output name exists but is not a directory"
        else: # if out_dir does not exist; creates it.
            os.makedirs(out_dir)

       # rootdir = in_dir
        #filenames = os.listdir(in_dir)
	for dirName, subdirList, fileList in os.walk(in_dir): #search directories recursively
        	for filename in fileList:
            		dataset = dicom.read_file(os.path.join(dirName, filename), None, False, True) #read in the dicom
           		#print filename + "..."
			if "SeriesDescription" in dataset:
				print filename + "..."
				parts = [str(dataset.SeriesNumber), str(dataset.SeriesDescription)]
				foldername = "_".join (parts)
				if os.path.isdir(os.path.join(out_dir,foldername)): #is there already a directory for that series description?
                   			shutil.copyfile(os.path.join(dirName, filename),os.path.join(out_dir,foldername,filename))#if yes, copy
               			else:
                    			os.makedirs(os.path.join(out_dir,foldername)) #if no, make that directory
                   			shutil.copyfile(os.path.join(dirName, filename),os.path.join(out_dir,foldername,filename))#and then copy
			if "SeriesDescription" not in dataset:
				print filename + " has no series description - has not been sorted"
                print "done\r"
	for d in os.listdir(out_dir):
		filename = list(d)	#change file/directory name to list
		index = 0
		change = 0
		for character in filename:	#inspect characters in the filename for spaces
			if character == ' ':
				filename[index]='_'	#replace spaces with underscores
				change = 1
			index = index + 1
		if change == 1:				#only change filename if there were spaces
			print d + ' has been renamed.'
			os.rename(os.path.join(out_dir,d), os.path.join(out_dir,''.join(filename)))

    print

