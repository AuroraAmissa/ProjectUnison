import glob
import json

files = {}

for file in glob.glob("site/content/*/*.md"):
    contents = open(file, "r").read()

    title = None
    for line in contents.split("\n"):
        if line.startswith("# "):
            title = line[2:]

    if title:
        files[title.lower()] = "/".join(file.split("/")[-2:])
        files[title.lower().replace(" ", "%20")] = "/".join(file.split("/")[-2:])

open("build/pages.json", "w").write(json.dumps(files))
print(files)
