import argparse 
import csv

parser = argparse.ArgumentParser(prog="ratios")
parser.add_argument("--file", "-f", help="the csv file to use", required=True, type=str)
parser.add_argument("--output", "-o", help="name", required=True, type=str)
args = parser.parse_args()


with open(args.file) as f:    
    lines=f.readlines()[1:]
    ratios = []
    for i in range(len(lines) - 1):
        if i%2==0:
            group, name, value1 = lines[i].split(',')
            _, _, value2 = lines[i + 1].split(',')
            ratio = float(value2) / float(value1)
            ratios.append([group,name.split("-")[0],ratio])
    
    with open(f"benchmarks/{args.output}-ratios.csv", "w") as c:
        csv_writer = csv.writer(c)
        csv_writer.writerow(["group","name","result"])
        for ratio in ratios:
            print(f"{ratio}")
            csv_writer.writerow(ratio)
