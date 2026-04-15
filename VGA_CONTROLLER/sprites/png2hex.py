#!/usr/bin/env python3
"""
png2hex.py - convert indexed PNG to readmemh-style .hex file

Usage:
  python3 png2hex.py input.png [output.hex]
  python3 png2hex.py -p 4 input.png output32.hex   # pack 4 pixels/word
  python3 png2hex.py --palette input.png palette.txt  # export palette RGB per line
"""
import argparse
import os
import sys

try:
    from PIL import Image
except Exception as e:
    print("Pillow not installed. Please run: pip3 install --user pillow", file=sys.stderr)
    sys.exit(2)


def parse_args():
    p = argparse.ArgumentParser(description="Convert indexed PNG to .hex for $readmemh")
    p.add_argument("input", help="input PNG (indexed/palette)")
    p.add_argument("output", nargs="?", help="output .hex file (defaults to input.hex)")
    p.add_argument("-p", "--pack", type=int, default=1, help="pixels per hex word (default 1)")
    p.add_argument("--palette", action="store_true", help="also write a palette file (palette.txt)")
    return p.parse_args()


def write_palette(img, outpath):
    pal = img.getpalette()
    if pal is None:
        print("No palette available.")
        return
    rgb = [tuple(pal[i:i+3]) for i in range(0, len(pal), 3)]
    with open(outpath, "w") as f:
        for idx, c in enumerate(rgb):
            f.write("{:03d}: {:3d},{:3d},{:3d}\n".format(idx, c[0], c[1], c[2]))
    print("Wrote palette:", outpath)


def main():
    args = parse_args()
    inp = args.input
    if args.output:
        out = args.output
    else:
        base = os.path.splitext(os.path.basename(inp))[0]
        out = base + ".hex"

    pack = max(1, args.pack)

    img = Image.open(inp)
    if img.mode != "P":
        print("Image mode is '%s' (not palette). Converting to 8-bit adaptive palette." % img.mode)
        img = img.convert("P", palette=Image.ADAPTIVE, colors=256)

    w, h = img.size
    pixels = list(img.getdata())  # row-major

    # write palette if requested
    if args.palette:
        pal_out = os.path.splitext(out)[0] + "_palette.txt"
        write_palette(img, pal_out)

    with open(out, "w") as f:
        i = 0
        total = len(pixels)
        while i < total:
            word = 0
            count = 0
            for j in range(pack):
                if i + j < total:
                    # pack so that first pixel becomes most-significant byte
                    word = (word << 8) | (pixels[i + j] & 0xFF)
                    count += 1
                else:
                    word = (word << 8)
            i += count
            width = 2 * pack
            f.write("{:0{w}X}\n".format(word, w=width))

    print(f"Wrote {out} (size={w}x{h}, pixels={w*h}, pack={pack})")

if __name__ == "__main__":
    main()
