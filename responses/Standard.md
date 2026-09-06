# PS1 Standard-Track Discussion Questions

Replace each placeholder below, keeping the surrounding HTML answer markers. Answer each question in a short paragraph, using a compact table for the reported values where useful. Report rates as percentages and monetary values in USD with appropriate precision. `check_submission.jl` displays the computed values you need.

## 1. Prices and rate conventions

Report the computed six-month bill price $V_B$ and the seven-year note price. The bill is quoted with a nominal annual yield $y$ compounded $n=2$ times per year. Its equivalent continuously compounded rate is $g_y = n\log(1+y/n)$. Report both $y$ and $g_y$ as percentages. Explain why $g_y$ and $y$ are different numbers even though $(1+y/n)^{nT} = e^{g_yT}$, so both give the same accumulation factor and the same bill price.

<!-- answer-1:start -->
TODO: Write your response here.
<!-- answer-1:end -->

## 2. Interest-rate shock

The note's yield rises by $\Delta y = 0.0050$ (50 basis points), from 4.60% to 5.10%. Report the exact repriced note value $V_B(y+\Delta y)$ and the estimate from the second-order repricing formula $\Delta V_B/V_B \approx -D_{\mathrm{mod}}\Delta y + \tfrac{1}{2}K(\Delta y)^2$, together with the modified duration $D_{\mathrm{mod}}$ and convexity $K$ you used. Explain the sign of the price change in terms of $dV_B/dy$.

<!-- answer-2:start -->
TODO: Write your response here.
<!-- answer-2:end -->

## 3. Approximation quality

Report $V_B(y+\Delta y)$ minus the duration-convexity estimate, in USD per USD 100 par. The sign shows which way the estimate misses. Show enough precision to make the small difference visible, for example four decimal places or scientific notation. Explain why the estimate is close but not exact, referring to the Taylor expansion in $\Delta y$ that produces the repricing formula.

<!-- answer-3:start -->
TODO: Write your response here.
<!-- answer-3:end -->
