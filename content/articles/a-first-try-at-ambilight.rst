========================
A first try at ambilight
========================

:date: 2015-01-04 11:28:40
:slug: a-first-try-at-ambilight
:authors: matael
:summary: Just some tests for a ambilight-like project
:tags: python, arduino, opencv, ambilight, imported

As probably some of you know, Ambilight_ is a commercial system developped by Philips.
As Wikipedia says, *AmbiLight* goes for *Ambient Lighthing*.

The concept behind Ambilight is that immersion is better if the ambient light (hue and brightness) is close to those
displayed on screen. Ambilight goes even further adapting projected light's hue to what appear on the corresponding side
of the screen. This system is close to extension of images outside screen.

This article will only talk about simple tests using Python to compute average color of strips on both right and left sides of an
image.

During all the experiments, we'll use the ``cv2`` lib for Python2.x : this lib provides plenty of bindings between Python
and OpenCV_.

On Ubuntu, just install :

.. code-block:: bash

    sudo apt-get install python-opencv

On Arch, please note that some of the OpenCV bindings packages on the AUR_ are flagged as out-of-date. But you are an
Archer thus you'll find a way to install that lib, either using ``pacman`` or ``pip`` (or a combination of both).

First test : one strip per side on a picture
============================================

This first test was the hardest for me : I didn't know anything about OpenCV_ before and I had to learn on the fly.
Note that, in these moments StackOverflow_ becomes one of your best friends...

.. image:: /static/images/ambilight/masks_principle.png
    :width: 800px
    :align: center

The concept is quite simple :

- get a image (from webcam or HDD) (left pic)
- apply a mask on its both sides (two masks actually, they are drawn on the middle image)
- compute separatly the average color of each strip
- draw a rectangle which color is the average and the size corresponding to the area averaged (finally, the right image)

Let's see how we can achieve that in Python.

Getting an image
----------------

With OpenCV_, you can get images/films either through your webcam or directly from your hard drive.

.. code-block:: python

    import cv2

    # read from a file
    f = cv2.imread('filename')

    # read from a cam
    cam = cv2.VideoCapture(O) # 0 is cam ID
    _,f = cam.read()
    # _ contains ret. value
    # f contains image

You have to know that all images objects created by ``cv2`` are ``numpy`` arrays ; just remember to include this useful
lib (you'll need it for masking) :

.. code-block:: python

    import numpy as np

Getting dimensions and creating masks
-------------------------------------

Now, we'll create two numpy arrays with exactly the same dimensions as the image :

.. code-block:: python

    # total width
    l = f.shape[1]
    # total height
    h = f.shape[0]

    # 5% of l, this will be the width of averaged band
    bandwidth = int(l*0.05) # 5% of total width

    # create masks
    # simple np arrays full of 0s :)
    mask_left = np.zeros((h,l,1), np.uint8)
    mask_right = np.zeros((h,l,1), np.uint8)

    for i in xrange(h): # full height
        for j in xrange(bandwidth):
            mask_left[i][j] = 1
            mask_right[i][l-j-1] = 1

For ``cv2`` a mask is just a ``numpy`` array (with same dimensions as the image). Area containing ones are shown through
this masks and those containing zeros are not.

Averaging and drawing rectangles
--------------------------------

The easiest part :)

OpenCV offers the ``mean()`` function to compute average color and this function can take a mask as parameter. So :

.. code-block:: python

    val_left = cv2.mean(f, mask=mask_left)
    val_right = cv2.mean(f, mask=mask_right)

Finally we have to draw our rectangles and save the new image :

.. code-block:: python

    # thickness=-1 cause the rectangle to be filled
    cv2.rectangle(f, (0,0), (bandwidth,h), color=val_left, thickness=-1)
    cv2.rectangle(f, (l-bandwidth,0), (l,h), color=val_right, thickness=-1)

    # just save !
    cv2.imwrite('test1.png', f)


And here we are \\o/ !

Hum, it has to be mentionned that OpenCV doc recommends to work on copied images in order to save the original.
Here, the source code doesn't do that, but you have to know this is a common (and encouraged) practice.

Second test : more details
==========================

Ok, now we have a beautiful example with one strip per side, let's try to improve that a bit.

We'll try to divide each side in ``nb`` regions.

Let's take a look at the wole code at once since it's not extremely different from the previous one :

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

    cv2.imwrite('test2.png', f)

Ok, except the mindf*ck behind coordinates, all the process was quite easy. And the result looks nice :

.. image:: /static/images/ambilight/multi.png
    :width: 450px
    :align: right

Timeit
------

Creating a function around this code, I've been able to ``%timeit`` inside iPython :::

    In [10]: %timeit ambi
    1000000 loops, best of 3: 189 ns per loop

I don't really know if this measurement is accurate but, if it is, we have a really nice system :)

Third test : a webcam video
===========================

The last test that'll be covered in this article is just a small tweak of the previous one :

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

As you can see, the wideo is pretty smooth and reactive.

And now ?
=========

Now we have a better idea about how to process an image to extract color info from its sides, we'll be able to go
further.

With some others guys from HAUM (local hackerspace) we'll try to build the complete system using leds and arduino.

We just wanna recreate this system for fun, and, as I'm writing, another idea comes to my mind : what about trying to
adapt general ambient light (not only next to screen) to the action on-screen ?

.. _Ambilight: http://en.wikipedia.org/wiki/Ambilight
.. _OpenCV: http://opencv.org/
.. _StackOverflow: http://stackoverflow.com/
.. _AUR: https://aur.archlinux.org/packages/?O=0&K=opencv
