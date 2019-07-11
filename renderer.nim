import os

import csfml


const width: int = 1024
const height: int = 768


type
  Buffer* = object
    width, height: int
    pixels: seq[Color]


proc writeImage(buf: Buffer, filename: string) =
  var img: Image = newImage(width.int32, height.int32)

  for j in 0..<height:
    for i in 0..<width:

      setPixel(img, i.int32, j.int32, buf.pixels[i + j * width])

  var splittedFile = splitFile(filename)
  if existsOrCreateDir(splittedFile.dir) == true:
    if saveToFile(img, filename) == true:
      echo "Image successfully saved"


proc renderer* (w, h: int): Buffer =
  var buf: Buffer = Buffer(width: w, height: h, pixels: newSeq[Color](width * height))

  for j in 0..<height:
    for i in 0..<width:

      buf.pixels[i + j * width] = Black

  return buf


var buf: Buffer = renderer(width, height)
writeImage(buf, "images/step1-write-an-image.png")
