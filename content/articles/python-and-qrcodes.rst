==================
Python and QRCodes
==================

:date: 2015-01-04 11:28:38
:slug: python-and-qrcodes
:authors: matael
:summary: How to generate QRCodes using Python
:tags: python, qrcodes, imported

Few days ago, I decided to try to generate QRCodes.

This article just shows a possibility using Python.

Tools
=====

Googling for *QRCodes generation* I found some websites proposing to generate QRCodes for you.

.. image:: /static/images/qr/qr.png
    :width: 300px
    :align: right

The `ZXing Generator`_ and the `Kaywa Generator`_ seem really powerful and complete, but I was looking for a way of integring QRCode-generation in an piece of software without requiring an Internet access.

A guy (**MarkTraceur**) commented my post on reddit, talking about a tool he built : QRustom_ ! Thanks to him !

With python, you can use pyqrcode_ but it works using a C/C++ encoder and a Java decoder...

I also found the PyQRNative_ lib that seems to be a rewriting of this `javascript generator`_ (pretty sure great things can be done using this JS lib and Node.js_).

The code (that you can ``wget`` here_) would need a serious rewriting to become PEP8_ compliant and **documented** but it works (here's a QR containing URL for this post generated using PyQRNative).

**EDIT :** After my post on reddit, Chris Beaven told me he did the rewriting. His version is available on Pypi_. I've also rewritten this article using his lib.

Note that you'll have also to install the `Python Imaging Library`_ (PIL) in order to generate the images themselves.

Just run :

.. sourcecode:: bash

    $ sudo pip install pil qrcode

Usage
=====


.. sourcecode:: python

    from qrcode import *

    qr = QRCode(version=20, error_correction=ERROR_CORRECT_L)
    qr.add_data("http://blog.matael.org/")
    qr.make() # Generate the QRCode itself

    # im contains a PIL.Image.Image object
    im = qr.make_image()

    # To save it
    im.save("filename.png")

At line 3, we instanciate a new ``qrcode.QRCode`` object using two parameters.
This class has other parameters that we don't use here (``box_size``, ``border``, etc...).

The first one is the QR version, an integer between 0 and 40 which define the size of the barcode and the amount of data we'll be able to store.

The second is the correction level (redundancy).
As said on Wikipedia_, you can choose between :

``ERROR_CORRECT_L``
    7% of codewords can be restored
``ERROR_CORRECT_M`` (default)
    15% can be restored
``ERROR_CORRECT_Q``
    25% can be restored
``ERROR_CORRECT_H``
    30% can be restored

It's this redundancy phenomenon that enables decoding even if the code is damaged.

When the lib guess what you need
--------------------------------

The ``qrcode`` module add the ``fit`` parameter to the ``QRCode.make()`` method. If ``fit`` is used and ``QRCode.version`` is set to ``None``, ``qrcode`` will guess the right version. 

Faster !
--------

This rewriting bring a short version for fast generation :

.. sourcecode:: python
  
    import qrcode
    img = qrcode.make("your awesome data")

**Chris, thank you for that great work !**

Conclusion
==========

QR Codes are an elegant way of share data between devices.

They can be used for a lot of applications, from product tracking inside a factory to blog post URL.

The redundancy phenomenon allow artistic use or deformation of QR Codes and things like that :

.. image:: /static/images/qr/qr_matael.png
    :width: 300px
    :align: center

I really think that these codes are powerful.

Note also that, using processing_ and QR Codes, you can do `Augmented Reality`_ ;)


  
  
.. _ZXing Generator: http://zxing.appspot.com/generator/
.. _Kaywa Generator: http://qrcode.kaywa.com/
.. _pyqrcode: http://pyqrcode.sourceforge.net/
.. _PyQRNative: http://code.google.com/p/pyqrnative/
.. _javascript generator: http://d-project.googlecode.com/svn/trunk/misc/qrcode/js/qrcode.js
.. _Node.js: http://nodejs.org/
.. _here: http://pyqrnative.googlecode.com/svn/trunk/pyqrnative/src/PyQRNative.py
.. _PEP8: http://www.python.org/dev/peps/pep-0008/
.. _Python Imaging Library: http://www.pythonware.com/products/pil/
.. _Wikipedia: http://en.wikipedia.org/wiki/QR_code
.. _processing: http://processing.org
.. _Augmented Reality: http://answers.oreilly.com/topic/1337-how-to-do-augmented-reality-in-processing/
.. _QRustom: https://qrustom.com/
.. _Pypi: http://pypi.python.org/pypi/qrcode
