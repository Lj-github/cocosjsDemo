# -*- coding: utf-8 -*-
# @Time    : 18/4/9 下午6:54
# @Author  : myTool
# @File    : MakeFileList.py
# @Software: PyCharm
#  将src下的所有js文件写入加载json
import os
import json
import sys

def GetFileList(dir, fileList):
    newDir = dir
    if os.path.isfile(dir):
        fileList.append(dir.decode('utf-8'))
    elif os.path.isdir(dir):
        for s in os.listdir(dir):
            newDir = os.path.join(dir, s)
            GetFileList(newDir, fileList)
    return fileList
def getFileStrLen(path):
    if path :
        return  path.decode('utf-8').__len__()

try:
    #获取当前路径
    path = sys.path[0] + "/res"
    allJsList = GetFileList(path,[])
    if allJsList:
        with open("project.json", 'r') as f:
            oldJson = json.loads(f.read().encode('utf8'))
            newJson = oldJson
            newJson["jsList"] = []
            for jsfil in allJsList:
                newJson["jsList"].append(jsfil[getFileStrLen(sys.path[0])+1:])
            with open("project.json", 'w') as f:
                json.dump(newJson, f)

except NameError:
    pass