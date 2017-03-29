`casebase`: A Statistical Software Tool for Survival Analysis
=============================================================

<p>
This software is written in the open source software environment <a href="https://cran.r-project.org/">R</a>. It's main functionality is to fit smooth-in-time parametric hazard functions using case-base sampling <a href="http://sahirbhatnagar.com/casebase/references/">Hanley & Miettinen (2009)</a>.
</p>
<p>
This approach allows the explicit inclusion of the time variable into the model, which enables the user to fit a wide class of parametric hazard functions. For example, including time linearly recovers the Gompertz hazard, whereas including time logarithmically recovers the Weibull hazard; not including time at all corresponds to the exponential hazard.
</p>
<p>
The theoretical properties of this approach have been studied in <a href="http://sahirbhatnagar.com/casebase/references/">Saarela & Arjas (2015) and Saarela (2015)</a>.
</p>
<p>
The software is still in development mode.
</p>
<h2 id="installation">
Installation
</h2>
<p>
The software package is available on <a href="https://github.com/sahirbhatnagar/casebase">Github</a> and can be installed directly from within <code>R</code> using the following commands (note: you will need the <a href="https://CRAN.R-project.org/package=pacman"><code>pacman</code></a> package prior to installing the <code>casebase</code> package)
</p>
``` r
library(pacman)
pacman::p_install_gh('sahirbhatnagar/casebase')
```