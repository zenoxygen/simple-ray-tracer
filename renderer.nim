import os
import math

import csfml

import vector
import sphere
import light


const width: int = 1024
const height: int = 768
const fov: float = PI / 3.0


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


proc renderer* (w, h: int, spheres: var seq[Sphere], lights: var seq[Light]): Buffer =
  var buf: Buffer = Buffer(width: w, height: h, pixels: newSeq[Color](width * height))

  for j in 0..<height:
    for i in 0..<width:

      var x: float = (2.0 * (i.float + 0.5) / width.float - 1.0) * tan(fov / 2.0)  * width.float / height.float
      var y: float = - (2.0 * (j.float + 0.5) / height.float - 1.0) * tan(fov / 2.0)
      var orig: Vector = newVector(0, 0, 0)
      var dir: Vector = newVector(x, y, -1).normalize()

      buf.pixels[i + j * width] = rayCast(spheres, lights, orig, dir)

  return buf


var spheres: seq[Sphere] = @[]

var red: Color = color(75, 25, 25, 255)
var green: Color = color(25, 75, 25, 255)
var blue: Color = color(25, 25, 75, 255)

var s1: Sphere = newSphere(newVector(-1, -2, -15), 2, red)
spheres.add(s1)

var s2: Sphere = newSphere(newVector(2, -1, -20), 3, blue)
spheres.add(s2)

var s3: Sphere = newSphere(newVector(1, 2, -30), 6, green)
spheres.add(s3)

var lights: seq[Light] = @[]

var l1: Light = newLight(newVector(-20, 20, 20), 2)
lights.add(l1)

var buf: Buffer = renderer(width, height, spheres, lights)
writeImage(buf, "images/step3-add-lighting.png")
