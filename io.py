import os
import json
import csv

from pprint import pprint

def get_val(string,s,e):
    parts = string.split("-", 4)  # Split the string at the first two hyphens
    result = "-".join(parts[s:e])  # Join the first two parts with a hyphen
    return result


files=os.listdir("io-benchmarks")
with open("iores.csv","a+") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["group","name","result"])
    for file in sorted(files):
        with open("io-benchmarks/"+file, "r") as f:
            j=json.load(f)
            res=''
            if "write" in file:
                res=j['jobs'][0]['write']['iops']
            if "read" in file:
                res=j['jobs'][0]['read']['iops']
            writer.writerow([get_val(file,1,2),get_val(file,2,4), res])