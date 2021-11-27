import math
import random
proc jitter*(time: int,  exp: float): float =
  ## Create A random delay.
  ## jitter = time ** exp sqrt(-1)
  randomize()
  let z = sqrt(float(time) * float(rand(0.5..exp)) * float(rand(0.1..1.0)))
  var jitter = sqrt(rand(0.1..z) * rand(0.01..exp))
  return jitter
if isMainModule:
  for x in 1..50:
    var y = jitter(5, float(x))
    echo(y)
