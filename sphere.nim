import math

import csfml

import vector
import light


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


proc sceneIntersect* (spheres: var seq[Sphere], orig, dir, p, n: var Vector, mat: var Color): bool =
  var distSpheres: float = high(int).float

  for sphere in spheres:

    var dist: float

    if rayIntersect(sphere, orig, dir, dist) == true and dist < distSpheres:
      distSpheres = dist
      p = add(orig, mul(dir, dist))
      n = sub(p, sphere.center).normalize()
      mat = sphere.material

  return distSpheres < 1000


proc rayCast* (spheres: var seq[Sphere], lights: var seq[Light], orig, dir: var Vector): Color =
  var p, n: Vector
  var mat: Color

  if sceneIntersect(spheres, orig, dir, p, n, mat) == false:
    return Black

  var intensity: float

  for light in lights:
    var dirLight: Vector = sub(light.position, p).normalize()
    intensity = intensity + light.intensity * max(0.1, mulScalar(dirLight, n))

  var tmp: Vector = mul(newVector(mat.r.float, mat.g.float, mat.b.float), intensity)
  var final: Color = color(tmp.x.int, tmp.y.int, tmp.z.int, 255)

  return final
