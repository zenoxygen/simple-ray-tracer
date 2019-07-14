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


proc refract* (incident: Vector, normal: Vector, refractiveIndex: float): Vector =
  var n1: float = 1.0
  var n2: float = refractiveIndex
  var cos1: float = mulScalar(normal, inv(incident))
  var cos2: float = sqrt(1.0 - pow(n1 / n2, 2.0) * (1.0 - pow(cos1, 2.0)))

  if cos1 > 0:
    return add(mul(incident, pow(n1 / n2, 2.0)), mul(normal, (n1 / n2) * cos1 - cos2))
  else:
    return add(mul(incident, pow(n1 / n2, 2.0)), mul(normal, (n1 / n2) * cos1 + cos2))


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


proc rayCast* (spheres: var seq[Sphere], lights: var seq[Light], orig, dir: var Vector, depth = 0): Color =
  var point, normal: Vector
  var mat: Material

  if depth > 10 or sceneIntersect(spheres, orig, dir, point, normal, mat) == false:
    return color(50, 175, 200, 255)

  var diffuseIntensity: float
  var specularIntensity: float

  var origReflect, dirReflect: Vector
  var colorReflect: Color

  var origRefract, dirRefract: Vector
  var colorRefract: Color

  dirReflect = reflect(dir, normal)
  dirRefract = refract(dir, normal, mat.refractiveIndex)

  if mulScalar(dirReflect, normal) < 0:
    origReflect = sub(point, mul(normal, 1e-3))
  else:
    origReflect = add(point, mul(normal, 1e-3))

  if mulScalar(dirRefract, normal) < 0:
    origRefract = sub(point, normal)
  else:
    origRefract = add(point, normal)

  colorReflect = rayCast(spheres, lights, origReflect, dirReflect, depth + 1)
  colorRefract = rayCast(spheres, lights, origRefract, dirRefract, depth + 1)

  for light in lights:

    var dirLight: Vector = sub(light.position, point).normalize()
    var distLight: float = sub(light.position, point).length()

    var origShadow, pointShadow, normalShadow: Vector
    var tmpMat: Material

    if mulScalar(dirLight, normal) < 0:
      origShadow = sub(point, normal)
    else:
      origShadow = add(point, normal)

    if sceneIntersect(spheres, origShadow, dirLight, pointShadow, normalShadow, tmpMat) and
      sub(pointShadow, origShadow).length() < distLight:
      continue

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

  var colorReflection: Vector = mul(newVector(colorReflect.r.float,
                                              colorReflect.g.float,
                                              colorReflect.b.float),
                                              mat.albedo[2])

  var colorRefraction: Vector = mul(newVector(colorRefract.r.float,
                                              colorRefract.g.float,
                                              colorRefract.b.float),
                                              mat.transparence)

  var phongReflection: Vector = add(add(add(diffuseReflection,
                                            specularReflection),
                                            colorReflection),
                                            colorRefraction)

  var final: Color = color(phongReflection[0].int,
                           phongReflection[1].int,
                           phongReflection[2].int, 255)

  return final
