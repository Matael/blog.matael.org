=============================
Ambilight v2 : Threads Inside
=============================

:date: 2015-01-04 11:28:41
:slug: ambilight-v2-threads-inside
:authors: matael
:summary: Après une première série de tests, boostons le script (fr)
:tags: python, arduino, opencv, ambilight, imported

Au cours d'un `précédent article`_ (en anglais), j'avais décrit une série de tests préliminaires à la fabrication d'un
système ambilight-like DIY.

Au cours d'un test sur une machine un peu moins puissante, on a noté (quelques bidouilleurs du HAUM_ et moi-même) une
certaine lenteur dans le processus.

L'article de la dernière fois statuait ainsi sur le résultat du dernier bout de code :

    As you can see, the video is pretty smooth and reactive.

C'était effectivement le cas, mais pas sur toutes les machines...

Le bout de code était le suivant :

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

Par rapport au dernier article (pour le code n'avait été testé que sous Arch), j'ai ajouté les deux dernières lignes.
En effet, sans celles ci, l'ubuntu installé sur le netbook ne veut rien savoir et refuser d'afficher quoi que ce soit.

Bien, nous allons procéder ainsi :

- analyse du code existant pour déterminer ses points faibles (et il y en a)
- réécriture pas à pas du code (en expliquant notament les principales bases de programmation multi-processus en python)

Analyse
=======

Ce code a plusieurs problèmes, le premier et le plus évident (qui est pardonnable : c'est un simple *proof of concept*)
est qu'il ne contient aucune gestion des erreurs (*quid* si la caméra n'est pas trouvée par exemple ?).
Je ne m'attarderais pas beaucoup sur ce point, mais dans un projet fini, il faudrait veiller à gérer ça.

Si vous regardez bien, vous verrez combien la méthode est sale. L'algo fait ça :::

    Faire toujours
        Récupérer une image

        Pour chaque i dans le nombre de "régions"
            Créer un masque blanc pour la zone droite
            Créer un masque blanc pour la zone gauche

            Pour chaque i dans dh
                Pour chaque j dans bandwidth
                    Remplacer le point (i,j) par un 1 dans le masque droit
                    Remplacer le point (i,j) par un 1 dans le masque gauche
                Fin Pour
            Fin Pour

            Calculer la moyenne à gauche
            Calculer la moyenne à droite

            Tracer le rectangle de droite
            Tracer le rectangle de gauche
        Fin Pour

    Fin faire

L'oeil avertit aura bien évidement que le calcul des masques pour chaque zone pourrait être fait une et une seul fois et
ceux ci stockés une bonne fois pour toutes.

Il en va de même pour le calcul des zones elles même : on pourrait calculer une fois pour toute les 2 points les
délimitant et s'en resserir à chaque nouvelle image.

Enfin, vous noterez que seul le tracé des rectangle modifie l'image, tout le reste se contente de la lire : on devrait
pouvoir parallèliser ça.

L'idée est d'arriver à un truc comme ça : le programme se charge de récupérer une image, de pré-calculer les masques et
les zones. Il *spawn* ensuite une série de workers : plusieurs pour faire les moyennes de couleur des zones en parallèle
et un pour tracer les rectangles.

Préliminaires
=============

CycleQueue
----------

Quand on traite avec des *threads*, il est courant d'utiliser ``Queue.Queue()`` pour générer une file d'attente entre
les données fourni par un *thread* et consommées par un autre. J'ai pris la liberté d'étendre un peu cette classe
histoire de pouvoir "bloquer" un état de la file d'attente et de rappeller cet état. L'écriture de cette classe
augmentée est détaillée dans un `autre article`_.

Voilà juste un exemple d'utilisation :

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

En programmation orienté objet, le *singleton* est un *design pattern* bien connu.
Il s'agit d'écrire une classe qui renverra toujours la même instance d'elle même.

Je suis pas un grand fan de réinvention de roue, StackOverflow_ propose une excellente manière d'implémenter ce *pattern*
en python.

Voilà donc le décorateur que j'ai utilisé (dans ``utilities.py``):

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

Il suffira alors de décorer les classes que l'on veut *singleton* par ``@Singleton``.
Ici, c'est la classe qui retient l'image elle même (et son double modifié) qui sera un *singleton* :

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

Globales
========

On fait souvent la guerre aux globales, mais ici, ça me permet d'avoir des appels de fonction relativement court et de
simplifier l'écriture. Voilà donc les globales :

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

Calcul des masques et des zones
-------------------------------

On va en profiter pour remplir ``masks`` avec les masques en question. En fait, on va écrire une fonction qui sera
appellée dans ``main()`` pour faire ça. Même si ``masks`` est globale, je la passe en argument à la fonction (ainsi que
la ``CycleQueue`` contenant les zones) pour rendre cette fonction plus portable.

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

Je pense que le code est assez clair (si vous pensez que ce n'est pas le cas, dites le moi en commentaire et je
tacherais de l'expliquer).

Nous avons désormais de quoi alimenter nos *workers*.

Workers
=======

Ecrivons maintenant nos 2 *workers* :

- le moyennage des couleurs d'une part
- le tracé des rectangles

Pourquoi *threader* la deuxième partie ?
----------------------------------------

Le fait de *threader* le tracé des rectangle permet de commencer à tracer avant la fin des moyennes.
Pour cela, les 2 programmes discuteront via une ``Queue()`` les *workers* moyennant ajoutant les zones et couleurs
moyennes à la file que le *worker* dessinant viendra lire ensuite.

On veillera bien à attendre la vidange des 2 files (celle des zones, alimentant les *workers* moyennant et celle entre
moyenneurs et dessinateur) avant de changer de *frame*.

Rappels sur les threads
-----------------------

Les deux workers hériteront de ``threading.Thread``.

La création d'un *thread* en python est assez simple (comparé à d'autres langages).

On crée une classe héritant de ``threading.Thread`` et on écrit 2 méthodes au moins : ``__init__`` et ``run``.

La première contient comme d'habitude les éléments d'initialisation et obligatoirement :

.. code-block:: python

    threading.Thread.__init__(self)

Pour assurer la mise en place complète de la classe parente.

La seconde contient le code exécuté au sein du *thread*.

Un *thread* se code comme suit (ici un *thread* disant bonjour :

.. code-block:: python

    from time import sleep
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

Ici, nous allons utiliser des ``Queue()`` pour faire discuter nos *threads*. Il faut savoir que d'autres mécanismes
existent : *mutex*, *semaphores*, *locks*, etc...

Pour plus d'info, vous pouvez jeter un oeil à la doc_.

Moyenneur
---------

Voilà le code de notre ami le moyenneur :

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

Rien de compliqué hein ? Normal :) tout le boulot est fait avant et les threads ne sont que des coques quasi-vides :)

Remarquez toutefois l'utilisation de :

.. code-block:: python

    IMG.Instance().image

Qui renvoie bien l'attribut ``image`` de l'instance unique de la classe ``IMG`` qui est un *singleton*.

Dessinateur
-----------

Deuxième *thread* à peine plus compliqué :

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

A noter que je ne crée la variable ``zone`` que pour alléger l'écriture.
Notez là encore les *tuples* dans l'appel de ``cv2.rectangle``.

Finalement, la toute dernière chose à remarqué est que nous modifions ``IMG.Instance().final_image`` et non
``IMG.Instance().image``. Cela nous évite d'utiliser des verrous et simplifie un peu la gestion.

La main()
=========

Enfin, nous pouvons écrire le chef d'ochestre : la ``main()``.

Vous y trouverez une étrange ressemblance avec ce qui avait été écrit dans le `précédent article`_ :

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


Et voilà !

Conclusion
==========

Cet article était un peu long, mais il pose plusieurs concepts :

- d'une part il revient sur des notions d'orienté objet
- il présente succintement la mise en place de *threads* en python
- il constitue un réécriture complète d'un script très crade
- enfin, il revient sur des notions de modularité : presque tous les éléments peuvent être réécrits ou
  modifiés/augmentés presque sans effort.

Pour ceux qui voudraient le code complet, il est disponible ici_.

En espérant que ça vous a montré quelque chose ;)

.. _précédent article: http://blog.matael.org/writing/a-first-try-at-ambilight/
.. _HAUM: http://haum.org
.. _autre article: http://blog.matael.org/writing/cyclequeue/
.. _StackOverflow: http://stackoverflow.com/questions/42558/python-and-the-singleton-pattern
.. _doc: http://docs.python.org/2/library/threading.html
.. _ici: /static/files/ambilight/code_threaded.zip
