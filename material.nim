import csfml

import vector


type
  Material* = object
    albedo: Vector
    diffuseColor: Color
    specularExponent: float


proc newMaterial* (albedo: Vector, color: Color, exp: float): Material =
  return Material(albedo: albedo, diffuseColor: color, specularExponent: exp)


proc albedo* (mat: Material): Vector =
  return mat.albedo


proc diffuseColor* (mat: Material): Color =
  return mat.diffuseColor


proc specularExponent* (mat: Material): float =
  return mat.specularExponent
