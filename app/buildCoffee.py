# -*- coding: utf-8 -*-
# @Time    : 2018/10/8 上午11:32

# 没次  不需要吧全部的coffee  都编译一遍  只需要编译改过的
import os
import json
import hashlib
import shutil

def shortMD5(md5):
    chars = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
             "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
             "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7",
             "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
             "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
             "W", "X", "Y", "Z"]
    sTempSubString = md5[8:16]
    lHexLong = 0x3FFFFFFF & int(sTempSubString, 16);
    outChars = "";
    for i in range(0, 6):
        index = 0x0000003D & lHexLong
        outChars = outChars + chars[index]
        lHexLong = lHexLong >> 5
    return outChars


def get_file_md5(file_path):
    if not os.path.isfile(file_path):
        return
    myhash = hashlib.md5()
    f = open(file_path, 'rb')
    while True:
        b = f.read(8192)
        if not b:
            break
        myhash.update(b)
    f.close()
    return myhash.hexdigest()


def GetFileList(dir, fileList):
    newDir = dir
    if os.path.isfile(dir):
        fPath, fName = os.path.split(dir)
        fType = fName.split(".").pop()
        if fType in ["coffee"]:
            fileList.append(dir)

    elif os.path.isdir(dir):
        for s in os.listdir(dir):
            newDir=os.path.join(dir,s)
            GetFileList(newDir, fileList)
    return fileList

def getManifest_tsJson(fileName):
    if not os.path.isfile(fileName):
        with open(fileName, 'w') as f:
            f.write("{}")
        return None
    with open(fileName, 'r') as f:

        return json.load(f)

def getValFormListByKey(list,key):
    if not list:
        return None
    for k in list:
        if key == k:
            return list[k]
    return None

def createJsonFile(jsonObj,filename):
    if not os.path.isfile(filename):
        os.mknod(filename)
    with open(filename, 'w') as f:
        json.dump(jsonObj, f, sort_keys=True, indent=4, separators=(',', ':'))

def mkdir(path):
    path = path.strip()
    path = path.rstrip("\\")
    isExists = os.path.exists(path)
    if not isExists:
        os.makedirs(path)
        return True
    else:
        return False

def movefile(srcfile, dstfile):
    if not os.path.isfile(srcfile):
        print("%s not exist!" % (srcfile))
    else:
        fpath, fname = os.path.split(dstfile)
        if not os.path.exists(fpath):
            '''创建路径'''
            mkdir(fpath)
        '''复制文件'''
        shutil.move(srcfile, dstfile)
        print("move %s -> %s" % (srcfile, dstfile))
if __name__ == '__main__':
    print("begin build coffee to js")
    filee = os.path.realpath(__file__)
    fpath,fname = os.path.split(filee)
    egretProFile = fpath + "/app/"
    allTSFile = GetFileList(egretProFile+ "static/coffee/",[])
    # 去掉开头
    rep = []
    for k in range(len(allTSFile) ):
        rep.append(allTSFile[k].replace(fpath, ""))
    allTSFile = rep
    manifest_tsJSONFile = fpath + "/manifest_coffee.json"
    allTSFileMd5_old = getManifest_tsJson(manifest_tsJSONFile)
    endMd5Table = {}
    for k in range(len(allTSFile) ) :
        fileN = fpath + allTSFile[k]
        tsFileMd5_new = shortMD5(get_file_md5(fileN))
        tsFileMd5_old = getValFormListByKey(allTSFileMd5_old,allTSFile[k])
        if tsFileMd5_new != tsFileMd5_old:
            print("build ts =>" + fileN)
            #shStr = "tsc " + fileN + " --allowUnreachableCode true --allowUnusedLabels true --allowSyntheticDefaultImports true"
            #coffee -m -c -o static/coffee/commons/ static/coffee/commons/Display.coffee
            scriptFilePath ,scriptFileName= os.path.split( fileN.replace("/coffee/","/script/"))
            shStr = "coffee -m -c -o " +scriptFilePath + " " + fileN
            os.system(shStr)
            movefile(fileN.replace(".ts",".js"), fileN.replace("/src/","/bin-debug/").replace(".ts",".js"))
        endMd5Table[allTSFile[k]] = tsFileMd5_new
        #allTSFile[allTSFile[k]] = tsFileMd5_new

    createJsonFile(endMd5Table, manifest_tsJSONFile)
    print("build js success")