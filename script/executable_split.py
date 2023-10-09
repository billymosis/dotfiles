#!/usr/bin/env python3

import os
import sys
from PIL import Image

if len(sys.argv) != 2:
    print("Usage: python sprite_splitter.py <input_image.png>")
    sys.exit(1)

input_file = sys.argv[1]

try:
    # Load the PNG image
    image = Image.open(input_file)

    # Extract the filename without extension
    filename_without_extension = os.path.splitext(input_file)[0]

    # Create a directory with the same name as the input file (without extension)
    os.makedirs(filename_without_extension, exist_ok=True)

    # Specify the dimensions of each individual sprite
    sprite_width = 48
    sprite_height = 48

    # Loop through the grid and extract each sprite
    for row in range(0, image.height, sprite_height):
        for col in range(0, image.width, sprite_width):
            # Define the region to crop
            left = col
            upper = row
            right = col + sprite_width
            lower = row + sprite_height

            # Crop the sprite
            sprite = image.crop((left, upper, right, lower))

            # Construct the filename for the sprite
            sprite_filename = f'sprite_{row // sprite_height + 1}_{col // sprite_width + 1}.png'

            # Save the sprite inside the directory
            sprite.save(os.path.join(filename_without_extension, sprite_filename))

    print("Sprites extracted and saved in directory:", filename_without_extension)
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
