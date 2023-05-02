# Real-Bees
<a name="readme-top"></a>

[![FarmingSimulator-22](https://img.shields.io/badge/FarmingSimulator-22-blue?style=plastic)](https://www.farming-simulator.com/)
[![GitHub issues](https://img.shields.io/github/issues/Peppie84/FS22_BeesRevamp?style=plastic)](https://github.com/Peppie84/FS22_BeesRevamp/issues)

<br />
<div align="center">

<img src="documents/mod_icon.jpg" style="width: 128px;">

<h3 align="center"><u>FS22_BeesRevamp</u></h3>

<p align="center">
    TBD
</p>

</div>

## Features
 - Aktuelle Honigproduktion:
	- lvl1 = (( litersHoneyPerDay="5") / 24) * kehrwert von TageProPeriod
 	- lvl5 = ((litersHoneyPerDay="495") / 24 ) * kehrwert von TageProPeriod
 - Honigproduktion nur zwischen März und Okt
 ```
 Mär=1
 Apr=2
 Mai=3
 Jun=4
 Jul=5
 Aug=6
 Sep=7
 Okt=8
 Nov=9
 Dez=10
 Jan=11
 Feb=12
 ```
 - Produktionsleistung über das Jahr anpassen:
 ```
Mär=0.75
Apr=1.25
Mai=1.50
Jun=2.00
Jul=1.50
Aug=1.25
Sep=0.75
Okt=0.50
Nov=-0.5
Dez=-0.5
Jan=-0.5
Feb=-0.5
 ```
 - Bienen fliegen ab 10 Grad zwischen März und Okt
 - Bienen können sterben. Effekt: es kommt kein Honig mehr + Infohud die Info ausgeben
 	- Wenn die Bienen gestorben sind, dann muss ein neuer Kasten gekauft werden
 - Zwischen März und Juni muss man einmal pro Period an den Kasten und einen Aktionsknopf drücken = Schwarmkontrolle
 	- Macht man das nicht, wird der BeeGrothFactor halbiert für das aktuelle Jahr. Im neuen Jahr wird dieser Wert wieder zurückgesetzt.
 - Schwarm darstellen? Den man wie ein EasterEgg aufsammeln kann?
 - Honig muss man auch einkaufen können, damit sie im Winter nicht verhungern. Honig muss auf den PalettSpawner abgelegt werden
	- Hier sollte man nur Sirup/Melasse oder Sugar-Water kaufen können
 - Im Okt muss mit Oxalsäure behandelt werden, sonst sterben die Bienen im März
 - Name der Oxsalsäure: Oxu SIM 22
 - PricePerLiter kann über FruiteTypeManager geändert werden, nach dem Load Befehl!
 	- 13.15€ pro Liter
 - Reichweite erhöhen, 150m sind zu wenig!
 - Im FieldInfo Hud anzeigen wie viel Hives influenced sind und wie viel %Bonus es gibt
	- Muss irgendwie gecached werden, da es sonst zu oft aufgerufen wird!
	- oder bei nicht influenced fruits direkt ein defualt raushauen
	- eventuell wenn man auf dem Feld läuft, alle 10pixel oder so
 - An den Fruchtkalender könnte man neben dem Fruchtnamen eine kleine Biene einblenden, damit man weiß welche Frucht von Bienen profitiert.
 - Hilfe-system für Real-Bees mod einplanen


 ## Aktuelle Umsetzung:
 - [x] Variable Produktion an Honig je nach Monat
 - [x] Im Winter wird der Verbrauch negativ
 - [ ] Wenn der Honig auf 0 fällt im Winter müssen die Bienen sterben

---

 ## Current Beehivesystem
 The beehivesystem class is the main controller for all beehives. It controls the flying bee animation (fx) and also the honey production.

 ### Honey production
 | |Honey per Period|Honey per Hour|Placeable Price|
|---|:---:|:---:|:---:|
| BeeHive LVL1 | 5 | 0.2083¯ | 1100 |
| BeeHive LVL2 | 20 | 0.8333¯ | 4400 |
| BeeHive LVL3 | 25 | 1.0416¯ | 6600 |
| BeeHive LVL4 | 150 | 6.25 | 12500 |
| BeeHive LVL5 | 495 | 20.625 | 19000 |

### Beehive behavior

| |Flying bees fx|Honey production (every hour)|
|---|:---:|:---:|
| SunIsOn | x | x (HoneyPerHour * reciprocal(DaysPerPeriod)) |
| IsRaining | - | x (HoneyPerHour * reciprocal(DaysPerPeriod)) |
| IsWinterPeriod | - | - |

---

 ## New Behivesystem
 ### Honey production
It's hard to re-calculate a new value for real bees. In real, a bee hive with two brood frames + one honey frame can produce 50kg per year - in average, depending on the weather. But a two frame brood hive also needs nearly 15kg food for winter (Nov-Feb/Mar), mostly feeded with sugar water or something similar.

Below you can see some "real" numbers for the placables and situations.
Based on the average of 50kg per year and 8 month of production + 2 days per month as season settings:

`50kg/year / 8 = 6.25 kg/month / reciprocal(2) = 3.125 kg/day / 24 = 0.13020833¯ kg/hour`

For a single frame hive, the defined `Beehive groth factor` simulates the growing/shrinking of a hive. So, a single frame hive can produce `0.26041666 kg/hour` instead of its `0.13020833¯ kg/hour` on month **Jun**.

 | Season |Honey per Period|Honey per Hour|Placeable Price|
|---|:---:|:---:|:---:|
| BeeHive LVL1 | 6.25 | 0.260416¯ | 200 |
| BeeHive LVL2 | 11.25 | 0.46875 | 400 |
| BeeHive LVL3 | 12.25 | 0.5104166¯ | 450 |
| BeeHive LVL4 | 73.0 | 3.04166¯ | 2500 |
| BeeHive LVL5 | 240.9 | 10.0375 | 8500 |

### Beehive growth factor

 | | Period |Factor|
|---|---|:---:|
| Spring | Mar | 0.75 |
| Spring | Apr | 1.25 |
| Spring | May | 1.50 |
| Summer | Jun | 2.00 |
| Summer | Jul | 1.50 |
| Summer | Aug | 1.25 |
| Fall | Sep | 0.75 |
| Fall | Oct | 0.50 |
| Fall | Nov | -.50 |
| Winter | Dec | -.50 |
| Winter | Jan | -.50 |
| Winter | Feb | -.50 |

### Beehive behavior

| |Flying bees fx|Honey production (every hour)|
|---|:---:|:---:|
| SunIsOn | x | x (HoneyPerHour * reciprocal(DaysPerPeriod)) * BeehiveGrowthFactor |
| Is under 10°C | - | x (HoneyPerHour * reciprocal(DaysPerPeriod)) * BeehiveGrowthFactor |
| IsRaining | - | x (HoneyPerHour * reciprocal(DaysPerPeriod)) * BeehiveGrowthFactor |
| IsWinterPeriod | - | x (HoneyPerHour * reciprocal(DaysPerPeriod)) * BeehiveGrowthFactor |




# Helps
- global auf das Beehive system zugreifen:
```
g_currentMission.beehiveSystem
```


# Devs
## Spezialisierungen

### PlaceableBeehiveExtended
Registrierte Methoden:
 - getBeehiveHiveCount

### BeeCare
In der BeeCare Spezialisierung geht um das Wohl der Bienen. Hier wird gesteuert ob Schwarmkontrolle gemacht werden muss, die Aktion wird hier gesteuert, die Winterbehandlung, die Anzahl der Binen pro Volk (Hive).
Registrierte Methoden:
 - getBeehiveStatus
 - getBeePopulation



## Manager

### BeehiveSystemExtended

# Copyright
Copyright (c) 2023 [Dennis Schmitt](https://github.com/peppie23).
All rights reserved.

<p align="right">(<a href="#readme-top">back to top</a>)</p>