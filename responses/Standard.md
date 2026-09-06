# PS1 Standard-Track Discussion Questions

Edit this file in VS Code. Replace each `TODO: Write your response here.` line with your answer, keeping the surrounding HTML answer markers. Explain your reasoning and include the requested values, using tables where useful. Save this file before rerunning the checker.

Run `check_submission.jl` as described in the README to generate results from your saved code. The financial results appear in the terminal after the test report. Report rates as percentages and valuation prices in USD per USD 100 par.

## 1. Prices and rate conventions

Report the computed six-month bill price and the seven-year note price. The bill is quoted with a nominal annual yield $y$ compounded $n=2$ times per year. Its equivalent continuously compounded rate is $g_y = n\log(1+y/n)$. Report both $y$ and $g_y$ as percentages. Explain why $g_y$ and $y$ differ even though $(1+y/n)^{nT} = e^{g_yT}$, so that both give the same accumulation factor and bill price.

<!-- answer-1:start -->
TODO: Write your response here.
<!-- answer-1:end -->

## 2. Interest-rate shock

The note's yield rises by $\Delta y=0.005$ (50 basis points), from 4.60% to 5.10%. Compare the note price recalculated by the package at the higher yield with the **new note price estimated using duration and convexity**:

$$
V_{\mathrm{est}} = V_B(y)\left[1-D_{\mathrm{mod}}\Delta y+\frac{1}{2}K(\Delta y)^2\right].
$$

This is L2b's second-order Taylor approximation. It uses the original price $V_B(y)$, modified duration $D_{\mathrm{mod}}$, and convexity $K$, all evaluated before the yield change. The checker calculates the estimated new price for you. Report both prices and the modified duration and convexity shown by the checker. Explain why the note price falls when the yield rises and relate this to the sign of $dV_B/dy$.

<!-- answer-2:start -->
TODO: Write your response here.
<!-- answer-2:end -->

## 3. Approximation quality

Report $V_B(y+\Delta y)$ minus the estimated new note price from Question 2, in USD per USD 100 par. Use the checker's **Package price minus estimated note price** result, which is calculated before rounding. The sign shows which way the estimate misses. You may round reported values to four decimal places. Explain the difference between the two methods, referring to the Taylor expansion in $\Delta y$ that produces the repricing formula.

<!-- answer-3:start -->
TODO: Write your response here.
<!-- answer-3:end -->
