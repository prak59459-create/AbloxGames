#!/usr/bin/env python3
"""Writes raw 8-bit RGB as a PNG, with nothing but the standard library.

    png.py <raw rgb file> <width> <height> <out.png>

The catalogue generator renders covers in Swift on Linux, where there is no
image library; this is the one step that needs zlib.
"""
import struct
import sys
import zlib


def chunk(kind, data):
    body = kind + data
    return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)


def main():
    raw_path, width, height, out_path = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
    with open(raw_path, "rb") as f:
        rgb = f.read()
    stride = width * 3
    assert len(rgb) == stride * height, "size does not match"
    rows = bytearray()
    previous = bytes(stride)
    for y in range(height):
        row = rgb[y * stride:(y + 1) * stride]
        # "Up" filter: each byte minus the one above. Flat-shaded pictures
        # are mostly runs of the same colour, which this turns into zeros.
        rows.append(2)
        rows += bytes((a - b) & 0xFF for a, b in zip(row, previous))
        previous = row
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(rows), 9))
    png += chunk(b"IEND", b"")
    with open(out_path, "wb") as f:
        f.write(png)


if __name__ == "__main__":
    main()
