import csv
import os
import shutil

# Store entries from the file
entries = {}

# Read the spreadsheet and populate the dictionary
with open('master.tsv', 'r') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t')
    next(reader, None)  # Skip the header row
    for row in reader:
        if len(row) >= 2:  
            key = row[0]
            value = row[1]
            entries.setdefault(key, []).append(value)
        else:
            print("Skipped incomplete row:", row)

# Write dictionary entries to text files
for key, values in entries.items():
    with open(f"{key.lower()}.txt", 'w') as outfile:
        outfile.writelines(f"{value}\n" for value in values)

# Create directories and move text files into them
for key in entries.keys():
    directory = key.lower()
    file_name = f"{directory}.txt"
    os.makedirs(directory, exist_ok=True)
    shutil.move(file_name, directory)

