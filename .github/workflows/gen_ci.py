#!/usr/bin/env python

from os import path
from jinja2 import Environment, FileSystemLoader
import json

workdir = path.dirname(__file__)
with open(path.join(workdir, "targets.json")) as f:
    targets = json.load(f)

env = Environment(loader=FileSystemLoader(workdir), autoescape=False)
template = env.get_template("ci.yml.jinja")
contents = template.render(targets=targets)
with open(path.join(workdir, "ci.yml"), "w") as f:
    f.write(contents)
