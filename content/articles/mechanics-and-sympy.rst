===================
Mechanics and Sympy
===================

:date: 2015-01-04 11:28:41
:slug: mechanics-and-sympy
:authors: matael
:summary: Symbolic algebra for oscillator analysis
:tags: python, fac, imported

As an undergraduate student in physics, some of the code I write is related with mechanical problems.

This post is an attempt to find eigenpulsations and eigenvectors of a 5 degres of freedom oscillator using sympy.

What is Sympy
=============

While working with simple maths, Python's builtins and the ``math`` librairy should do the trick : you'll be able to
compute almost anything you need.

If your work requires a more powerful tool for numerical calculations, you should take a look at Numpy_ or Pylab and you
would get solution to your problem.

But if you want to work on symbolic maths (means maths with free *symbols* that represent part of the system), you'll
have to find a formal calculation framework or symbolic math framework.

Software exists to do that kind of stuff :

- SageMath_
- Mathematica_ (and WolframAlpha_)
- Some MatLab_ plugins
- Maple_

Sympy_ is a python lib (mostly python2) providing tools for symbolic algebra and resolution as well as numerical
computation. Finally, sympy does provide a way of exanching data and code with Sage, Matlab and Mathematica.

.. _Numpy: http://www.numpy.org/
.. _SageMath: http://www.sagemath.org/
.. _Mathematica: http://www.wolfram.com/mathematica/
.. _WolframAlpha: http://www.wolframalpha.com/
.. _MatLab: http://www.mathworks.com/
.. _Maple: http://www.maplesoft.com/
.. _Sympy: http://sympy.org/en/index.html


Installing Sympy
----------------

If you have ``pip`` just run :

.. code-block:: bash

    pip install sympy


(On **ArchLinux** make sure to use *Python2* and *pip2*)

On my system, I run Sympy 0.7.2.

Problem : 5DOF
==============

Let's take a look to our problem :

.. image:: /static/images/5ddl/oscil5.png
   :align: center

We have 5 coupled oscillators (spring-mass systems) with same mass and spring constant.

Each mass follow a movement named :math:`x_i = X_i\sin(\omega t);\forall i\in\{1,2,3,4,5\}`

We can write equations for this kind of system quite easily :

.. math::

    m
    \begin{pmatrix}
    1 & 0 & 0 & 0 & 0\\
    0 & 1 & 0 & 0 & 0\\
    0 & 0 & 1 & 0 & 0\\
    0 & 0 & 0 & 1 & 0\\
    0 & 0 & 0 & 0 & 1
    \end{pmatrix}
    \begin{pmatrix}
    \ddot{x_1}\\
    \ddot{x_2}\\
    \ddot{x_3}\\
    \ddot{x_4}\\
    \ddot{x_5}\\
    \end{pmatrix}
    +
    k
    \begin{pmatrix}
    2 & -1 & 0 & 0 & 0\\
    -1 & 2 & -1 & 0 & 0\\
    0 & -1 & 2 & -1 & 0\\
    0 & 0 & -1 & 2 & -1\\
    0 & 0 & 0 & -1 & 2
    \end{pmatrix}
    \begin{pmatrix}
    x_1\\
    x_2\\
    x_3\\
    x_4\\
    x_5\\
    \end{pmatrix} =
    \begin{pmatrix}
    0\\
    0\\
    0\\
    0\\
    0\\
    \end{pmatrix}

It comes :

.. math::

    \underbrace{
    \begin{pmatrix}
    (2\omega_0^2-\omega^2) & -\omega_0^2 & 0 & 0 & 0\\
    -\omega_0^2 & (2\omega_0^2-\omega^2) & -\omega_0^2 & 0 & 0\\
    0 & -\omega_0^2 & (2\omega_0^2-\omega^2) & -\omega_0^2 & 0\\
    0 & 0 & -\omega_0^2 & (2\omega_0^2-\omega^2) & -\omega_0^2\\
    0 & 0 & 0 & -\omega_0^2 & (2\omega_0^2-\omega^2)
    \end{pmatrix}
    }_S
    \underbrace{
    \begin{pmatrix}
    X_1\\
    X_2\\
    X_3\\
    X_4\\
    X_5\\
    \end{pmatrix}}_X =
    \underbrace{\begin{pmatrix}
    0\\
    0\\
    0\\
    0\\
    0\\
    \end{pmatrix}}_L

We now have to translate this maths into python instances :

.. code-block:: python

    from __future__ import print_function, division

    from sympy import Symbol, symbols, Matrix, zeros

    # Coefficient matrix
    a = Symbol('w0') # omega0
    w = Symbol('w') # omega

    S = Matrix([
        [(2*a**2-w**2),-a**2, 0, 0, 0],
        [-a**2, (2*a**2-w**2),-a**2, 0, 0],
        [0, -a**2, (2*a**2-w**2),-a**2, 0],
        [0, 0, -a**2, (2*a**2-w**2),-a**2],
        [0, 0, 0, -a**2, (2*a**2-w**2)]
    ])


    # movements amplitudes
    X1,X2,X3,X4,X5 = symbols('X1 X2 X3 X4 X5')

    X = Matrix([
        [X1],
        [X2],
        [X3],
        [X4],
        [X5]
    ])

    # initial conditions
    L = zeros(5,1)

Time to solve
=============

For this kind of problem, one (brutal) way to solve is to try to find eigenpulsations out of the :math:`S` matrix (means that
we have to find all :math:`w^2|det(S) = 0`).

Eigenpulsations
---------------

Finding the determinant of a :math:`5\times 5` matrix is not something really interesting, so let's get Python to do that :

.. code-block:: python

    determ = S.det_bareis()

We could have used ``det()`` instead of ``det_bareis()`` but the latter is preconised for matrices with symbols.

Now we must solve the equation : :math:`\det S = 0` for :math:`\omega^2`. Sympy provides something cool for that kind of thing :
``solve()``. So let's use it and print solutions next :

.. code-block:: python

    from sympy.solvers import solve
    from sympy import pprint # for pretty printing

    eigenpulsations = solve(determ, w**2)

    for n,s in enumerate(eigenpulsations):
        print("Solution "+str(n+1)+" :")
        print("------------")
        pprint(s)
        print('\n')

We can then see that our pulsations are :

.. math::
    \left\{
    \begin{array}{l}
    \omega_1^2 = (2-\sqrt{3})\omega_0^2\\
    \omega_2^2 = \omega_0^2\\
    \omega_3^2 = 2\omega_0^2\\
    \omega_4^2 = 3\omega_0^2\\
    \omega_5^2 = (2+\sqrt{3})\omega_0^2
    \end{array}
    \right.

It would have take a lot longer to find that out without a computer...

Eigenvectors
------------

When trying to understand how a system moves, finding its eigenvectors is really useful.

For us, it means solving the equation :

.. math::
    S_iX = L

Where :math:`S_i` is the :math:`S` matrix with all :math:`\omega^2` replaced by :math:`w_i \forall i\in\{1,2,3,4,5\}`.

To do that, we'll use the ``solve_linear_system()`` utility that takes a N*(M+1) matrix as a coefficient matrix, then
an unnested list of symbols to solve for and finally some arguments.

For example, to solve (from documentation) :

.. math::

    \begin{cases}
        x + 4 y =  2 \\
        -2 x +   y = 14
    \end{cases}


You would give to ``solve_linear_system()`` the following matrix :

.. math::

    \begin{pmatrix}
        1 & 4 & 2\\
        -2 & 1 & 14
    \end{pmatrix}

Here, we'll have to tweak a bit our matrices before solving them : we need to replace the global :math:`\omega^2` term by each
eigenpulsation :

.. code-block:: python

    from sympy import solve_linear_system

    for p in eigenpulsations:
        complete_sys = S[:,:]   # hard copy. Ensure to work always on a
                                # safe copy of our matrix

        # replace w**2 in matrix with current eigenpulsation
        for l in xrange(len(complete_sys)):
            complete_sys[l] = complete_sys[l].subs(w**2,p)

        # append the last column : the L matrix :)
        complete_sys = complete_sys.row_join(L)

        # solve the system without checking for zero denominators
        # in kinetics, a null denominator is only a resonnance, as our system doesn't
        # take damping into account, we can have null denominators
        res = solve_linear_system(complete_sys, X1, X2, X3, X4, X5, check=False)

        # print the solution we're working on
        print('=> w = '+str(p))

        # then print the found values for each Xi
        for k,v in res.items():
        print('---> '+str(k)+ ' = '+str(res[k]))

We will get 5 eigenvectors (one per eigenpulsation) :

.. math::
    \overrightarrow{V_1} = \begin{pmatrix}
    X_5\\\\
    X_5\sqrt{3}\\\\
    2X_5\\\\
    X_5\sqrt{3}\\\\
    X_5
    \end{pmatrix}
    ;
    \overrightarrow{V_2} = \begin{pmatrix}
    -X_5\\\\
    -X_5\\\\
    0\\\\
    X_5\\\\
    X_5
    \end{pmatrix}
    ;
    \overrightarrow{V_3} = \begin{pmatrix}
    X_5\\\\
    0\\\\
    -X_5\\\\
    0\\\\
    X_5
    \end{pmatrix}
    ;
    \overrightarrow{V_4} = \begin{pmatrix}
    -X_5\\\\
    X_5\\\\
    0\\\\
    -X_5\\\\
    X_5
    \end{pmatrix}
    ;
    \overrightarrow{V_5} = \begin{pmatrix}
    X_5\\\\
    -X_5\sqrt{3}\\\\
    2X_5\\\\
    -X_5\sqrt{3}\\\\
    X_5
    \end{pmatrix}

And here we are :)
We have found each of the pulsations and associated vector so we can basically understand how this system moves.

If we now want to go further, we should use the modal matrix :math:`\Phi` as :

.. math::
    \Phi = \{V_i ~;~ i \in\{1,2,3,4,5\} | \omega_i < \omega_{i+1}\}

One more degre ?
================

This method works, but if your try to solve with that script for a system with 6DOF, you'll notice that this is pretty
slow.... It's not really optimized and we could use some tricks to infer some eigenpulsations and vectors just analyzing
the system itself (without maths :))
