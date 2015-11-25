#!/usr/bin/env python
import sys
import os
from os.path import join, getsize
from ctypes	import *
from string	import *
import types
import os;
import io;
import tempfile;
import struct;

class Partion:
  def __init__(self, label, fstype, size, flag, downloadfile):
    self.label = label
    self.fstype = fstype
    self.size = size
    self.flag = flag
    self.downloadfile = downloadfile


def	CheckKey(line, keyword):
    line_list = [];
    if line.count(keyword)==True :
        line_list = line.split('=');
        if line_list[0].strip() == keyword  :
            return line_list[1].strip();
    return None;

def	OutFile(fileName, partion_list):
    # updpate the property file
    print("out file=" + fileName);
    fp=open(fileName,'w');
    line = '\nSETPATH="..\\out\\boardname\\burn" \n';
    line +='PARTITION_I=0, "MBRC", "./bootloader.bin", "RAW", "IMG", 0x11;\n' ;
    line +='PARTITION_I=1, "BOOT", "./u-boot-dtb.img", "RAW", "IMG", 0x11;\n' ;
    line += '\nSETPATH="."\n';
    fp.write(line);
    num=2;
    for part in partion_list:        
        if part.label == None:
            continue;
        if part.fstype == None:
            continue;
        if part.downloadfile == 'FMT':
            line ='PARTITION_F=%d, "%s", "", "%s", "FMT", 0x1;\n' %(num, part.label, part.fstype);
        elif ( (part.downloadfile == None) or (len(part.downloadfile)==0 ) ) :
            line ='PARTITION_O=%d, "%s", "", "%s", "IMG", 0x20;\n' %(num, part.label, part.fstype);
        else :
            line ='PARTITION_O=%d, "%s", "", "%s", "IMG", 0x1;\n' %(num, part.label, part.fstype);
        fp.write(line);
        num = num + 1;

    fp.write("PARTITION_UDISK_INDEX=12;\n");
    fp.write("PARTITION=1;\n");

    fp.close()
 
if __name__ == '__main__':
    if len(sys.argv) < 3 :
        print 'usage: partions.py input.cfg output.cfg'
        exit(-1)
    
    in_file = sys.argv[1];
    out_file = sys.argv[2];
    print(" careate cfg " + in_file + " to " + out_file);
    fp = open(in_file);
    partion_list=[] ;
    
    bpart = False;
    label = None;
    fstype = None;
    size = None;
    flag = None;
    downloadfile = None;

    while True:
        line = fp.readline();
        if not line:
            break
        if line.strip() == '' or line[0] in '#;//':
            continue

        if line.count('[MBR_INFO]')==True : 
            print "mbr info:";
            bpart = True;
            continue;
        if line.count('[partition]')==True : 
            if bpart == True :
                partion_list.append( Partion(label, fstype, size, flag, downloadfile) );
            bpart = True;
            label = None;
            fstype = None;
            size = None;     
            flag = None;
            downloadfile = None;
            print "partition:";
            continue;
            
        if bpart != True :
            continue;

        tmp = CheckKey(line,'label');
        if tmp != None:
            print("label:" + tmp);
            label = tmp;
            continue;
        tmp = CheckKey(line,'fstype');
        if tmp != None:
            print("fstype:" + tmp);
            fstype = tmp;
            continue;           
        tmp = CheckKey(line,'size');
        if tmp != None:
            print("size:" + tmp);
            size = tmp;
            continue;
        tmp = CheckKey(line,'flag');
        if tmp != None:
            print 'flag:%d'% int(tmp,16);
            flag = tmp;
            continue;
        tmp = CheckKey(line,'downloadfile');
        if tmp != None:
            print("downloadfile:" + tmp);
            downloadfile = tmp;
            continue; 

    if label != None :
        partion_list.append( Partion(label, fstype, size, flag, downloadfile) );
    fp.close();
    OutFile(out_file, partion_list);

    
    
