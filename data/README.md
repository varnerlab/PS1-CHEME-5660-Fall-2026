# PS1 Data

## Standard track

`standard-terms.csv` contains the classroom bill, seven-year note, and yield-shock terms used by the public tests. The rates are decimal annual rates. The examples are controlled classroom instruments and are not represented as current tradable quotes.

## Advanced track

`advanced-terms.csv` contains the known seven-period liability and the model-implied price per dollar of maturity value for an exact-maturity principal STRIP.

`cir-rate-scenarios.csv` contains 40 frozen paths with seven one-period observations per path:

| Column | Meaning |
|:--|:--|
| `scenario_id` | Scenario row identifier |
| `period` | One-year roll period, from 1 through 7 |
| `short_rate` | CIR instantaneous short-rate state at the start of the period |
| `one_period_zero_price` | Model price paid for one dollar at the end of the period |
| `growth_factor` | Maturity wealth per dollar invested, equal to the inverse zero price |
| `bill_discount_rate` | Equivalent synthetic 52-week bank-discount quote using 364 days |

`cir-parameters.csv` records the seed, parameters, and numerical settings used to produce the frozen table. The teaching team used the same CIR parameters for scenario generation and zero-coupon pricing. This suppresses the distinction between physical and risk-neutral dynamics as an explicit pedagogical simplification.

Students do not run or reproduce the CIR simulation. The Advanced calculations use the supplied zero prices and growth factors.

