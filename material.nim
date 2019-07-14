import csfml

import vector


type
  Material* = object
    albedo: Vector
    diffuseColor: Color
    specularExponent: float
    refractiveIndex: float
    transparence: float


proc newMaterial* (albedo: Vector, color: Color, exp: float, r: float, t: float): Material =
  return Material(albedo: albedo, diffuseColor: color, specularExponent: exp, refractiveIndex: r, transparence: t)


proc albedo* (mat: Material): Vector =
  return mat.albedo


proc diffuseColor* (mat: Material): Color =
  return mat.diffuseColor


proc specularExponent* (mat: Material): float =
  return mat.specularExponent


proc refractiveIndex* (mat: Material): float =
  return mat.refractiveIndex

proc transparence* (mat: Material): float =
  return mat.transparence
