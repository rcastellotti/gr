import os
import json
import csv

from pprint import pprint


def get_val(string, s, e):
    parts = string.split("-", 4)  # Split the string at the first two hyphens
    result = "-".join(parts[s:e])  # Join the first two parts with a hyphen
    return result


files = os.listdir("benchmarks")
al_results = csv.writer(open("benchmarks/al_results.csv", "a+"))
bw_results = csv.writer(open("benchmarks/bw_results.csv", "a+"))
iops_results = csv.writer(open("benchmarks/iops_results.csv", "a+"))
al_results.writerow(["group", "name", "result"])
bw_results.writerow(["group", "name", "result"])
iops_results.writerow(["group", "name", "result"])

for file in sorted(files):
    with open("io-benchmarks/" + file, "r") as f:
        j = json.load(f)
        res = ""
        if "write" in file and "iops" in file:
            res = j["jobs"][0]["write"]["iops"]
            print(f"accessing file: {file} and retrieving {res}")

        if "write" in file and "bw" in file:
            res = j["jobs"][0]["write"]["bw_bytes"]
            print(f"accessing file: {file} and retrieving {res}")

        if "write" in file and "al" in file:
            res = j["jobs"][0]["write"]["clat_ns"]["mean"]
            print(f"accessing file: {file} and retrieving {res}")

        if "read" in file and "iops" in file:
            res = j["jobs"][0]["read"]["iops"]
            print(f"accessing file: {file} and retrieving {res}")

        if "read" in file and "bw" in file:
            res = j["jobs"][0]["read"]["bw_bytes"]
            print(f"accessing file: {file} and retrieving {res}")


        if "read" in file and "al" in file:
            res = j["jobs"][0]["read"]["clat_ns"]["mean"]
            print(f"accessing file: {file} and retrieving {res}")

        row=[get_val(file, 0, 1), os.path.splitext(get_val(file, 1, 3))[0], res]
        if "bw" in file:
            bw_results.writerow(row)
        elif "iops" in file:
            iops_results.writerow(row)
        else:
            al_results.writerow(row)
