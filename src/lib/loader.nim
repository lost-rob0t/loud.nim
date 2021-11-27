import strutils

type
  Loud* = ref object
    urls*: seq[string]
    timeout: int
    depth*: int
    file*: string
func makeLoud*(path: string, depth: int): Loud =
  Loud(file: path, depth: depth, urls: @[])
proc load*(loud: Loud, path: string) =
  let f = open(path, fmRead)
  defer: f.close()

  for line in f.lines():
    if line.startsWith("https://") or line.startsWith("http://"):
        loud.urls.add(line)

  # Deduplicating list
  #loud.urls.deduplicate(isSorted=true)

proc addUrl*(loud: Loud, url: string) =
  ## Adds a url to the Loud objects seq of urls.
  loud.urls.add(url)


#proc cutUrl*(loud: Loud, url: string): Loud =
#  ## Remove a url from Loud seq of urls.
#  ## This is needed incase of dead hosts/links
#  loud.urls.delete(url)

proc syncUrls*(loud: Loud, path: string) =
  ## Write all urls in Louds seq of urls to disk.

  let f = open(path, fmAppend)
  defer: f.close()
  for url in loud.urls:
    f.writeLine(url)
