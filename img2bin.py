#!/usr/bin/python3

"""
A script to convert regular images to .coe files used in FPGA chips
Color depth: 12bit (RGB 4+4+4)
Author: Pill
Rev: 0.1.0
"""

import argparse
import os

from PIL import Image


def main():
    parser = argparse.ArgumentParser(
        description='Convert images to bin file, using 12 bits of color depth (RGB4+4+4)')
    parser.add_argument('src', metavar='src', type=str,
                        help='image file you want to convert')
    args = parser.parse_args()
    src = args.src

    image = Image.open(src).convert('RGBA')

    print('Input image: {}x{} pixels'.format(*image.size))

    # remove alpha channel (white background) and output color reduced image for demo
    background = Image.new('RGBA', image.size, (255, 255, 255))
    alpha_composite = Image.alpha_composite(background, image)
    bit_reduced = alpha_composite.point(lambda p: p//16*16)

    filename, suffix = os.path.splitext(src)
    print('Output demo image at:', filename + '.demo' + '.png')
    bit_reduced.save(filename + '.demo' + '.png')

    # generate binary data
    vector_content = list()
    for i in range(image.size[1]):  # height
        for j in range(image.size[0]):  # width
            vector_content += [c//16 for c in bit_reduced.getpixel((j, i))[:3]]
    if len(vector_content) % 2:
        vector_content.append(0)
    binary_content = b''
    for i in range(0, len(vector_content), 2):
        binary_content += bytes([(vector_content[i]<<4)+vector_content[i+1]])
    print('Output bin file at:', src + '.bin')

    with open(src + '.bin', 'wb') as f:
        f.write(binary_content)

    print('.bin file generated. Size: {} kbits'.format(
        round(image.size[0] * image.size[1] * 12 / 1024, 2)))


if __name__ == '__main__':
    main()
