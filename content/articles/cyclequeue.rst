==========
CycleQueue
==========

:date: 2015-01-04 11:28:40
:slug: cyclequeue
:authors: matael
:summary: Extension d'une classe utile en Python
:tags: python, ambilight, imported

Pour un très prochain article sur l'ambilight_, nous allons avoir besoin d'une version augmentée de ``Queue.Queue``.

Cette classe (faisant partie de la bibliothèque standard de python) permet de créer une file d'attente. Elle simplifie
part ailleurs la gestion de la communication entre *threads*.

Nous allons l'étendre de manière à pouvoir mémoriser un état de la file et revenir à tout moment à cet état.
Le *workflow* final attendu est le suivant :

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


Ecriture de la classe
=====================

.. code-block:: python

    import Queue

    class CycleQueue(Queue.Queue):
        """ Particular Queue with new method reinit to get back to
        initial state.

        Standard use :

            q = CycleQueue()

            q.put('elem1')
            q.put('elem2')
            # etc...

            # lock current state, say state1
            q.lockstate()

            q.get()
            # etc... 'till queue is empty

            q.reinit() # get back to state1

        """

        def __init__(self, *args, **kw):
            Queue.Queue.__init__(self, *args, **kw)
            self._backup = []

        def lockstate(self):
            """ Lock current state """

            for i in self.queue:
                self._backup.append(i)


        def reinit(self):
            """ Get back to previous locked state """

            # check if a non-empty backup exists
            if self._backup == []:
                raise IndexError('Backup list is empty')

            # reset the queue
            self.queue.clear()

            # push locked elements back to queue
            for t in self._backup: self.put(t)

Le code n'a rien de très compliqué. Notez simplement l'utilsation des variables ``*args`` et ``**args`` pour le passage
de tous les arguments d'un coup.

En fait, on vient juste cloner la classe ``Queue.Queue()`` et lui ajouter les 2 méthodes utiles. On s'assure ainsi une
compatibilité parfaite avec celle ci.

Tests
=====

Nous allons aussi écrire quelques tests pour s'assurer du bon fonctionnement de notre extension :

.. code-block:: python

    import unittest
    from utilities import CycleQueue

    elements = ['a','b','c','d']

    class TestCycleQueue(unittest.TestCase):


        # test pour la fonction lockstate()
        def test_lock(self):

            # instanciation d'une CycleQueue
            q = CycleQueue()

            # ajout d'éléments
            for e in elements:
                q.put(e)

            # verrouillage
            q.lockstate()

            # vérification du backup
            # le test ne passe pas si un élément du backup
            # diffère de son semblable dans la queue
            for i in xrange(len(elements)):
                self.assertTrue(
                    q._backup[i] == q.queue[i]
                )

        # test de reinit()
        def test_reinit(self):

            # instanciation
            q = CycleQueue()

            # on charge la file
            for e in elements:
                q.put(e)

            # on la verrouille
            q.lockstate()

            # on supprime quelques éléments
            q.get(); q.task_done()
            q.get(); q.task_done()

            # ré-initialisation
            q.reinit()

            # on vérifie la conformité vis à vis de la
            # liste originelle
            for i in xrange(len(elements)):
                self.assertTrue(
                    q._backup[i] == elements[i]
                )


    if __name__=='__main__':
        unittest.main()

Rien de compliqué là non plus, simplement quelques tests.

On va s'arrêter là donc :)

Vous pouvez lancer les tests via :

.. code-block:: bash

    $ python utilities_tests.py

On aurait pu tester aussi que l'exception ``IndexError`` était bien levée, mais cela n'a pas grande utilité. Une autre
fois peut être.

.. _ambilight: http://blog.matael.org/writing/a-first-try-at-ambilight/


