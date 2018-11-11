---
title: "Hübsche Gendergaps mit LaTeX erzeugen"
date: "2018-10-28T21:01:38+01:00"
slug: huebschen-gendergap-haben-sie-da
---


Kürzlich habe ich festgestellt, wie furchtbar ein Gendergap in LaTeX aussieht, wenn es auf üblichem Wege (mittels Unterstrich `\textunderscore`) erzeugt wird. Besonders stört mich daran, dass der Unterstrich in der Schriftart Computer Modern (dem LaTeX-Default) ungewöhnlich lang ist und etwas *zu* tief steht. Hinzu kommt, dass in der deutschen Silbentrennung vor einem Unterstrich natürlich kein Wortumbruch vorgesehen ist, auch wenn dies bei langen gegenderten durchaus sinnvoll sein kann. Besonders die "_innen"-Endung ist lang genug, um den sauberen Blocksatz für LaTeX unmöglich zu machen. Das äußert sich dann durch über den Block hinaushängenden Wörter.

Auf meiner Suche nach einer brauchbaren Lösung bin ich direkt auf [eine StackOverflow-Diskussion zum Thema](https://tex.stackexchange.com/q/128814) gestoßen, doch die dort *markierte* Lösung halte ich nicht für die *beste* Lösung. "The real TIL is always in the comments": In der [zweiten Antwort wird dort](https://tex.stackexchange.com/a/233274) eine Skalierung des Unterstrichs mittels `\adjustbox` vorgeschlagen. Auch diese Lösung ist nicht ganz perfekt, da die vertikale Positionsanpassung nicht von der Schriftgröße abhängig ist und dementsprechend bei nicht-`\normalsize` Größen zunehmend "abdriftet". Das hab ich korrigiert und noch ein wenig das Kerning optimiert.

Herausgekommen ist das folgende Minimalbeispiel, inklusive vom `\gendergap` abgeleiteten Makros, für die häufigsten Endungen:

```latex
%!TEX program=xelatex
\documentclass[varwidth=9cm, border=5mm]{standalone}

\usepackage[ngerman]{babel}
\usepackage{ngerman}
\usepackage{adjustbox}

\newcommand{\gendergap}{%
  \kern-.6pt%
  \adjustbox{scale={0.5}{1},raise={0.25ex}{\height}}{\textunderscore}%
}

\newcommand\gginnen{"-\gendergap\relax{}in\-nen }
\newcommand\ggin{"-\gendergap\relax{}in }
\newcommand\gge{"-\gendergap\relax{}e }

\begin{document}
Altforscher\textunderscore innen\\

Bricht um: Forscher\gginnen Forscher\n Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen Forscher\gginnen\\

{\Huge Neuforscher\gginnen}\\
{\huge Neuforscher\gginnen}\\
{\LARGE Neuforscher\gginnen}\\
{\Large Neuforscher\gginnen}\\
{\large Neuforscher\gginnen}\\
{\normalsize Neuforscher\gginnen} (normal)\\
{\small Neuforscher\gginnen}\\
{\footnotesize Neuforscher\gginnen}\\
{\scriptsize Neuforscher\gginnen}\\
{\tiny Neuforscher\gginnen}
\end{document}
```


Das kompiliert zu folgendem Ergebnis, das aus meiner Sicht deutlich ansprechender aussieht, den Gendergap an eine vernünftige Position hebt und dank `"-` Makro aus dem guten alten `ngerman`-Paket auch die optionale Silbentrennung vor dem Gap hinzufügt (die ursprünglichen Trennungsmöglichkeiten des zugrunde liegenden Worts bleiben erhalten).

{{< fig src="/media/genderhyph.png" title="Beispiel des ästhetisch ansprechenden Gendergap im Vergleich zum gewöhnlichen Unterstrich (oben)" >}}


Zwei Bemerkungen zum Schluss:

* Innerhalb von `\caption`-Umgebungen (vermutlich noch weiteren) muss das `\gendergap` Makro (und die `\gg…`-Derivate) geschützt werden. Dazu wird direkt davor ein `\protect` eingesetzt:<br />`ein\protect\gendergap e` oder `Forscher\protect\innen`.
* Falls jemand auf die Idee kommt, die `gg`-Präfixe von den Makros wegzulassen: die naheliegende Bennenung von `\in` wird nicht funktionieren, weil die Variable innerhalb von TeX schon verwendet wird (wenngleich nur innerhalb von Matheumgebungen, für das &isin;-Symbol)

Happy gender diversity! 🏳️‍🌈👋
