import json
import os

json_dir = "."
labels = set()

for filename in os.listdir(json_dir):
    if filename.endswith(".json"):
        with open(os.path.join(json_dir, filename), "r") as f:
            data = json.load(f)
            for shape in data["shapes"]:
                labels.add(shape["label"])

with open("labels.txt", "w") as f:
    for label in sorted(labels):
        f.write(f"{label}\n")