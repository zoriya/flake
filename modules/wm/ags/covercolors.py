#! /usr/bin/env python3

from material_color_utilities_python import *
from PIL import Image
import json
import os
import sys
import hashlib

CACHE_DIR = os.path.expanduser("~/.cache/ags/tempcolors")

def cache_and_get_colors(file_path):
	file_hash = hashlib.sha256(file_path.encode('utf-8')).hexdigest()
	cache_path = os.path.join(CACHE_DIR, file_hash[:2], file_hash[2:])

	os.makedirs(cache_path, exist_ok=True)

	colors_path = os.path.join(cache_path, "colors.json")
	if os.path.exists(colors_path):
		with open(colors_path, "r") as f:
			parsed_colors = json.load(f)
	elif not os.path.exists(file_path):
		return None
	img = Image.open(file_path)
	basewidth = 8
	wpercent = (basewidth/float(img.size[0]))
	hsize = int((float(img.size[1])*float(wpercent)))
	img = img.resize((basewidth, hsize), Image.Resampling.LANCZOS)
	theme = themeFromImage(img)

	scheme = theme.get("schemes")

	parsed_colors = {
		"primary": hexFromArgb(scheme.get("dark").primary),
		"onPrimary": hexFromArgb(scheme.get("dark").onPrimary),
		"background": hexFromArgb(scheme.get("dark").background),
		"onBackground": hexFromArgb(scheme.get("dark").onBackground),
	}

	with open(colors_path, "w") as f:
		json.dump(parsed_colors, f)

	return parsed_colors

fn = sys.argv[1]

parsed_colors = cache_and_get_colors(fn)

print(json.dumps(parsed_colors, indent=4))
