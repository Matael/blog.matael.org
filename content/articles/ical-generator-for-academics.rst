============================
ICal Generator for Academics
============================

:date: 2016-08-16 00:19:39
:slug: ical-generator-for-academics
:authors: matael
:summary: Easing conference planning for fun and profit
:tags: ical, fac, python, imported

Conferences are an important part of scientific life and, even if I'm pretty new to this
world, I understand planning one's tour at a conference can be a real hassle.

The context that led to the following project is pretty common for most scientists. My
friend `Fred Blain`_ from USFD_ was preparing for the ACL2016_ conference in Berlin.
This year's ACL was a huge (1.6k researchers) conference with a lot of talks in up to 7
tracks in parallel. The program was announced `on the website`_ but, as usual, not easy to
mine and dissect.

On a proposal from Fred, we decided to tackle the challenge of making this program easier
to prune down to a small, personal interest list.

  The rest of the article describes the parsing and restitution processes. The result can
  be found `here`_.

.. _Fred Blain: http://fredblain.org/
.. _USFD: http://www.sheffield.ac.uk/
.. _ACL2016: http://acl2016.org/
.. _on the website: http://acl2016.org/index.php?article_id=12
.. _here: https://acl2016.fredblain.org/

Parsing the HTML page
=====================

We'll go through the parsing process and the creation of a webapp to browse the program
and generate an ICAL.

On the ACL website, some pages provide a detailed program (such as http://acl2016.org/index.php?article_id=64 ), we'll use that to generate a JSON list of events for each day.

Setting up the basics
---------------------

Let's first implement a base in which we could implement the parsing process:

.. code-block:: python

  from requests import get
  from bs4 import BeautifulSoup

  class ConferenceDay:

      def __init__(self, day_id):
          self.day_id = day_id
          self.base_url = 'http://acl2016.org/'
          self.session_soup = BeautifulSoup(get(self.base_url+'index.php?article_id='+str(self.day_id)).content, 'html.parser')
          self.session_rooms_mapper = {
              'A': "Audimax",
              'B': "Kinosaal",
              'C': "2002",
              'D': "3038",
              'E': "2094",
              'F': "2091",
              'G': "2097"
          }

The class will hold everything, the room mapper is linked to the distribution of rooms at
the venue.

Page structure
--------------

First thing to do, as usual, is to study the page structure. One can easily show that the
full page is actually a long table. Let's walk through the table's rows and understand the
different features:

- The global events are in bold (tagged with ``<strong>``)
- The sessions are preceeded by a ``<h3>`` title with the session's name
- Some useless events are present (Lunch & Coffee breaks)
- Some rows are here for padding only

Let's write a loop over the table's rows to classify them. As an output, we want a list of
lists containing the row's content (as BeautifulSoup object) if it's a paper, the session
name as a string if it's a title or a tuple ``(time,name)`` if it's one of the global
activities.


.. code-block:: python

  def parse_html(self):
      # list of events not to log
      KILL_LIST = ['Coffee break', 'Lunch break']

      # empty list of events and boolean to know if we're
      # in one of the sets of activities (Lunch, Coffee, etc...)
      self.list_events = []
      in_activity_list = False

      row = self.session_soup.find('tr')
      while row:
          # if it's a title, add a new sublist
          if row.find('h3'):
              self.list_events.append([row.find('h3').get_text()])
              in_activity_list = False # beginning of session => end of global activity time

          # if the second column is of length 1 => activity or empty row
          # in beautiful soup the contents' length of a tag with 1 children only
          # is of length 1
          # the "empty" rows are 1 character rows => len()=1
          elif len(row.find_all('td')[1].contents)==1:
              # if strong => activity
              if row.find('strong') and not row.find('strong').get_text() in KILL_LIST:
                  if not in_activity_list:
                      self.list_events.append([])
                      in_activity_list = True
                  self.list_events[-1].append(
                      (row.find('td').get_text(),
                        row.find('strong').get_text())
                  )

              # empty row, discard
              else:
                  pass

          else: # it's a normal row => add it to the current list
              self.list_events[-1].append(row)

          # neeext !
          row = row.find_next_sibling()

Of course, the ``else: pass`` is optional but is kept because `readability counts`_.
The function is straight forward, it just checks line by line for a title, a global
activity or a normal paper and create sublist for sets of activities or sessions.

From list to dict
-----------------

Now we have the list, let's transform it into a dict mapping each timeframe with
corresponding events.

.. code-block:: python

  def generate_dict(self):
      self.events= {}
      for sub in self.list_events:
          # very long lists are posters or demo
          if len(sub)>15:
              continue

          # check if the sublist is full string => global events
          if len(list(filter(lambda _: type(_)==tuple, sub)))==len(sub):
              for e in sub:
                  self.events[e[0]] = {'type': 'global_session', 'title': e[1]}

          else: # normal session
              # the first item was always the session name
              session_title = sub[0]
              # retrieve session room (last character of the session number)
              session_room = self.session_rooms_mapper[session_title.split(':')[0][-1]]

              for talk in sub[1:]:
                  local_timeframe = talk.find_all('td')[0].text
                  paper_title = talk.find_all('td')[1].contents[0].text
                  paper_authors = talk.find_all('td')[1].contents[2]
                  if not self.events.get(local_timeframe):
                      self.events[local_timeframe] = []
                  self.events[local_timeframe].append(
                      {'type': 'session',
                        'session_name': session_title,
                        'title': paper_title,
                        'authors': paper_authors,
                        'room': session_room}
                  )

This second function goes through the previously created list and build the dict:

- It first kicks out every sublist with more thant 15 entries (that corresponds to poster sessions or demo in the present conference).
- It creates a global event entry for each sublist composed only of tuple
- It generate a JSON entry with the right session name and room for other papers

Finally, don't forget to call those last two functions in ``__init__`` if you want the
list to be created at instantiation:

.. code-block:: python

  parse_html()
  generate_dict()

In the end, the attribute ``events`` holds the full list of events, timeframe by
timeframe.

Bundling into a website
=======================

In order to make all this accessible and easily profitable, let's build a small webapp
around it.

Design considerations
---------------------

The number of expected researchers was high for a conference but not for a webapp, we
decided a simple plain JSON file could serve as a simple database. Note that this is **not
true** in general and is highly correlated with my laziness.

We are bad at creating beautiful designs but `HTML5 Up`_ is not, we downloaded the
style-sheet and HTML boilerplate from them (it's called `Prologue`_). As the theming part
is just a matter of integration it will not be discussed here.

Generating the database
-----------------------

As we didn't want to kill ACL website by generating 3 requests to their servers every time
1 is sent to ours, let's cache the cleaned list of events and talks.

This is done simply using the following script (the comments should make it sufficiently
readable):

.. code-block:: python

  from ACLConf import ConferenceDay
  from json import dump

  # filename where to store the final lists
  DB_NAME = "./days.json"

  # each day is associated to the corresponding article_id from ACL Website
  mapper = {
      'monday': 64,
      'tuesday': 65,
      'wednesday': 66
  }

  # create and fill a dict with day_name ->  event list by timeframe
  days = {}
  for day_name,day_id in mapper.items():
      days[day_name] = ConferenceDay(day_id).events

  # write it all in the "DB" file
  with open(DB_NAME, 'w') as fh:
      dump(days, fh)

The webapp
----------

As often in my projects, the webapp is built on top of Bottle_. It consist in 2 functions:

- the first view, responding on ``/`` shows 1 form per day and allows one to pick up
  interesting talks and click on a *Generate ICAL* button to get the file (1 per day);
- the second one process the POST data from the form and generate the ICAL itself

Let's start with the usual boilerplate (imports and static file URL):

.. code-block:: python

  from bottle import\
      route,\
			run,\
			jinja2_template as template,\
			request,\
			response,\
			static_file

  @route('/assets/<filename:path>')
  def static(filename):
      """Serves static files"""
      return static_file(filename, root='assets/')

  if __name__=='__main__': run(host='localhost', port=8080, reloader=True)




The second view to add is the index page which displays the forms. It's also the one that
reads the JSON file:

.. code-block:: python

  from json import load

  DB_NAME = "./days.json"

  @route('/')
  def index():

      # keep a list of days so we can iterate in the right order
      days_list = ['monday', 'tuesday', 'wednesday']

      # read from the database
      with open(DB_NAME, 'r') as fh:
          days_contents = load(fh)

      # orders the sessions by ascending starting time
      sessions_orders = {}
      for d in days_list:
          l = []
          for time in days_contents[d].keys():
              # pad the missing leading zeros
              if len(time.split(':')[0])==1:
                  l.append(('0'+time,time))
              else:
                  l.append((time,time))

          # Good ol' sort (WARNING .sort() operates *in place*)
          l.sort()
          sessions_orders[d] = l

      return template('index.html',
                      days_contents=days_contents,
                      sessions_orders=sessions_orders,
                      days_list=days_list
      )

Some may notice a better way to sort session would be to use the built-in ``datetime``
module but here's the thing: we finished this webapp at 2.30 a.m. and we didn't want to mess
around with this date-related crap.

The relevant part of the ``index.html`` template looks like this:


.. code-block:: htmldjango

  {% for d in days_list %}
  <section id="{{d}}">
    <div class="container">
      <h2>{{d|capitalize}} sessions</h2>
      {% for sorted_key,timeframe in sessions_orders[d] %}
      <form action="/export.ics" method='POST'>
        <input type="hidden" name='day' value="{{d}}"/>
        <h3>{{timeframe}}</h3>
        <ul>
          {% for paper in days_contents[d][timeframe] %}
            <li>
              <input type=radio name="{{timeframe}}"
                     id="{{paper.title}}"
                     value="{{paper.title}}
                            {% if paper.type=='session' %}
                              by {{paper.authors}}#{{paper.room}}
                            {% endif %}
                           "
              />
              <label for="{{paper.title}}">
                <strong>{{paper.title}}</strong>
                {% if paper.type=='session' %}
                  <em> by {{paper.authors}}</em>
                {% endif %}
              </label>
            </li>
          {% endfor %}
        </ul>
        {% endfor %}
        <br />
        <input type="submit" value="Generate iCal!"/>
      </form>
    </div>
  </section>
  {% endfor %}


It's literally just a couple of for-loops that spans one form per day and that add a new
set of radio buttons for each timeframe.

Generating the ICal
-------------------

Because it was 2.30 a.m. and the first time for us with the ``icalendar`` package, we went
for the easy way: reuse an example `from the documentation`_.

In the following view, we get the ``POST`` data from the form and we process it. As all
the required data was already included in the form itself (title, authors, rooms and timeframe)
there's no need to call the DB again.

.. code-block:: python

  from icalendar import Calendar, Event
  import pytz
  from datetime import datetime

  # use the right extension in the route to help the
  # OS to detect it as a calendar file
  @route('/export.ics', method='POST')
  def generate_ical():

      # init the Calendar object as proposed in the example
      cal = Calendar()
      cal.add('prodid', '-//My calendar product//mxm.dk//')
      cal.add('version', '2.0')

      # pre-init datetime objects for date handling
      mapper = {
          'monday': datetime(2016, 8, 8, tzinfo=pytz.timezone('Europe/Paris')),
          'tuesday': datetime(2016, 8, 9, tzinfo=pytz.timezone('Europe/Paris')),
          'wednesday': datetime(2016, 8, 10, tzinfo=pytz.timezone('Europe/Paris'))
      }

      for k,v in request.POST.items():
          # if the field is named day it's the first (hidden) one
          # it will be used afterwards but does not require a special action
          if k=='day':
            continue
          else:
              # update the pre-built datetime objects
              start,end = k.split("-")
              dtstart = mapper[request.POST['day']].replace(hour=int(start.split(":")[0]),
                                                            minute=int(start.split(":")[1]))
              dtend = mapper[request.POST['day']].replace(hour=int(end.split(":")[0]),
                                                          minute=int(end.split(":")[1]))

              # bundle everything into an event object
              event = Event()
              if v.find('#')>0:
                  # papers "value" in the form contain a # between authors and room
                  v_sum, v_room = v.split('#')
                  event.add('summary', v_sum)
                  event.add('location', v_room)
              else:
                  event.add('summary', v)

              event.add('dtstart',dtstart)
              event.add('dtend',dtend)

          # add it to the calendar and go to the next one
          cal.add_component(event)

      # change the content-type so a download is proposed
      response.content_type = 'text/calendar'
      # raw response without rendering
      return cal.to_ical()

Aaaaannnnd... There we are!

A fully functionning ICal generator in less than 200 lines of code, accessible through a
web browser.

What's next?
============

As usual, the result we got is not an end, there's plenty of other conferences to come and
it could be awesome to provide such a tool for every single one. This will require a
better codebase, with a more modular architecture and a more efficient engine.

For those who think it's kind of overkill to use such a solution, some commercial
alternatives exist and particularly Conference4Me_. The tool proposed here doesn't serve the same purpose though: no application, no "branded" content nor support; just an idea, a need and a bunch of lines to fill it.

.. _readability counts: https://www.python.org/dev/peps/pep-0020/
.. _HTML5 Up: https://html5up.net
.. _Prologue: https://html5up.net/prologue
.. _Bottle: http://bottlepy.org
.. _from the documentation: http://icalendar.readthedocs.io/en/latest/usage.html#example
.. _Conference4Me: http://conference4me.psnc.pl/
