import os
import json
import csv

from pprint import pprint

def get_val(string,s,e):
    parts = string.split("-", 4)  # Split the string at the first two hyphens
    result = "-".join(parts[s:e])  # Join the first two parts with a hyphen
    return result


files=os.listdir("io-benchmarks")
al_results=csv.writer(open("al_results.csv","a+"))
bw_results=csv.writer(open("bw_results.csv","a+"))
iops_results=csv.writer(open("iops_results.csv","a+"))
al_results.writerow(["group","name","result"])
bw_results.writerow(["group","name","result"])
iops_results.writerow(["group","name","result"])

for file in sorted(files):
    with open("io-benchmarks/"+file, "r") as f:
        j=json.load(f)
        res=''
        if "write" in file:
            res=j['jobs'][0]['write']['iops']
        if "read" in file:
            res=j['jobs'][0]['read']['iops']
        if "bw" in file:
            bw_results.writerow([get_val(file,0,1),get_val(file,1,3), res])
        elif "iops" in file:
            iops_results.writerow([get_val(file,0,1),get_val(file,1,3), res])
        else:
            al_results.writerow([get_val(file,0,1),get_val(file,1,3), res])