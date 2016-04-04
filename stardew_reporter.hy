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
  0 "Oak Chair" 8 "Scarecrow" 9 "Lightning Rod" 10 "Bee House" 16 "Cheese Press" 16 "Wild Horseradish" 18 "Daffodil" 20 "Leek" 21 "Crystalarium" 22 "Dandelion" 24 "Parsnip" 25 "Seed Maker" 31 "Orange Office Stool" 38 "Flooring" 60 "Emerald" 62 "Aquamarine" 64 "Ruby" 66 "Amethyst" 68 "Topaz" 70 "Jade" 72 "Diamond" 74 "Prismatic Shard" 78 "Cave Carrot" 80 "Quartz" 82 "Fire Quartz" 84 "Frozen Tear" 86 "Earth Crystal" 88 "Coconut" 90 "Cactus Fruit" 92 "Sap" 93 "Torch" 94 "Singing Stone" 97 "Dwarf Scroll II" 97 "Wallpaper" 98 "Dwarf Scroll III" 104 "Heater" 105 "Tapper" 107 "Dinosaur Egg" 108 "Tub o' Flowers" 114 "Charcoal Kiln" 121 "Dwarvish Helm" 122 "Dwarf Gadget" 123 "Ancient Drum" 126 "Strange Doll" 128 "Pufferfish" 129 "Anchovy" 131 "Crystal Chair" 137 "Smallmouth Bass" 137 "Rarecrow" 139 "Salmon" 140 "Walleye" 142 "Carp" 148 "Eel" 152 "Seaweed" 153 "Green Algae" 157 "White Algae" 158 "Stonefish" 159 "Crimsonfish" 160 "Angler" 162 "Lava Eel" 163 "Legend" 165 "Scorpion Carp" 166 "Treasure Chest" 167 "Joja Cola" 168 "Trash" 169 "Driftwood" 170 "Broken Glasses" 171 "Broken CD" 172 "Soggy Newspaper" 174 "Large Egg" 176 "Egg" 178 "Hay" 184 "Milk" 186 "Large Milk" 188 "Green Bean" 190 "Cauliflower" 192 "Potato" 194 "Fried Egg" 196 "Salad" 198 "Baked Fish" 200 "Vegetable Medley" 203 "Strange Bun" 206 "Pizza" 207 "Bean Hotpot" 210 "Hashbrowns" 211 "Pancakes" 213 "Fish Taco" 216 "Bread" 219 "Trout Soup" 221 "Pink Cake" 223 "Cookie" 224 "Spaghetti" 226 "Spicy Eel" 227 "Sashimi" 229 "Tortilla" 235 "Autumn's Bounty" 242 "Dish O' The Sea" 245 "Sugar" 246 "Wheat Flour" 247 "Oil" 248 "Garlic" 250 "Kale" 254 "Melon" 256 "Tomato" 257 "Morel" 258 "Blueberry" 259 "Fiddlehead Fern" 260 "Hot Pepper" 262 "Wheat" 264 "Radish" 266 "Red Cabbage" 270 "Corn" 272 "Eggplant" 276 "Pumpkin" 278 "Bok Choy" 281 "Chanterelle" 282 "Cranberries" 283 "Holly" 284 "Beet" 287 "Bomb" 288 "Mega Bomb" 296 "Salmonberry" 297 "Grass Starter" 298 "Hardwood Fence" 300 "Amaranth" 301 "Grape Starter" 302 "Hops Starter" 304 "Hops" 305 "Void Egg" 306 "Mayonnaise" 307 "Duck Mayonnaise" 309 "Acorn" 310 "Maple Seed" 311 "Pine Cone" 322 "Wood Fence" 323 "Stone Fence" 325 "Gate" 328 "Wood Floor" 330 "Clay" 333 "Crystal Floor" 334 "Copper Bar" 335 "Iron Bar" 336 "Gold Bar" 337 "Iridium Bar" 338 "Refined Quartz" 340 "Poppy Honey" 340 "Fairy Rose Honey" 340 "Summer Spangle Honey" 340 "Wild Honey" 342 "Pickled Tomato" 342 "Pickled Parsnip" 344 "Ancient Fruit Jelly" 346 "Beer" 347 "Rare Seed" 348 "Cranberries Wine" 348 "Grape Wine" 348 "Cherry Wine" 348 "Blueberry Wine" 348 "Ancient Fruit Wine" 348 "Strawberry Wine" 348 "Pomegranate Wine" 349 "Energy Tonic" 350 "Parsnip Juice" 368 "Basic Fertilizer" 369 "Quality Fertilizer" 370 "Basic Retaining Soil" 372 "Clam" 373 "Golden Pumpkin" 376 "Poppy" 378 "Copper Ore" 380 "Iron Ore" 382 "Coal" 384 "Gold Ore" 386 "Iridium Ore" 388 "Wood" 390 "Stone" 392 "Nautilus Shell" 393 "Coral" 395 "Coffee" 396 "Spice Berry" 397 "Sea Urchin" 398 "Grape" 399 "Spring Onion" 400 "Strawberry" 401 "Straw Floor" 402 "Sweet Pea" 404 "Common Mushroom" 406 "Wild Plum" 408 "Hazelnut" 410 "Blackberry" 411 "Cobblestone Path" 412 "Winter Root" 414 "Crystal Fruit" 416 "Snow Yam" 418 "Crocus" 419 "Vinegar" 420 "Red Mushroom" 421 "Sunflower" 422 "Purple Mushroom" 423 "Rice" 424 "Cheese" 425 "Fairy Seeds" 426 "Goat Cheese" 427 "Tulip Bulb" 428 "Cloth" 429 "Jazz Seeds" 430 "Truffle" 431 "Sunflower Seeds" 432 "Truffle Oil" 436 "Goat Milk" 440 "Wool" 442 "Duck Egg" 444 "Duck Feather" 446 "Rabbit's Foot" 453 "Poppy Seeds" 454 "Ancient Fruit" 455 "Spangle Seeds" 458 "Bouquet" 463 "Drum Block" 464 "Flute Block" 465 "Speed-Gro" 472 "Parsnip Seeds" 473 "Bean Starter" 474 "Cauliflower Seeds" 475 "Potato Seeds" 476 "Garlic Seeds" 477 "Kale Seeds" 479 "Melon Seeds" 480 "Tomato Seeds" 481 "Blueberry Seeds" 482 "Pepper Seeds" 483 "Wheat Seeds" 484 "Radish Seeds" 485 "Red Cabbage Seeds" 486 "Starfruit Seeds" 487 "Corn Seeds" 488 "Eggplant Seeds" 490 "Pumpkin Seeds" 491 "Bok Choy Seeds" 492 "Yam Seeds" 493 "Cranberry Seeds" 494 "Beet Seeds" 495 "Spring Seeds" 496 "Summer Seeds" 497 "Fall Seeds" 499 "Ancient Seeds" 528 "Wizard Couch" 535 "Geode" 536 "Frozen Geode" 537 "Magma Geode" 538 "Alamite" 539 "Bixite" 540 "Baryte" 541 "Aerinite" 542 "Calcite" 543 "Dolomite" 544 "Esperite" 545 "Fluorapatite" 546 "Geminite" 547 "Helvite" 548 "Jamborite" 549 "Jagoite" 550 "Kyanite" 551 "Lunarite" 552 "Malachite" 553 "Neptunite" 554 "Lemon Stone" 555 "Nekoite" 556 "Orpiment" 557 "Petrified Slime" 558 "Thunder Egg" 559 "Pyrite" 560 "Ocean Stone" 561 "Ghost Crystal" 562 "Tigerseye" 563 "Jasper" 564 "Opal" 565 "Fire Opal" 566 "Celestine" 567 "Marble" 568 "Sandstone" 569 "Granite" 570 "Basalt" 571 "Limestone" 572 "Soapstone" 573 "Hematite" 574 "Mudstone" 575 "Obsidian" 576 "Slate" 577 "Fairy Stone" 578 "Star Shards" 587 "Amphibian Fossil" 591 "Tulip" 593 "Summer Spangle" 597 "Blue Jazz" 599 "Sprinkler" 609 "Radish Salad" 613 "Apple" 621 "Quality Sprinkler" 629 "Apricot Sapling" 630 "Orange Sapling" 631 "Peach Sapling" 632 "Pomegranate Sapling" 634 "Apricot" 637 "Pomegranate" 638 "Cherry" 645 "Iridium Sprinkler" 648 "Coleslaw" 680 "Green Slime Egg" 682 "Mutant Carp" 684 "Bug Meat" 685 "Bait" 686 "Spinner" 687 "Dressed Spinner" 691 "Barbed Hook" 699 "Tiger Trout" 700 "Bullhead" 702 "Chub" 705 "Albacore" 709 "Hardwood" 710 "Crab Pot" 715 "Lobster" 717 "Crab" 718 "Cockle" 719 "Mussel" 720 "Shrimp" 723 "Oyster" 724 "Coffee Table" 724 "Maple Syrup" 725 "Oak Resin" 726 "Pine Tar" 730 "Lobster Bisque" 734 "Woodskip" 745 "Strawberry Seeds" 749 "Omni Geode" 766 "Slime" 767 "Bat Wing" 768 "Solar Essence" 769 "Void Essence" 770 "Mixed Seeds" 771 "Fiber" 775 "Glacierfish" 787 "Battery Pack" 1298 "Standing Geode" 1299 "Obsidian Vase" 1302 "Sloth Skeleton M" 1304 "Skeleton" 1305 "Chicken Statue" 1306 "Leah's Sculpture" 1307 "Dried Sunflowers" 1364 "Decorative Bowl" 1376 "House Plant" 1402 "Calendar" 1466 "Budget TV" 1541 "'A Night On Eco-Hill'" 1545 "'Burnt Offering'" 1554 "'Jade Hills'" 1602 "'Little Tree'" 1605 "Little Photos" 1669 "Lg. Futan Bear" 1671 "Bear Statue"})
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
