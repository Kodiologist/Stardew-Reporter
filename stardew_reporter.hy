(import os)
(setv FARMER-ID "Farmerguy_117831755")
(setv SAVES-DIR (os.path.join (or (.get os.environ "APPDATA") "") "StardewValley" "Saves"))

(require kodhy.macros)

(import
  sys
  os
  [collections [Counter namedtuple]]
  xml.etree.ElementTree)

(when (> (len sys.argv) 1)
  (setv [SAVES-DIR FARMER-ID] (slice sys.argv 1)))

; ------------------------------------------------------------
; * Declarations
; ------------------------------------------------------------

(defn dec [x] (- x 1))

(setv ns {"xsi" "http://www.w3.org/2001/XMLSchema-instance" "xsd" "http://www.w3.org/2001/XMLSchema"})
(defn xsi [s] (+ "{" (get ns "xsi") "}" s))
(setv null-attrib {(xsi "nil") "true"})

(defn find [xml-elem path] (.find xml-elem path ns))
(defn findall [xml-elem path] (.findall xml-elem path ns))

(defn kid-text [xml-elem path] (whenn (find xml-elem path) it.text))
(defn kid-int [xml-elem path] (whenn (find xml-elem path) (int it.text)))
(defn kid-bool [xml-elem path] (whenn (find xml-elem path) (= it.text "true")))

(setv ITEM-NUMS {
  None "empty"
  0 "Weeds" 2 "Stone" 4 "Stone" 16 "Wild Horseradish" 18 "Daffodil" 20 "Leek" 22 "Dandelion" 24 "Parsnip" 30 "Lumber" 60 "Emerald" 62 "Aquamarine" 64 "Ruby" 66 "Amethyst" 68 "Topaz" 70 "Jade" 72 "Diamond" 74 "Prismatic Shard" 78 "Cave Carrot" 80 "Quartz" 82 "Fire Quartz" 84 "Frozen Tear" 86 "Earth Crystal" 88 "Coconut" 90 "Cactus Fruit" 92 "Sap" 93 "Torch" 94 "Spirit Torch" 96 "Dwarf Scroll I" 97 "Dwarf Scroll II" 98 "Dwarf Scroll III" 99 "Dwarf Scroll IV" 100 "Chipped Amphora" 101 "Arrowhead" 102 "Lost Book" 103 "Ancient Doll" 104 "Elvish Jewelry" 105 "Chewing Stick" 106 "Ornamental Fan" 107 "Dinosaur Egg" 108 "Rare Disc" 109 "Ancient Sword" 110 "Rusty Spoon" 111 "Rusty Spur" 112 "Rusty Cog" 113 "Chicken Statue" 114 "Ancient Seed" 115 "Prehistoric Tool" 116 "Dried Starfish" 117 "Anchor" 118 "Glass Shards" 119 "Bone Flute" 120 "Prehistoric Handaxe" 121 "Dwarvish Helm" 122 "Dwarf Gadget" 123 "Ancient Drum" 124 "Golden Mask" 125 "Golden Relic" 126 "Strange Doll" 127 "Strange Doll" 128 "Pufferfish" 129 "Anchovy" 130 "Tuna" 131 "Sardine" 132 "Bream" 136 "Largemouth Bass" 137 "Smallmouth Bass" 138 "Rainbow Trout" 139 "Salmon" 140 "Walleye" 141 "Perch" 142 "Carp" 143 "Catfish" 144 "Pike" 145 "Sunfish" 146 "Red Mullet" 147 "Herring" 148 "Eel" 149 "Octopus" 150 "Red Snapper" 151 "Squid" 152 "Seaweed" 153 "Green Algae" 154 "Sea Cucumber" 155 "Super Cucumber" 156 "Ghostfish" 157 "White Algae" 158 "Stonefish" 159 "Crimsonfish" 160 "Angler" 161 "Ice Pip" 162 "Lava Eel" 163 "Legend" 164 "Sandfish" 165 "Scorpion Carp" 166 "Treasure Chest" 167 "Joja Cola" 168 "Trash" 169 "Driftwood" 170 "Broken Glasses" 171 "Broken CD" 172 "Soggy Newspaper" 174 "Large Egg" 176 "Egg" 178 "Hay" 180 "Egg" 182 "Large Egg" 184 "Milk" 186 "Large Milk" 188 "Green Bean" 190 "Cauliflower" 192 "Potato" 194 "Fried Egg" 195 "Omelet" 196 "Salad" 197 "Cheese Cauliflower" 198 "Baked Fish" 199 "Parsnip Soup" 200 "Vegetable Medley" 201 "Complete Breakfast" 202 "Fried Calamari" 203 "Strange Bun" 204 "Lucky Lunch" 205 "Fried Mushroom" 206 "Pizza" 207 "Bean Hotpot" 208 "Glazed Yams" 209 "Carp Surprise" 210 "Hashbrowns" 211 "Pancakes" 212 "Salmon Dinner" 213 "Fish Taco" 214 "Crispy Bass" 215 "Pepper Poppers" 216 "Bread" 218 "Tom Kha Soup" 219 "Trout Soup" 220 "Chocolate Cake" 221 "Pink Cake" 222 "Rhubarb Pie" 223 "Cookie" 224 "Spaghetti" 225 "Fried Eel" 226 "Spicy Eel" 227 "Sashimi" 228 "Maki Roll" 229 "Tortilla" 230 "Red Plate" 231 "Eggplant Parmesan" 232 "Rice Pudding" 233 "Ice Cream" 234 "Blueberry Tart" 235 "Autumn's Bounty" 236 "Pumpkin Soup" 237 "Super Meal" 238 "Cranberry Sauce" 239 "Stuffing" 240 "Farmer's Lunch" 241 "Survival Burger" 242 "Dish O' The Sea" 243 "Miner's Treat" 244 "Roots Platter" 245 "Sugar" 246 "Wheat Flour" 247 "Oil" 248 "Garlic" 250 "Kale" 252 "Rhubarb" 254 "Melon" 256 "Tomato" 257 "Morel" 258 "Blueberry" 259 "Fiddlehead Fern" 260 "Hot Pepper" 262 "Wheat" 264 "Radish" 266 "Red Cabbage" 268 "Starfruit" 270 "Corn" 272 "Eggplant" 274 "Artichoke" 276 "Pumpkin" 278 "Bok Choy" 280 "Yam" 281 "Chanterelle" 282 "Cranberries" 283 "Holly" 284 "Beet" 286 "Cherry Bomb" 287 "Bomb" 288 "Mega Bomb" 290 "Stone" 294 "Twig" 295 "Twig" 296 "Salmonberry" 297 "Grass Starter" 298 "Hardwood Fence" 299 "Amaranth Seeds" 300 "Amaranth" 301 "Grape Starter" 302 "Hops Starter" 303 "Pale Ale" 304 "Hops" 305 "Void Egg" 306 "Mayonnaise" 307 "Duck Mayonnaise" 309 "Acorn" 310 "Maple Seed" 311 "Pine Cone" 313 "Weeds" 314 "Weeds" 315 "Weeds" 316 "Weeds" 317 "Weeds" 318 "Weeds" 319 "Weeds" 320 "Weeds" 321 "Weeds" 322 "Wood Fence" 323 "Stone Fence" 324 "Iron Fence" 325 "Gate" 326 "Dwarvish Translation Guide" 328 "Wood Floor" 329 "Stone Floor" 330 "Clay" 331 "Weathered Floor" 333 "Crystal Floor" 334 "Copper Bar" 335 "Iron Bar" 336 "Gold Bar" 337 "Iridium Bar" 338 "Refined Quartz" 340 "Honey" 341 "Tea Set" 342 "Pickles" 343 "Stone" 344 "Jelly" 346 "Beer" 347 "Rare Seed" 348 "Wine" 349 "Energy Tonic" 350 "Juice" 351 "Muscle Remedy" 368 "Basic Fertilizer" 369 "Quality Fertilizer" 370 "Basic Retaining Soil" 371 "Quality Retaining Soil" 372 "Clam" 373 "Golden Pumpkin" 376 "Poppy" 378 "Copper Ore" 380 "Iron Ore" 382 "Coal" 384 "Gold Ore" 386 "Iridium Ore" 388 "Wood" 390 "Stone" 392 "Nautilus Shell" 393 "Coral" 394 "Rainbow Shell" 395 "Coffee" 396 "Spice Berry" 397 "Sea Urchin" 398 "Grape" 399 "Spring Onion" 400 "Strawberry" 401 "Straw Floor" 402 "Sweet Pea" 403 "Field Snack" 404 "Common Mushroom" 405 "Wood Path" 406 "Wild Plum" 407 "Gravel Path" 408 "Hazelnut" 409 "Crystal Path" 410 "Blackberry" 411 "Cobblestone Path" 412 "Winter Root" 413 "Blue Slime Egg" 414 "Crystal Fruit" 415 "Stepping Stone Path" 416 "Snow Yam" 417 "Sweet Gem Berry" 418 "Crocus" 419 "Vinegar" 420 "Red Mushroom" 421 "Sunflower" 422 "Purple Mushroom" 423 "Rice" 424 "Cheese" 425 "Fairy Seeds" 426 "Goat Cheese" 427 "Tulip Bulb" 428 "Cloth" 429 "Jazz Seeds" 430 "Truffle" 431 "Sunflower Seeds" 432 "Truffle Oil" 434 "Stardrop" 436 "Goat Milk" 437 "Red Slime Egg" 438 "L. Goat Milk" 439 "Purple Slime Egg" 440 "Wool" 441 "Explosive Ammo" 442 "Duck Egg" 444 "Duck Feather" 446 "Rabbit's Foot" 449 "Stone Base" 450 "Stone" 452 "Weeds" 453 "Poppy Seeds" 454 "Ancient Fruit" 455 "Spangle Seeds" 456 "Algae Soup" 457 "Pale Broth" 458 "Bouquet" 460 "Mermaid's Pendant" 461 "Decorative Pot" 463 "Drum Block" 464 "Flute Block" 465 "Speed-Gro" 466 "Deluxe Speed-Gro" 472 "Parsnip Seeds" 473 "Bean Starter" 474 "Cauliflower Seeds" 475 "Potato Seeds" 476 "Garlic Seeds" 477 "Kale Seeds" 478 "Rhubarb Seeds" 479 "Melon Seeds" 480 "Tomato Seeds" 481 "Blueberry Seeds" 482 "Pepper Seeds" 483 "Wheat Seeds" 484 "Radish Seeds" 485 "Red Cabbage Seeds" 486 "Starfruit Seeds" 487 "Corn Seeds" 488 "Eggplant Seeds" 489 "Artichoke Seeds" 490 "Pumpkin Seeds" 491 "Bok Choy Seeds" 492 "Yam Seeds" 493 "Cranberry Seeds" 494 "Beet Seeds" 495 "Spring Seeds" 496 "Summer Seeds" 497 "Fall Seeds" 498 "Winter Seeds" 499 "Ancient Seeds" 516 "Small Glow Ring" 517 "Glow Ring" 518 "Small Magnet Ring" 519 "Magnet Ring" 520 "Slime Charmer Ring" 521 "Warrior Ring" 522 "Vampire Ring" 523 "Savage Ring" 524 "Ring of Yoba" 525 "Sturdy Ring" 526 "Burglar's Ring" 527 "Iridium Band" 528 "Jukebox Ring" 529 "Amethyst Ring" 530 "Topaz Ring" 531 "Aquamarine Ring" 532 "Jade Ring" 533 "Emerald Ring" 534 "Ruby Ring" 535 "Geode" 536 "Frozen Geode" 537 "Magma Geode" 538 "Alamite" 539 "Bixite" 540 "Baryte" 541 "Aerinite" 542 "Calcite" 543 "Dolomite" 544 "Esperite" 545 "Fluorapatite" 546 "Geminite" 547 "Helvite" 548 "Jamborite" 549 "Jagoite" 550 "Kyanite" 551 "Lunarite" 552 "Malachite" 553 "Neptunite" 554 "Lemon Stone" 555 "Nekoite" 556 "Orpiment" 557 "Petrified Slime" 558 "Thunder Egg" 559 "Pyrite" 560 "Ocean Stone" 561 "Ghost Crystal" 562 "Tigerseye" 563 "Jasper" 564 "Opal" 565 "Fire Opal" 566 "Celestine" 567 "Marble" 568 "Sandstone" 569 "Granite" 570 "Basalt" 571 "Limestone" 572 "Soapstone" 573 "Hematite" 574 "Mudstone" 575 "Obsidian" 576 "Slate" 577 "Fairy Stone" 578 "Star Shards" 579 "Prehistoric Scapula" 580 "Prehistoric Tibia" 581 "Prehistoric Skull" 582 "Skeletal Hand" 583 "Prehistoric Rib" 584 "Prehistoric Vertebra" 585 "Skeletal Tail" 586 "Nautilus Fossil" 587 "Amphibian Fossil" 588 "Palm Fossil" 589 "Trilobite" 590 "Artifact Spot" 591 "Tulip" 593 "Summer Spangle" 595 "Fairy Rose" 597 "Blue Jazz" 599 "Sprinkler" 604 "Plum Pudding" 605 "Artichoke Dip" 606 "Stir Fry" 607 "Roasted Hazelnuts" 608 "Pumpkin Pie" 609 "Radish Salad" 610 "Fruit Salad" 611 "Blackberry Cobbler" 612 "Cranberry Candy" 613 "Apple" 618 "Bruschetta" 621 "Quality Sprinkler" 628 "Cherry Sapling" 629 "Apricot Sapling" 630 "Orange Sapling" 631 "Peach Sapling" 632 "Pomegranate Sapling" 633 "Apple Sapling" 634 "Apricot" 635 "Orange" 636 "Peach" 637 "Pomegranate" 638 "Cherry" 645 "Iridium Sprinkler" 648 "Coleslaw" 649 "Fiddlehead Risotto" 651 "Poppyseed Muffin" 668 "Stone" 670 "Stone" 674 "Weeds" 675 "Weeds" 676 "Weeds" 677 "Weeds" 678 "Weeds" 679 "Weeds" 680 "Green Slime Egg" 681 "Rain Totem" 682 "Mutant Carp" 684 "Bug Meat" 685 "Bait" 686 "Spinner" 687 "Dressed Spinner" 688 "Warp Totem: Farm" 689 "Warp Totem: Mountains" 690 "Warp Totem: Beach" 691 "Barbed Hook" 692 "Lead Bobber" 693 "Treasure Hunter" 694 "Trap Bobber" 695 "Cork Bobber" 698 "Sturgeon" 699 "Tiger Trout" 700 "Bullhead" 701 "Tilapia" 702 "Chub" 703 "Magnet" 704 "Dorado" 705 "Albacore" 706 "Shad" 707 "Lingcod" 708 "Halibut" 709 "Hardwood" 710 "Crab Pot" 715 "Lobster" 716 "Crayfish" 717 "Crab" 718 "Cockle" 719 "Mussel" 720 "Shrimp" 721 "Snail" 722 "Periwinkle" 723 "Oyster" 724 "Maple Syrup" 725 "Oak Resin" 726 "Pine Tar" 727 "Chowder" 728 "Fish Stew" 729 "Escargot" 730 "Lobster Bisque" 731 "Maple Bar" 732 "Crab Cakes" 734 "Woodskip" 745 "Strawberry Seeds" 746 "Jack-O-Lantern" 747 "Rotten Plant" 748 "Rotten Plant" 749 "Omni Geode" 750 "Weeds" 751 "Stone" 760 "Stone" 762 "Stone" 764 "Stone" 765 "Stone" 766 "Slime" 767 "Bat Wing" 768 "Solar Essence" 769 "Void Essence" 770 "Mixed Seeds" 771 "Fiber" 772 "Oil of Garlic" 773 "Life Elixir" 774 "Wild Bait" 775 "Glacierfish" 784 "Weeds" 785 "Weeds" 786 "Weeds" 787 "Battery Pack" 788 "Lost Axe" 789 "Lucky Purple Shorts" 790 "Berry Basket"})
(setv PRODUCERS (frozenset [
  "Bee House" "Cheese Press" "Keg" "Loom" "Mayonnaise Machine" "Oil Maker" "Preserves Jar" "Tapper" "Charcoal Kiln" "Crystalarium" "Furnace" "Lightning Rod" "Recycling Machine" "Seed Maker" "Slime Egg-Press" "Slime Incubator" "Worm Bin"]))

(setv ItemType (namedtuple "ItemType" (qw name category)))

(setv items (Counter))
(setv terrain-features (Counter))
(setv plots (Counter))
(setv producers (Counter))
(setv animals (Counter))

(defn add-items [l]
  (for [item l]
    (when (= item.attrib null-attrib)
      (continue))
    (setv count (kid-int item "Stack"))
    (when (= count -1)
      ; This is some kind of code representing the state of the
      ; item. There should only be one item in this stack.
      (setv count 1))
    (setv name (kid-text item "Name"))
    (setv category (kid-int item "category"))
    (setv producer? (in name PRODUCERS))
    (setv held (kid-text item "heldObject/Name"))
    (when held
      (setv state (cond
        [(not-in (kid-int item "minutesUntilReady") [None 0 1])
          "in progress"]
        [(kid-bool item "readyForHarvest")
          "done"]))
      (setv name (if state
        (.format "{} ({} - {})" name held state)
        (.format "{} ({} inside)" name held))))
    (when (and (= name "Stone") (= category 0))
      (setv name "Stone (static)"))
    (setv o (kwc ItemType :name name :category category))
    (cond
      [producer?
        (+= (get producers name) count)]
      [(in name ["Stone (static)" "Twig" "Weeds"])
        (+= (get terrain-features name) count)]
      [True
        (+= (get items o) count)])
    (add-items (findall item "items/Item"))))

(defn add-terrain-features [l]
  (for [tf l]
    (setv ttype (get tf.attrib (xsi "type")))
    (cond
      [(= ttype "Tree")
        (setv ttype (.format "Tree ({})" (.join ", " (+
          [(get (qw oak maple pine) (dec (kid-int tf "treeType")))]
          [(cond
            [(kid-bool tf "tapped")
              "tapped"]
            [(<= (kid-int tf "growthStage") 3)
              "immature"]
            [True
              "untapped"])]
          (if (kid-bool tf "stump") ["stump"] [])))))]
      [(= ttype "HoeDirt") (do
        (if (kid-bool tf "crop/dead")
          (setv c "dead plant")
          (do
            (setv c (kid-int tf "crop/indexOfHarvest"))
            (setv c (.get ITEM-NUMS c (.format "[indexOfHarvest {}]" c)))))
        (+= (get plots c) 1))])
    (+= (get terrain-features ttype) 1)))

(defn add-animals [l]
  (for [animal l]
    (setv species (kid-text animal "type"))
    (when (in " " species)
      (setv species (.join ", " (reversed (.split species " ")))))
    (setv mature? (>= (kid-int animal "age") (kid-int animal "ageWhenMature")))
    (setv name (if mature?
      species
      (+ species " (immature)")))
    (+= (get animals name) 1)))

; ------------------------------------------------------------
; * Parse the XML
; ------------------------------------------------------------

(with [[o (open (os.path.join SAVES-DIR FARMER-ID FARMER-ID))]]
  (setv tree (xml.etree.ElementTree.parse o)))

(for [ppath ["items/Item" "boots" "leftRing" "rightRing" "hat"]]
  (add-items (findall tree (+ "player/" ppath))))

(for [locname ["FarmHouse" "Farm" "FarmCave"]]
  (setv loc (find tree (.format "locations/GameLocation[@xsi:type='{}']" locname)))
  (add-items (findall loc "objects/item/value/Object"))
  (add-items (findall loc "fridge/items/Item"))
  (add-items (findall loc "buildings/Building/indoors/objects/item/value/Object"))
  (whenn (kid-int loc "piecesOfHay")
    (+= (get items (kwc ItemType :name "Hay" :category 0)) it))
  (add-terrain-features (findall loc "terrainFeatures/item/value/TerrainFeature"))
  (add-animals (findall loc "buildings/Building/indoors/animals/item/value/FarmAnimal"))
  (add-animals (findall loc "buildings/animals/item/value/FarmAnimal")))

; ------------------------------------------------------------
; * Output
; ------------------------------------------------------------

(defn report [header l]
  (print "\n---" header)
  (for [[name n] l]
    (setv n (.rjust (if (= n 1) "" (format n ",")) 9))
    (print n name)))

(report "ITEMS" (amap [it.name (get items it)]
  (kwc sorted (.keys items) :key (λ (, it.category it.name)))))
(report "TERRAIN" (sorted (.items terrain-features)))
(report "PLOTS" (sorted (.items plots)))
(report "PRODUCERS" (sorted (.items producers)))
(report "ANIMALS" (sorted (.items animals)))
