
import os
import random

import deques
import httpclient
import ndns
import net
import nimquery
import sequtils
import  asyncdispatch
import strutils
from htmlparser import parseHtml
from streams import newStringStream
from utils import jitter
from xmltree import XmlNode, `$`, attr

type
  Url* = object
    url: string
    depth: int

func newUrl(url: string, depth: int): Url =
  Url(url: url, depth: depth)
proc getLinks(source: string): seq[string] =
  let html =  parseHtml(newStringStream(source))
  let links = html.querySelectorAll("a")
  var rlinks: seq[string]
  for l in links:
    let link = attr(l, "href")
    rlinks.add($link)
  result = rlinks
proc getSource(url: string, timeout: int): string  =
    var client = newHttpClient(timeout = timeout)
    return client.getContent(url)

proc httpNoise*(url: seq[string], delay, max_depth: int, verbose=false, timeout=10000, no_random=false) =
  var history: seq[string]
  var visits: seq[string]
  var depth = 0
  var targets: seq[Url]
  for x in url:
    let target = newUrl(x, depth)
    targets.add(target)
  shuffle(targets)
  var queue = toDeque(targets)
  #queue.addFirst(url1)
  while queue.len >= 1:
    let c_url = queue.popFirst()
    depth = c_url.depth

    if depth < max_depth:
      try:
        if verbose:
          echo(c_url.url, " @depth: ", depth)
        let source = getSource(c_url.url, timeout)
        let urls = getLinks(source)
        for link in urls:
          if link.startsWith("http://") or link.startsWith("https://"):
            if not link.contains("../../"):
              if not history.contains(link):
                let d = depth + 1
                let u = newUrl(link, d)
                queue.addLast(u)
      except HttpRequestError:
        history.add(c_url.url)
        continue
      except SslError:
        history.add(c_url.url)
        continue
      except OsError:
        history.add(c_url.url)
        continue
      except TimeoutError:
        history.add(c_url.url)
        continue

      except ValueError:
        history.add(c_url.url)
        continue
      except ProtocolError:
        history.add(c_url.url)
        continue
      visits.add(c_url.url)
    if not no_random:
      sleep(int(jitter(delay , 1.0) * 10000))

proc dnsNoise*(domain: string): Future[bool] {.async.} =
  ## Look up a domain, creates noise.
  ## returns false if domain is dead
  let client = initDnsClient(ip="9.9.9.9")
  var ips: seq[string]
  ips = await asyncResolveIpv4(client, domain)
  if len(ips) < 1:
    result = false
  else:
    result = true



if isMainModule:
  #let domain1 = "dadadadczqwwdq.com"
  let domain2 = "google.com"
  #let result = waitfor dnsNoise(domain1)
  let result2 = waitfor dnsNoise(domain2)
  #if result == true:
  #  echo("domain ", domain1, " is alive")
  #else:
  #  echo("domain ", domain1, " is dead")

  if result2 == true:
    echo("domain ", domain2, " is alive")
  else:
    echo("domain ", domain2, " is dead")

  let targets = @["https://scripter.co/notes/nim",
                  "https://pythoninwonderland.wordpress.com/2017/03/18/how-to-implement-breadth-first-search-in-python/",
                  "https://en.wikipedia.org/wiki/Breadth-first_search"]
  httpNoise(targets, 1, 2, true)
