---
author: Jan
categories:
- Technology
date: '2012-03-28'
guid: http://beta.janw.io/dauerladen-schadet-nicht-wie-die-ladeelektronik-unter-ios-funktioniert/
id: 65
slug: dauerladen-schadet-nicht-wie-die-ladeelektronik-unter-ios-funktioniert/
tags:
- apple
- batteries
- li-ion
title: Dauerladen schadet nicht – Wie die Ladeelektronik unter iOS funktioniert

---

Allzu oft habe ich schon Diskussionen darüber geführt, ob man Mac, iPod, iPhone etc. besser möglichst lange am Ladekabel hält oder es immer vollständig lädt und dann gleich wieder entlädt. Was die Geräte mit iOS betrifft gibt es dort nun Neuigkeiten, die mein eigenes Verhalten bestätigen und untermauern.

Sobald ich mich zu Hause aufhalte landen MacBook und iPhone nämlich am Strom. Nur selten verwende ich auch daheim den Akku und lasse ihn stattdessen immer voll geladen. Aus technischer/physikalischer Sicht schadet dies jedoch dem verbauten Lithium-Ionen-Akku. [Zum Umgang mit Li-Ion-Akkus schreibt die Wikipedia](http://de.wikipedia.org/wiki/Lithium-Ionen-Akkumulator#Hinweise_zum_Umgang_mit_Li-Ionen-Akkus):

<!--more-->

> Der Akku altert schneller, je höher seine Zellenspannung ist, daher ist es zu vermeiden, einen Li-Ion-Akku ständig 100 Prozent geladen zu halten. Der Ladezustand soll 55–75 % betragen, kühle Lagerung ist vorteilhaft.

Das wusste man wohl auch bei Apple, denn schon seit Jahren sei laut Michael Tchao, Apple Vice-President, die Ladeelektronik der iOS-Devices so gestaltet, dass diese ohne Weiteres über lange Zeit am Ladekabel bleiben können. [Ina Fried](http://allthingsd.com/author/ina/) von [AllThingsD](http://allthingsd.com/) hat Tchao speziell bezüglich des neuen iPad interviewt, bei dem zum ersten Mal Licht auf Apples Handhabe der Akkuladung fiel. So setze [das iPad auch bei einem angezeigten Ladezustand von 100% die Ladung fort](http://www.ilounge.com/index.php/news/comments/third-gen-ipad-charges-past-100-raising-meter-battery-questions/) (erkennbar am Batteriesymbol mit Blitz darin), was vielfach zu Verwirrung führte. Tchao räumt nun mit den Gerüchten über schadhafte Akkus und im gleichen Atemzug auch mit Mythen über die richtige Ladung der Akkus von iPhone, iPod und Co. auf. [Fried schreibt dazu](http://allthingsd.com/20120327/apple-ipad-battery-nothing-to-get-charged-up-about/):

> So here’s how things work: Apple does, in fact, display the iPad (and iPhone and iPod Touch) as 100 percent charged just before a device reaches a completely charged state. At that point, it will continue charging to 100 percent, then discharge a bit and charge back up to 100 percent, repeating that process until the device is unplugged.

Die _angezeigten_ 100% sind also nicht wirklich ein direkter Rückschluss auf die volle Akkuladung. Stattdessen zeigt die Software schon einige Prozent vorher an, 100% erreicht zu haben, lädt aber noch etwas weiter, um die „echten 100%“ zu erreichen und sofort wieder mit der Entladung zu beginnen. Diese Entladung wird dann ausgeführt bis wieder die „falschen 100%“ erreicht werden und die Ladung beginnt erneut. Dieses „Hin und Her“ der Ladung sorgt dafür, dass der Akku tatsächlich nur für sehr kurze Zeit überhaupt die „echten 100%“ erreicht und danach sofort wieder entladen wird. Dies schont die Zellen und das iDevice kann im Grunde ewig am Strom hängen.

Leider kommt im Interview nicht zur Sprache, ob diese Ladetechnik auch schon bei MacBooks zum Einsatz kommt. Insofern muss ich mich auch weiterhin darauf verlassen, dass mein Verhalten dem Akku nicht zu sehr schadet. Für iPhone, iPad und iPod touch herrscht nun allerdings Gewissheit: Sie können unbegrenzt am Kabel hängen – es schadet nicht.