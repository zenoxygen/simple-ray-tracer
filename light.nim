import vector


type
  Light* = object
    position: Vector
    intensity: float


proc newLight* (position: Vector, intensity: float): Light =
  return Light(position: position, intensity: intensity)


proc position* (light: Light): Vector =
  return light.position


proc intensity* (light: Light): float =
  return light.intensity
