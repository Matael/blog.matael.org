===================================
Ambilighht v2 : Threads Inside (en)
===================================

:date: 2015-01-04 11:28:41
:slug: ambilighht-v2-threads-inside-en
:authors: matael
:summary: After a serie of tests, it's time to boost the script (en)
:tags: python, arduino, opencv, ambilight, imported

In a `previous article`_ (english), I described a serie of preliminary tests towards building a ambilight-like system
(in the finest DIY way).

While testing on a less powerful machine, we noted (some hackers from HAUM_ and I) some kind of slowness in the process.

The last article was considering the following about the last piece of code :

    As you can see, the video is pretty smooth and reactive.

I was actually correct.... but not on every machine...

The related piece of code was :

.. code-block:: python


    import cv2
    import numpy as np

    # instanciate CAM object
    cam = cv2.VideoCapture(0)

    # get one image to process
    _,f = cam.read()

    # get total width/height
    l = f.shape[1]
    h = f.shape[0]

    # select number of regions
    nb = 10

    # compute height and width of each region
    dh = int(f.shape[0]/nb)
    bandwidth = int(l*0.05) # 5% of total width

    # act continuously
    while 1:

        # get one image to process
        _,f = cam.read()

        # for each region
        for k in xrange(nb):

            # create masks
            mask_left = np.zeros((h,l,1), np.uint8)
            mask_right = np.zeros((h,l,1), np.uint8)

            for i in xrange(dh):
                for j in xrange(bandwidth):
                    mask_left[dh*k+i][j] = 1
                    mask_right[dh*k+i][l-j-1] = 1

            # compute averages
            val_left = cv2.mean(f, mask=mask_left)
            val_right = cv2.mean(f, mask=mask_right)

            # draw rectangles
            cv2.rectangle(f, (0,dh*k), (bandwidth,dh*(k+1)), color=val_left, thickness=-1)
            cv2.rectangle(f, (l-bandwidth,dh*k), (l,dh*(k+1)), color=val_right, thickness=-1)

        # show image instead one saving it
        # 'w1 is the window reference
        cv2.imshow('w1', f)

        # wait 2ms for an Esc input and break if it comes.
        if cv2.waitKey(2) == 27:
            break

The only change between this code and the one from last article (which had only been tested on ArchLinux) is that I
added the 2 last lines.
Indeed, without them, ubuntu (on my netbook) just refuse to display anything.

So, we'll proceed as follow :

- analyze existing code to find its weak points
- rewrite the code step by step (explaining by the way the main principle of multi-threaded programming in Python)

Analysis
========

This code faces several problems, the first and most obvious (which is forgivable as this script is just a *proof of
concept*) is that there is abbsolutely no error handling (what happened if no camera is found ?).
I won't spend a lot of time of this aspect, but in a real finished project, you must fix this point.

If you read carefully, you'll notice that the processing is quite dirty. The algorithm is doing :::

    Always Do
        Grab an image

        For each n in the number of "regions"
            Create a white mask for right zone
            Create a white mask for left zone

            For each i in dh
                For each j in bandwith
                    Replace the point (i,j) with a 1 in right mask
                    Replace the point (i,j) with a 1 in left mask
                End For
            End For

            Compute average of right zone
            Compute average of left zone

            Trace right rectangle
            Trace left rectangle
        End For
    End Do

Trained reader will obviously notice that the mask calculations for each zone can be made only once and stored.

It could be done also for zones themselves : we could compute data for the 2 delimiting points and use it for each
iteration.

Finally, you'll notice that tracing the rectangles is the only action that modify the image : we could parallelize
computation of average colors.

The global idea it to create something like that : the main process grabs images and pre-computes masks and zonees
coordinates. Then, it spawns a serie of workers : several to average colors and only one to draw rectangles.

Preliminaries
=============

CycleQueue
----------

When using threads, we often use ``Queue.Queue()`` to create a waiting queue between data produced by a thread and
consummed by another. I've extended this class a bit, alllowing the programmer to store one queue state and to recall
this state. The conception of the augmented class is described in `another article`_ (fr).

Here is an use case :

.. code-block:: python

    from utilities import CycleQueue

    # instanciation
    q = CycleQueue()

    # utilisation comme une Queue classique
    for i in xrange(10):
        q.put(i)

    # vérrouillage de l'état courant
    q.lockstate()

    # utilisation comme une Queue classique
    for i in xrange(10):
        q.get()
        # faire des trucs
        q.task_done)()

    # restoration de l'état verrouillé
    q.reinit()

    # etc...

Singleton
---------

Within OOP, a *singleton* a well-known design pattern.
The concept is to build a class that will always reference the same instance of itself.

I'm not always willing to recreate all from *scratch*, StackOverflow_ proposes a excellent way of implementing this
pattern in Python.

Here is the decorator i used (inside ``utilities.py``):


.. code-block:: python

    class Singleton:
        """
        A non-thread-safe helper class to ease implementing singletons.
        This should be used as a decorator -- not a metaclass -- to the
        class that should be a singleton.

        The decorated class can define one `__init__` function that
        takes only the `self` argument. Other than that, there are
        no restrictions that apply to the decorated class.

        To get the singleton instance, use the `Instance` method. Trying
        to use `__call__` will result in a `TypeError` being raised.

        Limitations: The decorated class cannot be inherited from.

        """

        def __init__(self, decorated):
            self._decorated = decorated

        def Instance(self):
            """
            Returns the singleton instance.  Upon its first call, it creates a
            new instance of the decorated class and calls its `__init__` method.
            On all subsequent calls, the already created instance is returned.

            """

            try:
                return self._instance
            except AttributeError:
                self._instance = self._decorated()
                return self._instance

        def __call__(self):
            raise TypeError('Singletons must be accessed through `Instance()`.')

        def __instancecheck__(self, inst):
            return isinstance(inst, self._decorated)

We will only need to decorate *singleton* classes with ``@Singleton``.
Here, it's the class that will handle the image itself which will reference a singleton :

.. code-block:: python

    @Singleton
    class IMG:
        """ Handle current image """

        def __init__(self):
            self.final_image = None
            self.image = None

        def new_image(self, f):
            self.image = f
            self.final_image = f

Globals
=======

Programmers often fight against global variables, but sometimes, this does allow clean and short function calls.
Here are my globals :

.. code-block:: python

    # instanciate CAM object
    cam = cv2.VideoCapture(0)

    _,f = cam.read()
    l = image_width = f.shape[1]
    image_height = f.shape[0]
    nb_points = 5
    dh = int(f.shape[0]/nb_points)
    bandwidth = int(l*0.05) # 5% of total width

    masks = []

Computation for masks and zones
-------------------------------

Let's fill ``masks`` with valid data. We'll write a function which will be called in ``main()`` to do that. Even if
``masks`` is global, I give it to the function as an argument (along with the ``CycleQueue`` instance for zones) to make
this function more portable.

.. code-block:: python

    def enqueue_zones(queue, masks):
        """ Generate zones coordinates and masks and enqueue them

        tuple format :
            (y0, x0, y1, x1, index of masks)

        we have to store masks in another lists as Queue() doesn't
        recognize numpy arrays as valid datatypes

        """

        for h in xrange(nb_points):
            # generate masks
            mask_right = np.zeros((image_height,image_width,1), np.uint8)
            mask_left = np.zeros((image_height,image_width,1), np.uint8)
            for i in xrange(dh):
                for j in xrange(bandwidth):
                    mask_left[dh*h+i][j] = 1
                    mask_right[dh*h+i][l-j-1] = 1

            prev_len = len(masks)
            masks.append(mask_left)
            masks.append(mask_right)

            # enqueue
            ## left zone
            queue.put(( 0, dh*h, bandwidth, dh*(h+1), prev_len))
            ## right zone
            queue.put(( image_width-bandwidth, dh*h, image_width, dh*(h+1), prev_len+1))

I think the code is clear enough (if you don't think so, just tell me and I'll explain it).

We now have all we need to feed our workers :)

Workers
=======

Now, we'll write our two workers :

- color averaging on one hand
- rectangles drawing on another hand

Why threading rectangles drawing is interesting ?
-------------------------------------------------

Threading the drawing worker alllow use to start drawing before the averaging ends.

To achieve that, the two workers pools will discuss through a ``Queue``, averaging workers adding zones and colors to
the queue the drawing worker will read later.

We'll have to carefully wait for the emptying of both queues before switching frame.

Thread reminder
---------------

Both worker types will inherit from ``threading.Thread``.

In Python, writing a thread is quite easy (in comparison to other langages).

We do create a class (inheriting from ``threading.Thread``) and write at least two methods : ``__init__`` and ``run``.

The former contains (as usual) initialization elements and inevitably :

.. code-block:: python

    threading.Thread.__init__(self)

To ensure complete setup from parent class.

The latter contains the executed code inside the thread.

A *hello World* thread is coded as :

.. code-block:: python

    import threading

    class MyThread(threading.Thread):

        def __init__(self):
            threading.Thread.__init__(self)

        def run(self):
            while True:
                print("Hello, world!")

    t = MyThread()
    t.start() # lancement du thread

    t.join() # attente de la fin du thread

    # fin du programme

Here, we'll use some ``Queue`` to make our threads communicate. You must know that other mecanisms exist : mutex,
semaphores, locks, etc....

For further information, look at the doc_.

Averager
--------

Here is the code for our dear averager thread :

.. code-block:: python

    class ColorAverageWorker(threading.Thread):

        def __init__(self, queue, out_queue):
            threading.Thread.__init__(self)
            self.queue = queue
            self.out_queue = out_queue

        def run(self):
            while True:
                zone = self.queue.get()
                color = cv2.mean(IMG.Instance().image, mask=masks[zone[4]])
                # add a dict to out queue :
                # zone => zone tuple given by previous queue
                # color => color tuple given by cv2.mean()
                self.out_queue.put({'zone': zone,
                                    'color': color})
                self.queue.task_done()

Nothing complicated, uh ? As the greatest part of the job is precomputed, our threads are only quasi-empty workers :)

Notice, however, the usage of :

.. code-block:: python

    IMG.Instance().image

This do return the ``ìmage`` attribute for the unique instance of ``IMG`` class (which is a singleton).

Drawer
------

The second thread is almost as simple as the first one :

.. code-block:: python

    class WorkerDraw(threading.Thread):

        def __init__(self, queue):
            threading.Thread.__init__(self)
            self.queue = queue

        def run(self):

            while True:
                point = self.queue.get()
                zone = point['zone']
                cv2.rectangle(
                    IMG.Instance().final_image,
                    (zone[0], zone[1]),
                    (zone[2], zone[3]),
                    color=point['color'],
                    thickness=-1
                )
                self.queue.task_done()

Here again, notice that the ``zone`` variable is created only to make the code simpler.
Also notice *tuples* in thhe call foor ``cv2.rectangle``.

Finally, the last thing to notice is that we do modify ``ÌMG.Instance().final_image`` and not ``IMG.Instance().image``.
It suppress the need for locks and simplify a bit the code.

Main
====

Lastly, we can write our master process : the ``main()``.

You'll find a strange similarity with the code in the `previous article`_ :

.. code-block:: python

    def main():

        # init a CycleQueue for zones
        zones = CycleQueue()
        # ... and a Queue for the drawer
        out_queue = Queue()

        # enqueue zones
        enqueue_zones(zones, masks)
        zones.lockstate()

        # set number of workers (averaging only)
        num_workers = 5

        # spawn workers
        for i in xrange(num_workers):
            t = ColorAverageWorker(zones, out_queue)
            t.start()

        # all workers :)
        t = WorkerDraw(out_queue)
        t.start()

        # loop over frames
        while True:

            # read frame
            _,f = cam.read()
            # add it to singleton
            IMG.Instance().new_image(f)

            # ensure you have the right queue
            zones.reinit()

            # wait both queues to be empty
            zones.join()
            out_queue.join()

            # show image and wait for a keystroke
            cv2.imshow('w1', IMG.Instance().final_image)

            if cv2.waitKey(2) == 27:
                break

    if __name__=='__main__':
        main()

And voilà !

Conclusion
==========

This article was a bit long, but reveal several concepts :

- first, it comes back on OOP concepts
- it introduce succintly threading concepts
- it's a full rewriting of a (very) dirty script
- finally, it comes back on modulariity notions : almost all elements can we rewritten ou augmented almost without
  effort.

For those who want a complete code, it can be found here_.

Hoping this would have help you :)

.. _previous article: http://blog.matael.org/writing/a-first-try-at-ambilight/
.. _HAUM: http://haum.org
.. _another article: http://blog.matael.org/writing/cyclequeue/
.. _stackoverflow: http://stackoverflow.com/questions/42558/python-and-the-singleton-pattern
.. _doc: http://docs.python.org/2/library/threading.html
.. _here: /static/files/ambilight/code_threaded.zip

