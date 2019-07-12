import math

import csfml

import vector
import light
import material


type
  Sphere* = object
    center: Vector
    radius: float
    material: Material


proc newSphere* (c: Vector, r: float, mat: Material): Sphere =
  return Sphere(center: c, radius: r, material: mat)


proc reflect* (incident: Vector, normal: Vector): Vector =
  return sub(mul(mul(normal, mulScalar(incident, normal)), 2.0), incident)


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


proc sceneIntersect* (spheres: var seq[Sphere], orig, dir, p, n: var Vector, mat: var Material): bool =
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
  var point, normal: Vector
  var mat: Material

  if sceneIntersect(spheres, orig, dir, point, normal, mat) == false:
    return Black

  var diffuseIntensity: float
  var specularIntensity: float

  for light in lights:

    var dirLight: Vector = sub(light.position, point).normalize()
    var distLight: float = sub(light.position, point).length()

    diffuseIntensity += light.intensity * max(0.1, mulScalar(dirLight, normal))
    specularIntensity += pow(max(0.1, mulScalar(inv(reflect(inv(dirLight), normal)), dir)),
                              mat.specularExponent) * light.intensity

  var diffuseReflection: Vector = mul(mul(newVector(mat.diffuseColor.r.float,
                                                    mat.diffuseColor.g.float,
                                                    mat.diffuseColor.b.float),
                                                    diffuseIntensity),
                                                    mat.albedo[0])

  var specularReflection: Vector = mul(mul(newVector(1.0, 1.0, 1.0),
                                           specularIntensity),
                                           mat.albedo[1])

  var phongReflection: Vector = add(diffuseReflection, specularReflection)

  var final: Color = color(phongReflection[0].int,
                           phongReflection[1].int,
                           phongReflection[2].int, 255)

  return final
