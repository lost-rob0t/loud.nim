import lib/noise
import lib/utils
import lib/loader
import os
import cligen
import uri
import net
import asyncdispatch

proc makeDnsNoise(domains: seq[string], delay: int): seq[string] =
  var alive: seq[string]
  for target in domains:
    let b = waitFor dnsNoise(target)
    if b:
      alive.add(target)
  sleep(int(jitter(delay, 3.0)))
  result = alive

proc makeHttpNoise(urls: seq[string], delay: int, max_depth: int, verbose = true, timeout=10000, no_random = false) =
  httpNoise(urls, delay, max_depth, verbose, timeout, no_random)


proc argMain(file: string, depth: int, verbose=true, mode="http", delay=5, timeout=10, no_random=false) =
  var l = Loud(file: file, depth: depth, urls: @[])
  let real_timeout = timeout * 1000

  if mode == "http":
    l.load(file)
    makeHttpNoise(l.urls, int(delay), depth, verbose, real_timeout, no_random)

  if mode == "dns":
    l.load(file)
    var domains: seq[string]
    for url in l.urls:
      let host = parseUri(url).hostname
      domains.add(host)
    let v = makeDnsNoise(domains, int(delay))


if isMainModule:
  dispatch(argMain)
