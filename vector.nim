import math


type
  Vector* = object
    x, y, z: float


proc `[]`* (v: Vector, i: int): float =
  case i
  of 0: result = v.x
  of 1: result = v.y
  of 2: result = v.z
  else: assert(false)


proc `x`* (v: Vector): float =
  return v.x


proc `y`* (v: Vector): float =
  return v.y


proc `z`* (v: Vector): float =
  return v.z


proc newVector* (x, y, z: float): Vector =
  return Vector(x: x, y: y, z: z)


proc length* (v: Vector): float =
  return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)


proc normalize* (v: Vector): Vector =
  var d: float = v.length()
  return Vector(
    x: v.x / d,
    y: v.y / d,
    z: v.z / d
  )


proc add* (a: Vector, b: Vector): Vector =
  return Vector(
    x: a.x + b.x,
    y: a.y + b.y,
    z: a.z + b.z
  )


proc sub* (a: Vector, b: Vector): Vector =
  return Vector(
    x: a.x - b.x,
    y: a.y - b.y,
    z: a.z - b.z
  )


proc mul* (a: Vector, b: float): Vector =
  return Vector(
    x: a.x * b,
    y: a.y * b,
    z: a.z * b
  )


proc mulScalar* (a: Vector, b: Vector): float =
  var ret: float = 0.0
  for i in 0..<3:
    ret = ret + (a[i] * b[i])
  return ret


proc inv* (v: Vector): Vector =
  return mul(v, -1.0)
