Stardew Reporter prints out information of various kinds about a `Stardew Valley`_ save file. It's useful for getting an overview of your farm. Its counts of items aggregate across all containers in your farmhouse, farmland, and farm buildings. The output looks like this::

    --- ITEMS
              Gold Pickaxe
              Iridium Rod
              Master Slingshot
              [ etc. ]
           59 Clay
          874 Fiber
           66 Hardwood
          885 Stone
        1,118 Wood
           31 Coal
            3 Copper Ore
            3 Gold Bar
           16 Gold Ore
              Iridium Bar
            6 Iridium Ore
              Chest
            2 Feed Hopper
              Heater
              Rarecrow
            6 Scarecrow
              Singing Stone
              Iridium Sprinkler
           76 Quality Sprinkler
            5 Autumn's Bounty
              [ etc. ]

    --- TERRAIN
          292 Grass
          643 HoeDirt
           91 Stone (static)
           38 Tree (maple, immature)
           39 Tree (maple, tapped)
           10 Tree (maple, untapped)
           26 Tree (oak, immature)
              Tree (oak, tapped)
           67 Tree (oak, untapped)
           45 Tree (pine, immature)
          165 Tree (pine, untapped)
           65 Twig
           67 Weeds

    --- PLOTS
          176 Blueberry
           15 Corn
           15 Melon
          417 dead plant
           20 empty

    --- PRODUCERS
              Bee House (Honey - in progress)
              Charcoal Kiln
            2 Cheese Press (Cheese - done)
              Crystalarium (Diamond - done)
            6 Furnace
              Keg (Strawberry Wine - done)
            4 Keg (Strawberry Wine - in progress)
              Lightning Rod
            2 Mayonnaise Machine (Mayonnaise - done)
            2 Preserves Jar (Strawberry Jelly - in progress)
            2 Recycling Machine
            5 Tapper (Maple Syrup - done)
           34 Tapper (Maple Syrup - in progress)
              Tapper (Oak Resin - done)

    --- ANIMALS
            2 Chicken, Brown
              Cow, Brown
              Cow, White

Usage
----------------------------------------

The program is tested with save files produced by Stardew Valley 1.06.

`Download the compiled program`__, and if you're on Windows, install `Python 2.7`_ if you haven't already. Edit the value of ``FARMER_ID`` near the top of the program to match the name of the save file, which will be of the form ``[Name of your character]_[Some number]``; look in your save folder for the exact name. Unless you're on Windows, you'll also need to edit ``SAVES_DIR`` to point to the directory with your save files in it. Now you can run the program, which on Windows you can accomplish by right-clicking the file and choosing "Edit with IDLE", then choosing the menu option "Run Module". On Unix-likes, the command ``python stardew_reporter.py`` will suffice.

__ http://arfer.net/downloads/stardew_reporter.zip

Development
----------------------------------------

Please `send me`__ bug reports.

.. __: http://arfer.net/elsewhere

The program is written in Hy_ 0.10.0 and uses Kodhy_. However, neither of these is required at runtime if you use the compiled Python program linked above.

License
----------------------------------------

This program is copyright 2016 Kodi Arfer.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the `GNU General Public License`_ for more details.

.. _`Stardew Valley`: http://stardewvalley.net
.. _`Python 2.7`: https://www.python.org/
.. _Hy: http://hylang.org
.. _Kodhy: https://github.com/Kodiologist/Kodhy
.. _`GNU General Public License`: http://www.gnu.org/licenses/
