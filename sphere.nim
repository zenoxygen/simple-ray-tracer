import math

import csfml

import vector


type
  Sphere* = object
    center: Vector
    radius: float
    material: Color


proc newSphere* (c: Vector, r: float, mat: Color): Sphere =
  return Sphere(center: c, radius: r, material: mat)


proc rayIntersect* (sphere: Sphere, orig, dir: Vector, t0: var float): bool =
  var l: Vector = sub(sphere.center, orig)
  var tca: float = mulScalar(l, dir)
  var d2: float = mulScalar(l, l) - (tca * tca)

  if d2 > (sphere.radius * sphere.radius):
    return false

  var thc: float = sqrt(sphere.radius * sphere.radius - d2)
  t0 = tca - thc
  var t1: float = tca + thc
  if t0 < 0: t0 = t1
  if t0 < 0:
    return false

  return true


proc sceneIntersect* (spheres: var seq[Sphere], orig, dir: var Vector, mat: var Color): bool =
  var dist: float = high(int).float

  for sphere in spheres:

    if rayIntersect(sphere, orig, dir, dist) == true:
      mat = sphere.material
      return true

  return false


proc rayCast* (spheres: var seq[Sphere], orig, dir: var Vector): Color =
  var mat: Color

  if sceneIntersect(spheres, orig, dir, mat) == false:
    return Black

  return mat
