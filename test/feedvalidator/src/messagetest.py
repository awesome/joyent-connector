"""$Id: messagetest.py 511 2006-03-07 05:19:10Z rubys $"""

__author__ = "Sam Ruby <http://intertwingly.net/> and Mark Pilgrim <http://diveintomark.org/>"
__version__ = "$Revision: 511 $"
__date__ = "$Date: 2006-03-07 18:19:10 +1300 (Tue, 07 Mar 2006) $"
__copyright__ = "Copyright (c) 2002 Sam Ruby and Mark Pilgrim"
__license__ = "Python"

import unittest, new, os, sys, glob, re
import feedvalidator
from feedvalidator import compatibility
from feedvalidator.formatter.application_test import Formatter

class TestCase(unittest.TestCase):
  def failIfNoMessage(self, theClass, params, theList, msg=None):
    filterFunc = compatibility.AA
    events = filterFunc(theList)
    output = Formatter(events)
    for e in events:
      if not output.format(e):
        raise self.failureException, 'could not contruct message for %s' % e
    
desc_re = re.compile("<!--\s*Description:\s*(.*?)\s*Expect:\s*(!?)(\w*)(?:{(.*?)})?\s*-->")

def getDescription(xmlfile):
  """Extract description and exception from XML file

  The deal here is that each test case is an XML file which contains
  not only a possibly invalid RSS feed but also the description of the
  test, i.e. the exception that we would expect the RSS validator to
  raise (or not) when it validates the feed.  The expected exception and
  the human-readable description are placed into an XML comment like this:

  <!--
    Description:  channel must include title
    Expect:     MissingTitle
  -->

  """

  stream = open(xmlfile)
  xmldoc = stream.read()
  stream.close()

  search_results = desc_re.search(xmldoc)
  if search_results:
    description, cond, excName, plist = list(search_results.groups())
  else:
    raise RuntimeError, "can't parse %s" % xmlfile

  method = TestCase.failIfNoMessage
  
  params = {}
  if plist:
    for entry in plist.split(','):
      name,value = entry.lstrip().split(':',1)
      params[name] = value

  exc = getattr(feedvalidator, excName)

  description = xmlfile + ": " + description

  return method, description, params, exc

def buildTestCase(xmlfile, description, method, exc, params):
  """factory to create functions which validate `xmlfile`

  the returned function asserts that validating `xmlfile` (an XML file)
  will return a list of exceptions that include an instance of
  `exc` (an Exception class)
  """
  func = lambda self, xmlfile=xmlfile, exc=exc, params=params: \
       method(self, exc, params, feedvalidator.validateString(open(xmlfile).read())['loggedEvents'])
  func.__doc__ = description
  return func

if __name__ == "__main__":
  curdir = os.path.abspath(os.path.dirname(sys.argv[0]))
  basedir = os.path.split(curdir)[0]
  for xmlfile in glob.glob(os.path.join(basedir, 'testcases', '**', '**', '*.xml')):
    method, description, params, exc = getDescription(xmlfile)
    testName = 'test_' + os.path.basename(xmlfile)
    testFunc = buildTestCase(xmlfile, description, method, exc, params)
    instanceMethod = new.instancemethod(testFunc, None, TestCase)
    setattr(TestCase, testName, instanceMethod)
  unittest.main()
