#!/usr/bin/env python

from jinja2 import Environment, FileSystemLoader
import json

with open(f"targets.json") as f:
    targets = json.load(f)

env = Environment(loader=FileSystemLoader(f"."), autoescape=False)
template = env.get_template("ci.yml.jinja")
contents = template.render(targets=targets)
with open("ci.yml", "w") as f:
    f.write(contents)
