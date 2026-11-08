<div align="center">
  <img src="assets/banner.png" alt="QuantTech4D — Technical analysis for Delphi and Free Pascal - one call per indicator." width="100%" />
</div>

# QuantTech4D

**Technical analysis for Delphi and Free Pascal - one call per indicator.**

QuantTech4D is a native Pascal library that brings the complete function list of
[TA-Lib](https://github.com/TA-Lib/ta-lib) to Delphi and Free Pascal / Lazarus: more than 200 indicators,
all 61 candlestick patterns, Hilbert Transform cycle indicators, math operators and rolling-window
helpers - with a deliberately small and easy API.

```pascal
uses QuantTech4D.Types, QuantTech4D.Overlap, QuantTech4D.Momentum;

var
  Fast, Slow, Strength: TQDoubleArray;
  M: TQMACD;
begin
  Fast     := EMA(Close, 12);
  Slow     := EMA(Close, 26);
  Strength := RSI(Close);          // TA-Lib defaults: period 14
  M        := MACD(Close);         // 12 / 26 / 9, returns MACD, Signal and Hist
end;
```

Author: **Shaahin Ashayeri** - https://github.com/DelphiMan68 - License: **BSD-3-Clause**

---

## Table of contents

1. [Highlights](#highlights)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Quick start](#quick-start)
5. [Core concepts](#core-concepts)
6. [Cookbook](#cookbook)
7. [Candlestick patterns](#candlestick-patterns)
8. [Function reference](#function-reference)
9. [TA-Lib name mapping](#ta-lib-name-mapping)
10. [Algorithm notes](#algorithm-notes)
11. [Examples](#examples)
12. [Project layout](#project-layout)
13. [License and credits](#license-and-credits)

---

## Highlights

* **Complete coverage** of TA-Lib's function list: overlap studies, momentum, volume, volatility, price
  transforms, statistics, cycle (Hilbert Transform), math transforms and operators, and all 61 candlestick
  patterns.
* **One call per indicator.** Parameters default to the TA-Lib defaults, so `RSI(Close)` just works.
* **Output aligned with input.** Every result has the same length as the input series; the warm-up part is
  `NaN` (candlestick functions return `0`). No begin-index bookkeeping.
* **Typed multi-output results.** `TQMACD`, `TQBBands`, `TQStoch`, `TQAroon`, `TQMinMax`, `TQPair`, ...
* **NaN-aware chaining.** Indicators can be fed with the output of other indicators
  (`EMA(RSI(Close), 5)`): leading `NaN` values are skipped automatically.
* **Configurable candlesticks.** The TA-Lib "candle settings" model (body/shadow averaging periods and
  factors) is exposed through `QTCandleSettings`.
* **One codebase, two compilers.** Delphi (XE and later) and Free Pascal 3.x in Delphi mode, no third-party
  dependencies, no DLLs, no external runtime.
* **Safe by default.** Invalid parameters raise `EQuantTechError` with a clear message; division by zero and
  out-of-domain math produce `NaN` or the documented TA-Lib fallback instead of floating point exceptions.

## Requirements

| | |
|---|---|
| Delphi | XE or later (dynamic arrays, records with methods, default parameters) |
| Free Pascal | 3.0 or later, compiled in Delphi mode (`{$MODE DELPHI}` is set automatically by `QuantTech4D.inc`) |
| Platforms | Any target supported by the compiler (Windows, Linux, macOS, Android, iOS) |
| Dependencies | None (only `SysUtils`, `Math`, `Classes`) |

## Installation

**Delphi**

1. Copy the `src` folder next to your project (or anywhere you like).
2. Add the folder to *Project > Options > Building > Delphi Compiler > Search path*.
3. Add the units you need to your `uses` clause.

Alternatively reference the units directly in the `.dpr`, like the bundled examples do:

```pascal
uses
  QuantTech4D.Types   in '..\..\src\QuantTech4D.Types.pas',
  QuantTech4D.Core    in '..\..\src\QuantTech4D.Core.pas',
  QuantTech4D.Overlap in '..\..\src\QuantTech4D.Overlap.pas';
```

**Free Pascal / Lazarus**

```
fpc -Fu/path/to/QuantTech4D/src MyProgram.pas
```

In Lazarus add the `src` folder under *Project > Project Options > Compiler Options > Paths > Other unit files*.

Every unit includes `QuantTech4D.inc`, which switches Free Pascal to Delphi mode, enables long strings and
advanced records, and turns range/overflow checking off for the hot loops.

## Quick start

```pascal
program Demo;
{$APPTYPE CONSOLE}
uses
  SysUtils,
  QuantTech4D.Types, QuantTech4D.Overlap, QuantTech4D.Momentum, QuantTech4D.Data;

var
  D: TQOHLCV;
  S20, R14: TQDoubleArray;
begin
  D   := GenerateSampleOHLCV(200);        // or LoadOHLCVFromCSV('prices.csv')
  S20 := SMA(D.Close, 20);
  R14 := RSI(D.Close);
  WriteLn('Last SMA(20): ', QTFmt(S20[High(S20)], 2));
  WriteLn('Last RSI(14): ', QTFmt(R14[High(R14)], 2));
end.
```

## Core concepts

### Data types

| Type | Description |
|---|---|
| `TQDoubleArray` | `array of Double`. Index 0 is the **oldest** bar. Every indicator input and output uses it. |
| `TQIntArray` | `array of Integer`. Used by candlestick patterns and index outputs. |
| `TQOHLCV` | Record with parallel arrays `Open`, `High`, `Low`, `Close`, `Volume`, plus `Count` and `Resize(N)`. |
| `TQMAType` | `maSMA, maEMA, maWMA, maDEMA, maTEMA, maTRIMA, maKAMA, maMAMA, maT3` (same order as TA-Lib). |
| `TQMACD` | `MACD`, `Signal`, `Hist` arrays. |
| `TQBBands` | `Upper`, `Middle`, `Lower` arrays (also used by Keltner, Donchian and Acceleration Bands). |
| `TQStoch` | `K`, `D` arrays. |
| `TQAroon` | `Down`, `Up` arrays. |
| `TQMinMax` | `Lowest`, `Highest` arrays. |
| `TQMAMA` | `Mama`, `Fama` arrays. |
| `TQPhasor` | `InPhase`, `Quadrature` arrays. |
| `TQHTSine` | `Sine`, `LeadSine` arrays. |
| `TQPair` | `First`, `Second` arrays - the meaning of each field is documented per function. |
| `TQKDJ` | `K`, `D`, `J` arrays. |
| `TQIchimoku` | `Tenkan`, `Kijun`, `SenkouA`, `SenkouB`, `Chikou` arrays. |

### Warm-up values and lookback

An indicator needs a number of bars before its first value (its *lookback*, for example `Period - 1` for a
simple moving average). The result array always has the same length as the input; the lookback part is `NaN`.

```pascal
S := SMA(Close, 20);
WriteLn(QTLookback(S));      // 19  -> the first valid value is S[19]
```

Use `IsNaN` (unit `Math`) to test individual values, and `QTFmt(X, Decimals)` to print them (`NaN` becomes `n/a`).

### Chaining indicators

Leading `NaN` values in an input are skipped, so indicators can be stacked:

```pascal
Smoothed := EMA(RSI(Close, 14), 5);        // EMA of RSI
Trix     := ROC(EMA(EMA(EMA(Close, 9), 9), 9), 1);
```

`NaN` is only supported at the **start** of a series; a `NaN` in the middle of the data propagates through the
calculation.

### Error handling

All validation errors raise `EQuantTechError` (a descendant of `Exception`): invalid periods, mismatched array
lengths, out-of-range limits.

```pascal
try
  R := RSI(Close, 1);                      // period must be >= 2
except
  on E: EQuantTechError do
    WriteLn(E.Message);                    // RSI: period must be >= 2 (got 1)
end;
```

### Naming conventions

* Indicators keep their TA-Lib names in upper case (`SMA`, `MACD`, `CDLHAMMER`, `HT_SINE`).
* TA-Lib names that clash with Pascal or RTL identifiers use a descriptive prefix/suffix
  (`RollingMax`, `VecAdd`, `StdDevRoll`, ...). See the [mapping table](#ta-lib-name-mapping).
* Helper routines are prefixed with `QT` (`QTNaNSeries`, `QTFirstValid`, `QTLookback`, ...).

## Cookbook

### Moving averages of any type

```pascal
uses QuantTech4D.Types, QuantTech4D.Overlap;

Fast := MA(Close, 10, maEMA);
Slow := MA(Close, 30, maKAMA);
Hull := HMA(Close, 21);
Zl   := ZLEMA(Close, 20);
V    := VWMA(Close, Volume, 20);
```

### Bollinger Bands and %B

```pascal
var B: TQBBands;
B := BBANDS(Close, 20, 2.0, 2.0, maSMA);
// B.Upper[i], B.Middle[i], B.Lower[i]
PctB  := PERCENTB(Close, 20, 2.0);       // QuantTech4D.Extended
Width := BBW(Close, 20, 2.0);
```

### MACD, stochastic and ADX

```pascal
var M: TQMACD; S: TQStoch;
M := MACD(Close, 12, 26, 9);
S := STOCH(High, Low, Close, 5, 3, maSMA, 3, maSMA);
Adx := ADX(High, Low, Close, 14);
PlusDI  := PLUS_DI(High, Low, Close, 14);
MinusDI := MINUS_DI(High, Low, Close, 14);
```

### Volatility and volume

```pascal
Atr  := ATR(High, Low, Close, 14);
Natr := NATR(High, Low, Close, 14);
Obv  := OBV(Close, Volume);
Mfi  := MFI(High, Low, Close, Volume, 14);
Cmf  := CMF(High, Low, Close, Volume, 20);
```

### Reading real data

```pascal
uses QuantTech4D.Types, QuantTech4D.Data;

D := LoadOHLCVFromCSV('EURUSD_H1.csv');   // [Date,]Open,High,Low,Close,Volume - oldest row first
WriteLn(D.Count, ' bars');
```

### Building the series yourself

```pascal
D.Resize(Length(Candles));
for i := 0 to High(Candles) do
begin
  D.Open[i]   := Candles[i].Open;
  D.High[i]   := Candles[i].High;
  D.Low[i]    := Candles[i].Low;
  D.Close[i]  := Candles[i].Close;
  D.Volume[i] := Candles[i].Volume;
end;
```

### Cycle indicators

```pascal
uses QuantTech4D.Cycle;

Sine   := HT_SINE(Close);                 // Sine.Sine, Sine.LeadSine
Period := HT_DCPERIOD(Close);
Mode   := HT_TRENDMODE(Close);            // TQIntArray: 1 = trend, 0 = cycle
Ma     := MAMA(Close, 0.5, 0.05);         // Ma.Mama, Ma.Fama
```

### Trend following and channels

```pascal
uses QuantTech4D.Extended;

ST  := SUPERTREND(High, Low, Close, 10, 3.0);   // ST.First = line, ST.Second = direction (1 / -1)
Ich := ICHIMOKU(High, Low, Close);              // Tenkan, Kijun, SenkouA, SenkouB, Chikou
Kc  := KC(High, Low, Close, 20, 2.0, 10);
Dc  := DONCHIAN(High, Low, 20);
Zz  := ZIGZAG(High, Low, 5.0);                  // pivot prices, NaN elsewhere
```

### A simple crossover strategy

```pascal
Fast := SMA(Close, 10);
Slow := SMA(Close, 30);
for i := 31 to High(Close) do
  if (Fast[i - 1] <= Slow[i - 1]) and (Fast[i] > Slow[i]) then
    WriteLn('Buy signal at bar ', i)
  else if (Fast[i - 1] >= Slow[i - 1]) and (Fast[i] < Slow[i]) then
    WriteLn('Sell signal at bar ', i);
```

### Math helpers

```pascal
uses QuantTech4D.MathOps;

Diff  := VecSub(High, Low);
Roots := VecSqrt(Close);
Hi20  := RollingMax(High, 20);
Idx   := RollingMaxIndex(High, 20);       // TQIntArray of absolute indexes
Med   := RollingMedian(Close, 15);
Cum   := CumSum(Volume);
```

## Candlestick patterns

All 61 TA-Lib patterns live in `QuantTech4D.Patterns` and take a `TQOHLCV` record:

```pascal
uses QuantTech4D.Types, QuantTech4D.Patterns;

Hammer  := CDLHAMMER(D);
Engulf  := CDLENGULFING(D);
Morning := CDLMORNINGSTAR(D, 0.3);        // optional penetration factor
```

**Result values** (`TQIntArray`, same length as the data): `100` = bullish signal, `-100` = bearish signal,
`0` = no pattern (or warm-up). `CDLHIKKAKE` and `CDLHIKKAKEMOD` additionally return `+-200` when the
pattern is confirmed.

**Penetration parameter.** `CDLMORNINGSTAR`, `CDLEVENINGSTAR`, `CDLMORNINGDOJISTAR`, `CDLEVENINGDOJISTAR`,
`CDLABANDONEDBABY` (default 0.3), `CDLDARKCLOUDCOVER` and `CDLMATHOLD` (default 0.5) accept an optional
penetration factor.

### Candle settings

Pattern thresholds follow TA-Lib's candle-settings model. Each setting is a record
`(RangeType, AvgPeriod, Factor)`: the "average" of a candle property is taken over the previous `AvgPeriod`
bars and multiplied by `Factor`. They are stored in the global variable `QTCandleSettings`:

| Setting | Range type | Avg period | Factor |
|---|---|---|---|
| `BodyLong` | real body | 10 | 1.0 |
| `BodyVeryLong` | real body | 10 | 3.0 |
| `BodyShort` | real body | 10 | 1.0 |
| `BodyDoji` | high-low | 10 | 0.1 |
| `ShadowLong` | real body | 0 | 1.0 |
| `ShadowVeryLong` | real body | 0 | 2.0 |
| `ShadowShort` | shadows | 10 | 1.0 |
| `ShadowVeryShort` | high-low | 10 | 0.1 |
| `PriceNear` | high-low | 5 | 0.2 |
| `PriceFar` | high-low | 5 | 0.6 |
| `PriceEqual` | high-low | 5 | 0.05 |

```pascal
QTCandleSettings.BodyDoji.Factor := 0.05;   // stricter doji definition
Doji := CDLDOJI(D);
QTResetCandleSettings;                       // back to the defaults
```

### Pattern list

| Function | Pattern | Signals |
|---|---|---|
| `CDL2CROWS(D)` | Two Crows | +-100 |
| `CDL3BLACKCROWS(D)` | Three Black Crows | +-100 |
| `CDL3INSIDE(D)` | Three Inside Up/Down | +-100 |
| `CDL3LINESTRIKE(D)` | Three-Line Strike | +-100 |
| `CDL3OUTSIDE(D)` | Three Outside Up/Down | +-100 |
| `CDL3STARSINSOUTH(D)` | Three Stars In The South | +-100 |
| `CDL3WHITESOLDIERS(D)` | Three Advancing White Soldiers | +-100 |
| `CDLABANDONEDBABY(D)` | Abandoned Baby | +-100 |
| `CDLADVANCEBLOCK(D)` | Advance Block | +-100 |
| `CDLBELTHOLD(D)` | Belt-hold | +-100 |
| `CDLBREAKAWAY(D)` | Breakaway | +-100 |
| `CDLCLOSINGMARUBOZU(D)` | Closing Marubozu | +-100 |
| `CDLCONCEALBABYSWALL(D)` | Concealing Baby Swallow | +-100 |
| `CDLCOUNTERATTACK(D)` | Counterattack | +-100 |
| `CDLDARKCLOUDCOVER(D)` | Dark Cloud Cover | +-100 |
| `CDLDOJI(D)` | Doji | +-100 |
| `CDLDOJISTAR(D)` | Doji Star | +-100 |
| `CDLDRAGONFLYDOJI(D)` | Dragonfly Doji | +-100 |
| `CDLENGULFING(D)` | Engulfing Pattern | +-100 |
| `CDLEVENINGDOJISTAR(D)` | Evening Doji Star | +-100 |
| `CDLEVENINGSTAR(D)` | Evening Star | +-100 |
| `CDLGAPSIDESIDEWHITE(D)` | Up/Down-gap side-by-side white lines | +-100 |
| `CDLGRAVESTONEDOJI(D)` | Gravestone Doji | +-100 |
| `CDLHAMMER(D)` | Hammer | +-100 |
| `CDLHANGINGMAN(D)` | Hanging Man | +-100 |
| `CDLHARAMI(D)` | Harami Pattern | +-100 |
| `CDLHARAMICROSS(D)` | Harami Cross Pattern | +-100 |
| `CDLHIGHWAVE(D)` | High-Wave Candle | +-100 |
| `CDLHIKKAKE(D)` | Hikkake Pattern | +-100, +-200 |
| `CDLHIKKAKEMOD(D)` | Modified Hikkake Pattern | +-100, +-200 |
| `CDLHOMINGPIGEON(D)` | Homing Pigeon | +-100 |
| `CDLIDENTICAL3CROWS(D)` | Identical Three Crows | +-100 |
| `CDLINNECK(D)` | In-Neck Pattern | +-100 |
| `CDLINVERTEDHAMMER(D)` | Inverted Hammer | +-100 |
| `CDLKICKING(D)` | Kicking | +-100 |
| `CDLKICKINGBYLENGTH(D)` | Kicking - bull/bear determined by the longer marubozu | +-100 |
| `CDLLADDERBOTTOM(D)` | Ladder Bottom | +-100 |
| `CDLLONGLEGGEDDOJI(D)` | Long Legged Doji | +-100 |
| `CDLLONGLINE(D)` | Long Line Candle | +-100 |
| `CDLMARUBOZU(D)` | Marubozu | +-100 |
| `CDLMATCHINGLOW(D)` | Matching Low | +-100 |
| `CDLMATHOLD(D)` | Mat Hold | +-100 |
| `CDLMORNINGDOJISTAR(D)` | Morning Doji Star | +-100 |
| `CDLMORNINGSTAR(D)` | Morning Star | +-100 |
| `CDLONNECK(D)` | On-Neck Pattern | +-100 |
| `CDLPIERCING(D)` | Piercing Pattern | +-100 |
| `CDLRICKSHAWMAN(D)` | Rickshaw Man | +-100 |
| `CDLRISEFALL3METHODS(D)` | Rising/Falling Three Methods | +-100 |
| `CDLSEPARATINGLINES(D)` | Separating Lines | +-100 |
| `CDLSHOOTINGSTAR(D)` | Shooting Star | +-100 |
| `CDLSHORTLINE(D)` | Short Line Candle | +-100 |
| `CDLSPINNINGTOP(D)` | Spinning Top | +-100 |
| `CDLSTALLEDPATTERN(D)` | Stalled Pattern | +-100 |
| `CDLSTICKSANDWICH(D)` | Stick Sandwich | +-100 |
| `CDLTAKURI(D)` | Takuri (Dragonfly Doji with very long lower shadow) | +-100 |
| `CDLTASUKIGAP(D)` | Tasuki Gap | +-100 |
| `CDLTHRUSTING(D)` | Thrusting Pattern | +-100 |
| `CDLTRISTAR(D)` | Tristar Pattern | +-100 |
| `CDLUNIQUE3RIVER(D)` | Unique 3 River | +-100 |
| `CDLUPSIDEGAP2CROWS(D)` | Upside Gap Two Crows | +-100 |
| `CDLXSIDEGAP3METHODS(D)` | Upside/Downside Gap Three Methods | +-100 |

(Functions with a penetration factor take it as an optional second argument.)

## Function reference

Parameters are shown with their defaults. `Data`, `High`, `Low`, `Open`, `Close`, `Volume` are
`TQDoubleArray`; `D` is `TQOHLCV`. Unless stated otherwise the result has the same length as the input and
the warm-up part is `NaN`.

### `QuantTech4D.Overlap` - Overlap studies

Moving averages, bands and trailing stops.

| Function | Parameters | Returns | Description |
|---|---|---|---|
| `SMA` | Data: TQDoubleArray; Period: Integer = 30 | TQDoubleArray | Simple Moving Average. |
| `EMA` | Data: TQDoubleArray; Period: Integer = 30 | TQDoubleArray | Exponential Moving Average (seeded with an SMA, like TA-Lib). |
| `WMA` | Data: TQDoubleArray; Period: Integer = 30 | TQDoubleArray | Weighted Moving Average (linear weights 1..Period). |
| `DEMA` | Data: TQDoubleArray; Period: Integer = 30 | TQDoubleArray | Double Exponential Moving Average. |
| `TEMA` | Data: TQDoubleArray; Period: Integer = 30 | TQDoubleArray | Triple Exponential Moving Average. |
| `TRIMA` | Data: TQDoubleArray; Period: Integer = 30 | TQDoubleArray | Triangular Moving Average. |
| `KAMA` | Data: TQDoubleArray; Period: Integer = 30; FastLimit: Integer = 2; SlowLimit: Integer = 30 | TQDoubleArray | Kaufman Adaptive Moving Average. |
| `T3` | Data: TQDoubleArray; Period: Integer = 5; VFactor: Double = 0.7 | TQDoubleArray | Triple Exponential Moving Average (T3, Tillson). |
| `MA` | Data: TQDoubleArray; Period: Integer = 30; MAType: TQMAType = maSMA | TQDoubleArray | Generic moving average selected by type. |
| `HMA` | Data: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | Hull Moving Average. |
| `ZLEMA` | Data: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | Zero-Lag Exponential Moving Average. |
| `RMA` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Wilder's smoothed moving average (alpha = 1/Period). |
| `VWMA` | Price, Volume: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | Volume Weighted Moving Average. |
| `BBANDS` | Data: TQDoubleArray; Period: Integer = 5; NbDevUp: Double = 2.0; NbDevDn: Double = 2.0; MAType: TQMAType = maSMA | TQBBands | Bollinger Bands (population standard deviation, like TA-Lib). |
| `MIDPOINT` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | MidPoint over period: (highest + lowest) / 2 of one series. |
| `MIDPRICE` | High, Low: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Midpoint price over period: (highest high + lowest low) / 2. |
| `SAR` | High, Low: TQDoubleArray; Acceleration: Double = 0.02; Maximum: Double = 0.2 | TQDoubleArray | Parabolic SAR. |

### `QuantTech4D.Momentum` - Momentum indicators

Oscillators and directional-movement indicators.

| Function | Parameters | Returns | Description |
|---|---|---|---|
| `RSI` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Relative Strength Index (Wilder smoothing). |
| `CMO` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Chande Momentum Oscillator. |
| `MACD` | Data: TQDoubleArray; FastPeriod: Integer = 12; SlowPeriod: Integer = 26; SignalPeriod: Integer = 9 | TQMACD | MACD (fast EMA is seeded at the slow EMA's first bar, like TA-Lib). |
| `MACDFIX` | Data: TQDoubleArray; SignalPeriod: Integer = 9 | TQMACD | MACD with fixed 12/26 periods and TA-Lib's legacy 0.15 / 0.075 factors. |
| `STOCHF` | High, Low, Close: TQDoubleArray; FastKPeriod: Integer = 5; FastDPeriod: Integer = 3; FastDMAType: TQMAType = maSMA | TQStoch | Fast Stochastic. |
| `STOCH` | High, Low, Close: TQDoubleArray; FastKPeriod: Integer = 5; SlowKPeriod: Integer = 3; SlowKMAType: TQMAType = maSMA; SlowDPeriod: Integer = 3; SlowDMAType: TQMAType = maSMA | TQStoch | Slow Stochastic. |
| `STOCHRSI` | Data: TQDoubleArray; Period: Integer = 14; FastKPeriod: Integer = 5; FastDPeriod: Integer = 3; FastDMAType: TQMAType = maSMA | TQStoch | Stochastic RSI. |
| `PLUS_DM` | High, Low: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Wilder-smoothed plus directional movement. |
| `MINUS_DM` | High, Low: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Wilder-smoothed minus directional movement. |
| `PLUS_DI` | High, Low, Close: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | - |
| `MINUS_DI` | High, Low, Close: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | - |
| `DX` | High, Low, Close: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Directional Movement Index. |
| `ADX` | High, Low, Close: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Average Directional Movement Index. |
| `ADXR` | High, Low, Close: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Average Directional Movement Index Rating. |
| `CCI` | High, Low, Close: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Commodity Channel Index. |
| `MOM` | Data: TQDoubleArray; Period: Integer = 10 | TQDoubleArray | Momentum: price - price[Period ago]. |
| `ROC` | Data: TQDoubleArray; Period: Integer = 10 | TQDoubleArray | Rate of change: ((price/prev) - 1) * 100. |
| `ROCP` | Data: TQDoubleArray; Period: Integer = 10 | TQDoubleArray | Rate of change percentage: (price - prev) / prev. |
| `ROCR` | Data: TQDoubleArray; Period: Integer = 10 | TQDoubleArray | Rate of change ratio: price / prev. |
| `ROCR100` | Data: TQDoubleArray; Period: Integer = 10 | TQDoubleArray | Rate of change ratio, 100 scale: price / prev * 100. |
| `WILLR` | High, Low, Close: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Williams' %R. |
| `APO` | Data: TQDoubleArray; FastPeriod: Integer = 12; SlowPeriod: Integer = 26; MAType: TQMAType = maSMA | TQDoubleArray | Absolute Price Oscillator. |
| `PPO` | Data: TQDoubleArray; FastPeriod: Integer = 12; SlowPeriod: Integer = 26; MAType: TQMAType = maSMA | TQDoubleArray | Percentage Price Oscillator. |
| `AROON` | High, Low: TQDoubleArray; Period: Integer = 14 | TQAroon | Aroon (down and up). |
| `AROONOSC` | High, Low: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Aroon Oscillator (up - down). |
| `BOP` | Open, High, Low, Close: TQDoubleArray | TQDoubleArray | Balance Of Power. |
| `MFI` | High, Low, Close, Volume: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Money Flow Index. |
| `TRIX` | Data: TQDoubleArray; Period: Integer = 30 | TQDoubleArray | 1-period rate of change of a triple smoothed EMA. |
| `ULTOSC` | High, Low, Close: TQDoubleArray; Period1: Integer = 7; Period2: Integer = 14; Period3: Integer = 28 | TQDoubleArray | Ultimate Oscillator. |
| `AO` | High, Low: TQDoubleArray; FastPeriod: Integer = 5; SlowPeriod: Integer = 34 | TQDoubleArray | Awesome Oscillator: SMA(median,5) - SMA(median,34). |

### `QuantTech4D.Volatility` - Volatility indicators

True range based measures.

| Function | Parameters | Returns | Description |
|---|---|---|---|
| `TRANGE` | High, Low, Close: TQDoubleArray | TQDoubleArray | True Range. The first element is NaN (needs the previous close). |
| `ATR` | High, Low, Close: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Average True Range (Wilder smoothing, seeded with the mean of the first TRs). |
| `NATR` | High, Low, Close: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Normalized ATR: ATR / Close * 100. |

### `QuantTech4D.Volume` - Volume indicators

Accumulation/distribution, on-balance volume and money flow.

| Function | Parameters | Returns | Description |
|---|---|---|---|
| `AD` | High, Low, Close, Volume: TQDoubleArray | TQDoubleArray | Chaikin Accumulation/Distribution line. |
| `ADOSC` | High, Low, Close, Volume: TQDoubleArray; FastPeriod: Integer = 3; SlowPeriod: Integer = 10 | TQDoubleArray | Chaikin A/D Oscillator (fast EMA - slow EMA of the A/D line). |
| `OBV` | Close, Volume: TQDoubleArray | TQDoubleArray | On Balance Volume. |
| `CMF` | High, Low, Close, Volume: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | Chaikin Money Flow. |

### `QuantTech4D.Price` - Price transforms

Derived price series and Heikin-Ashi candles.

| Function | Parameters | Returns | Description |
|---|---|---|---|
| `AVGPRICE` | Open, High, Low, Close: TQDoubleArray | TQDoubleArray | Average price: (O + H + L + C) / 4. |
| `MEDPRICE` | High, Low: TQDoubleArray | TQDoubleArray | Median price: (H + L) / 2. |
| `TYPPRICE` | High, Low, Close: TQDoubleArray | TQDoubleArray | Typical price: (H + L + C) / 3. |
| `WCLPRICE` | High, Low, Close: TQDoubleArray | TQDoubleArray | Weighted close price: (H + L + 2C) / 4. |
| `HeikinAshi` | Data: TQOHLCV | TQOHLCV | Heikin-Ashi candles (Volume is copied unchanged). |

### `QuantTech4D.Statistic` - Statistic functions

Rolling statistics and linear regression.

| Function | Parameters | Returns | Description |
|---|---|---|---|
| `StdDevRoll` | Data: TQDoubleArray; Period: Integer = 5; NbDev: Double = 1.0 | TQDoubleArray | Rolling population standard deviation times NbDev (TA-Lib: STDDEV). |
| `VarianceRoll` | Data: TQDoubleArray; Period: Integer = 5 | TQDoubleArray | Rolling population variance (TA-Lib: VAR). |
| `BetaRoll` | Data0, Data1: TQDoubleArray; Period: Integer = 5 | TQDoubleArray | Beta of Data1 returns regressed on Data0 returns (TA-Lib: BETA). |
| `CORREL` | Data0, Data1: TQDoubleArray; Period: Integer = 30 | TQDoubleArray | Pearson's correlation coefficient (TA-Lib: CORREL). |
| `LINEARREG` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Linear regression value at the last bar of each window. |
| `LINEARREG_SLOPE` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Linear regression slope. |
| `LINEARREG_INTERCEPT` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Linear regression intercept (value at the first bar of the window). |
| `LINEARREG_ANGLE` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Linear regression angle in degrees. |
| `TSF` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Time Series Forecast (regression projected one bar ahead). |

### `QuantTech4D.MathOps` - Math transforms, operators and rolling windows

Vector arithmetic, element-wise math functions and rolling window helpers.

| Function | Parameters | Returns | Description |
|---|---|---|---|
| `VecAdd` | A, B: TQDoubleArray | TQDoubleArray | - |
| `VecSub` | A, B: TQDoubleArray | TQDoubleArray | - |
| `VecMult` | A, B: TQDoubleArray | TQDoubleArray | - |
| `VecDiv` | A, B: TQDoubleArray | TQDoubleArray | Element-wise division; division by zero yields NaN. |
| `VecAcos` | A: TQDoubleArray | TQDoubleArray | - |
| `VecAsin` | A: TQDoubleArray | TQDoubleArray | - |
| `VecAtan` | A: TQDoubleArray | TQDoubleArray | - |
| `VecCeil` | A: TQDoubleArray | TQDoubleArray | - |
| `VecCos` | A: TQDoubleArray | TQDoubleArray | - |
| `VecCosh` | A: TQDoubleArray | TQDoubleArray | - |
| `VecExp` | A: TQDoubleArray | TQDoubleArray | - |
| `VecFloor` | A: TQDoubleArray | TQDoubleArray | - |
| `VecLn` | A: TQDoubleArray | TQDoubleArray | - |
| `VecLog10` | A: TQDoubleArray | TQDoubleArray | - |
| `VecSin` | A: TQDoubleArray | TQDoubleArray | - |
| `VecSinh` | A: TQDoubleArray | TQDoubleArray | - |
| `VecSqrt` | A: TQDoubleArray | TQDoubleArray | - |
| `VecTan` | A: TQDoubleArray | TQDoubleArray | - |
| `VecTanh` | A: TQDoubleArray | TQDoubleArray | - |
| `RollingMax` | Data: TQDoubleArray; Period: Integer = 30 | TQDoubleArray | - |
| `RollingMin` | Data: TQDoubleArray; Period: Integer = 30 | TQDoubleArray | - |
| `RollingSum` | Data: TQDoubleArray; Period: Integer = 30 | TQDoubleArray | - |
| `RollingMaxIndex` | Data: TQDoubleArray; Period: Integer = 30 | TQIntArray | Absolute index (into Data) of the highest value in each window; -1 during warm-up. |
| `RollingMinIndex` | Data: TQDoubleArray; Period: Integer = 30 | TQIntArray | Absolute index (into Data) of the lowest value in each window; -1 during warm-up. |
| `RollingMinMax` | Data: TQDoubleArray; Period: Integer = 30 | TQMinMax | - |
| `RollingMinMaxIndex` | Data: TQDoubleArray; Period: Integer = 30; out LowestIdx, HighestIdx: TQIntArray | Boolean | Indexes of the lowest and highest value in each window (TA-Lib: MINMAXINDEX). |
| `RollingMedian` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Rolling median. |
| `CumSum` | Data: TQDoubleArray | TQDoubleArray | Cumulative sum. |

### `QuantTech4D.Cycle` - Cycle indicators (Hilbert Transform)

MAMA/FAMA and the HT_* family.

| Function | Parameters | Returns | Description |
|---|---|---|---|
| `MAMA` | Data: TQDoubleArray; FastLimit: Double = 0.5; SlowLimit: Double = 0.05 | TQMAMA | MESA Adaptive Moving Average and its companion FAMA. |
| `HT_TRENDLINE` | Data: TQDoubleArray | TQDoubleArray | Hilbert Transform - Instantaneous Trendline. |
| `HT_DCPERIOD` | Data: TQDoubleArray | TQDoubleArray | Hilbert Transform - Dominant Cycle Period. |
| `HT_DCPHASE` | Data: TQDoubleArray | TQDoubleArray | Hilbert Transform - Dominant Cycle Phase. |
| `HT_PHASOR` | Data: TQDoubleArray | TQPhasor | Hilbert Transform - Phasor Components (in-phase and quadrature). |
| `HT_SINE` | Data: TQDoubleArray | TQHTSine | Hilbert Transform - SineWave (sine and lead sine). |
| `HT_TRENDMODE` | Data: TQDoubleArray | TQIntArray | Hilbert Transform - Trend vs Cycle Mode: 1 = trend, 0 = cycle (0 in warm-up). |

### `QuantTech4D.Extended` - Extended indicators

The newer indicators of TA-Lib's function list.

| Function | Parameters | Returns | Description |
|---|---|---|---|
| `ALMA` | Data: TQDoubleArray; Period: Integer = 9; Offset: Double = 0.85; Sigma: Double = 6.0 | TQDoubleArray | Arnaud Legoux Moving Average. |
| `FRAMA` | Data: TQDoubleArray; Period: Integer = 16 | TQDoubleArray | Fractal Adaptive Moving Average (Ehlers). Period must be even (>= 4). |
| `VIDYA` | Data: TQDoubleArray; Period: Integer = 14; CMOPeriod: Integer = 9 | TQDoubleArray | Variable Index Dynamic Average (Chande): EMA whose alpha scales with \|CMO\|. |
| `MCGD` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | McGinley Dynamic. |
| `MAVP` | Data, Periods: TQDoubleArray; MinPeriod: Integer = 2; MaxPeriod: Integer = 30; MAType: TQMAType = maSMA | TQDoubleArray | Moving average with variable period (Periods[i] selects the period at bar i). |
| `MACDEXT` | Data: TQDoubleArray; FastPeriod: Integer = 12; FastMAType: TQMAType = maSMA; SlowPeriod: Integer = 26; SlowMAType: TQMAType = maSMA; SignalPeriod: Integer = 9; SignalMAType: TQMAType = maSMA | TQMACD | MACD with controllable MA types. |
| `MACDV` | High, Low, Close: TQDoubleArray; FastPeriod: Integer = 12; SlowPeriod: Integer = 26; SignalPeriod: Integer = 9 | TQMACD | MACD-V: (EMA fast - EMA slow) / ATR(slow) * 100. |
| `SAREXT` | High, Low: TQDoubleArray; StartValue: Double = 0.0; OffsetOnReverse: Double = 0.0; AFInitLong: Double = 0.02; AFLong: Double = 0.02; AFMaxLong: Double = 0.2; AFInitShort: Double = 0.02; AFShort: Double = 0.02; AFMaxShort: Double = 0.2 | TQDoubleArray | Parabolic SAR extended. Short-side values are returned negative (TA-Lib convention). |
| `SUPERTREND` | High, Low, Close: TQDoubleArray; Period: Integer = 10; Multiplier: Double = 3.0 | TQPair | SuperTrend. First = SuperTrend line, Second = direction (1 up, -1 down). |
| `SWAK_HP` | Data: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | - |
| `SWAK_2PHP` | Data: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | - |
| `SWAK_BUTTER` | Data: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | - |
| `SWAK_GAUSS` | Data: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | - |
| `SWAK_BP` | Data: TQDoubleArray; Period: Integer = 20; Bandwidth: Double = 0.1 | TQDoubleArray | - |
| `ACCBANDS` | High, Low, Close: TQDoubleArray; Period: Integer = 20 | TQBBands | Headley Acceleration Bands. |
| `BBW` | Data: TQDoubleArray; Period: Integer = 20; NbDev: Double = 2.0 | TQDoubleArray | Bollinger BandWidth: (upper - lower) / middle. |
| `PERCENTB` | Data: TQDoubleArray; Period: Integer = 20; NbDev: Double = 2.0 | TQDoubleArray | Bollinger %B. |
| `DONCHIAN` | High, Low: TQDoubleArray; Period: Integer = 20 | TQBBands | Donchian Channels (Upper = highest high, Lower = lowest low). |
| `KC` | High, Low, Close: TQDoubleArray; Period: Integer = 20; Multiplier: Double = 2.0; ATRPeriod: Integer = 10 | TQBBands | Keltner Channels: EMA(close) +/- Multiplier * ATR. |
| `CE` | High, Low, Close: TQDoubleArray; Period: Integer = 22; Multiplier: Double = 3.0 | TQPair | Chandelier Exit. First = long exit, Second = short exit. |
| `CKSP` | High, Low, Close: TQDoubleArray; P: Integer = 10; X: Double = 1.0; Q: Integer = 9 | TQPair | Chande Kroll Stop. First = stop for longs, Second = stop for shorts. |
| `ICHIMOKU` | High, Low, Close: TQDoubleArray; TenkanPeriod: Integer = 9; KijunPeriod: Integer = 26; SenkouBPeriod: Integer = 52; Displacement: Integer = 26 | TQIchimoku | Ichimoku Kinko Hyo (Senkou spans are shifted forward, Chikou back). |
| `ADR` | High, Low: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Average Day Range: SMA(high - low). |
| `ROGERSSATCHELL` | Open, High, Low, Close: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | Rogers-Satchell volatility (per-bar, not annualised). |
| `CVI` | High, Low: TQDoubleArray; Period: Integer = 10; ROCPeriod: Integer = 10 | TQDoubleArray | Chaikin's Volatility: ROC of EMA(high - low). |
| `CHOP` | High, Low, Close: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Choppiness Index. |
| `CHOPTR` | High, Low, Close: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Choppiness Index using the True Range box (prior close widens the high/low). |
| `MASSI` | High, Low: TQDoubleArray; EMAPeriod: Integer = 9; SumPeriod: Integer = 25 | TQDoubleArray | Mass Index. |
| `VHF` | Data: TQDoubleArray; Period: Integer = 28 | TQDoubleArray | Vertical Horizontal Filter. |
| `AC` | High, Low: TQDoubleArray | TQDoubleArray | Accelerator/Decelerator Oscillator: AO - SMA(AO, 5). |
| `CG` | Data: TQDoubleArray; Period: Integer = 10 | TQDoubleArray | Center of Gravity oscillator (Ehlers). |
| `CMOU` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Chande Momentum Oscillator, unsmoothed (plain window sums). |
| `COPPOCK` | Data: TQDoubleArray; ROC1: Integer = 14; ROC2: Integer = 11; WMAPeriod: Integer = 10 | TQDoubleArray | Coppock Curve: WMA(ROC1 + ROC2, WMAPeriod). |
| `CRSI` | Data: TQDoubleArray; RSIPeriod: Integer = 3; StreakPeriod: Integer = 2; RankPeriod: Integer = 100 | TQDoubleArray | Connors RSI: average of RSI(price), RSI(streak) and PercentRank(ROC). |
| `CTI` | Data: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | Correlation Trend Indicator (Ehlers): correlation of price with time. |
| `DOSC` | Data: TQDoubleArray; RSIPeriod: Integer = 14; EMA1: Integer = 5; EMA2: Integer = 3; SignalPeriod: Integer = 9 | TQDoubleArray | Derivative Oscillator: smoothed RSI minus its signal line. |
| `DPO` | Data: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | Detrended Price Oscillator. |
| `ER` | Data: TQDoubleArray; Period: Integer = 10 | TQDoubleArray | Kaufman Efficiency Ratio. |
| `ERI` | High, Low, Close: TQDoubleArray; Period: Integer = 13 | TQPair | Elder Ray Index. First = bull power, Second = bear power. |
| `FISHER` | High, Low: TQDoubleArray; Period: Integer = 9 | TQPair | Fisher Transform. First = Fisher, Second = trigger (previous Fisher). |
| `FOSC` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Forecast Oscillator: 100 * (close - TSF) / close. |
| `IBS` | High, Low, Close: TQDoubleArray | TQDoubleArray | Internal Bar Strength: (close - low) / (high - low). |
| `IMI` | Open, Close: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | Intraday Momentum Index. |
| `KDJ` | High, Low, Close: TQDoubleArray; Period: Integer = 9; KSmooth: Integer = 3; DSmooth: Integer = 3 | TQKDJ | KDJ stochastic with recursive 1/3 smoothing; seeds are 50. |
| `KST` | Data: TQDoubleArray; R1: Integer = 10; R2: Integer = 15; R3: Integer = 20; R4: Integer = 30; S1: Integer = 10; S2: Integer = 10; S3: Integer = 10; S4: Integer = 15; SignalPeriod: Integer = 9 | TQPair | Know Sure Thing (Pring). First = KST, Second = signal. |
| `KSTEXT` | Data: TQDoubleArray; R1: Integer = 10; R2: Integer = 15; R3: Integer = 20; R4: Integer = 30; S1: Integer = 10; S2: Integer = 10; S3: Integer = 10; S4: Integer = 15; SignalPeriod: Integer = 9; MAType: TQMAType = maSMA | TQPair | Know Sure Thing with controllable MA type. |
| `PSO` | High, Low, Close: TQDoubleArray; StochPeriod: Integer = 8; SmoothPeriod: Integer = 5 | TQDoubleArray | Premier Stochastic Oscillator (Leibfarth), range -1..1. |
| `RVI` | Data: TQDoubleArray; StdPeriod: Integer = 10; SmoothPeriod: Integer = 14 | TQDoubleArray | Relative Volatility Index (Dorsey) on closes. |
| `RVIR` | High, Low: TQDoubleArray; StdPeriod: Integer = 10; SmoothPeriod: Integer = 14 | TQDoubleArray | Relative Volatility Index, refined: average of RVI(high) and RVI(low). |
| `SMI` | High, Low, Close: TQDoubleArray; Period: Integer = 10; Smooth1: Integer = 3; Smooth2: Integer = 3; SignalPeriod: Integer = 3 | TQPair | Stochastic Momentum Index (Blau). First = SMI, Second = signal. |
| `SQZMOM` | High, Low, Close: TQDoubleArray; BBPeriod: Integer = 20; BBMult: Double = 2.0; KCPeriod: Integer = 20; KCMult: Double = 1.5 | TQPair | Squeeze Momentum. First = momentum, Second = squeeze flag (1 = squeeze on). |
| `STC` | Data: TQDoubleArray; FastPeriod: Integer = 23; SlowPeriod: Integer = 50; CyclePeriod: Integer = 10; Smooth: Double = 0.5 | TQDoubleArray | Schaff Trend Cycle. |
| `TSI` | Data: TQDoubleArray; LongPeriod: Integer = 25; ShortPeriod: Integer = 13 | TQDoubleArray | True Strength Index. |
| `VORTEX` | High, Low, Close: TQDoubleArray; Period: Integer = 14 | TQPair | Vortex Indicator. First = VI+, Second = VI-. |
| `WAVETREND` | High, Low, Close: TQDoubleArray; ChannelPeriod: Integer = 10; AveragePeriod: Integer = 21 | TQPair | WaveTrend Oscillator. First = WT1, Second = WT2 (SMA(WT1,4)). |
| `SI` | Open, High, Low, Close: TQDoubleArray; LimitMove: Double = 0.5 | TQDoubleArray | Wilder Swing Index. |
| `ASI` | Open, High, Low, Close: TQDoubleArray; LimitMove: Double = 0.5 | TQDoubleArray | Wilder Accumulative Swing Index. |
| `AVGDEV` | Data: TQDoubleArray; Period: Integer = 14 | TQDoubleArray | - |
| `SkewRoll` | Data: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | Rolling skewness (population moments). |
| `KurtosisRoll` | Data: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | Rolling excess kurtosis (population moments). |
| `PercentileRoll` | Data: TQDoubleArray; Period: Integer = 20; Percentile: Double = 50.0 | TQDoubleArray | Rolling percentile, nearest-rank method (Percentile in 0..100). |
| `PERCENTRANK` | Data: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | Percent rank: share of the previous Period values that are <= the current value. |
| `EFI` | Close, Volume: TQDoubleArray; Period: Integer = 13 | TQDoubleArray | Elder's Force Index: EMA(volume * close change). |
| `EMV` | High, Low, Volume: TQDoubleArray; Period: Integer = 14; VolumeScale: Double = 10000.0 | TQDoubleArray | Arms Ease of Movement (VolumeScale divides the volume to size the box ratio). |
| `KVO` | High, Low, Close, Volume: TQDoubleArray; FastPeriod: Integer = 34; SlowPeriod: Integer = 55; SignalPeriod: Integer = 13 | TQPair | Klinger Volume Oscillator. First = KVO, Second = signal. |
| `MARKETFI` | High, Low, Volume: TQDoubleArray | TQDoubleArray | Market Facilitation Index: (high - low) / volume. |
| `NVI` | Close, Volume: TQDoubleArray | TQDoubleArray | Negative Volume Index (starts at 1000). |
| `PVI` | Close, Volume: TQDoubleArray | TQDoubleArray | Positive Volume Index (starts at 1000). |
| `PVO` | Volume: TQDoubleArray; FastPeriod: Integer = 12; SlowPeriod: Integer = 26; SignalPeriod: Integer = 9 | TQMACD | Percentage Volume Oscillator (MACD of volume, in percent). |
| `PVT` | Close, Volume: TQDoubleArray | TQDoubleArray | Price Volume Trend. |
| `QSTICK` | Open, Close: TQDoubleArray; Period: Integer = 8 | TQDoubleArray | Qstick: SMA(close - open). |
| `RVOL` | Volume: TQDoubleArray; Period: Integer = 20 | TQDoubleArray | Relative Volume: volume / SMA(volume). |
| `VWAP` | High, Low, Close, Volume: TQDoubleArray | TQDoubleArray | Cumulative Volume Weighted Average Price of the whole series. |
| `WAD` | High, Low, Close: TQDoubleArray | TQDoubleArray | Williams' Accumulation/Distribution. |
| `FRACTAL` | High, Low: TQDoubleArray | TQPair | Williams Fractal. First = fractal highs, Second = fractal lows (value at the centre bar). |
| `ZIGZAG` | High, Low: TQDoubleArray; Deviation: Double = 5.0 | TQDoubleArray | ZigZag with a percentage deviation. Pivot prices at pivot bars, NaN elsewhere. |

### `QuantTech4D.Data` - Data helpers

CSV loading, synthetic sample data and formatting.

| Function | Parameters | Returns | Description |
|---|---|---|---|
| `LoadOHLCVFromCSV` | FileName: string; HasHeader: Boolean = True; Delimiter: Char = ',' | TQOHLCV | Loads OHLCV bars from a CSV file. Accepted layouts: [Date,]Open,High,Low,Close,Volume (a leading text/date column is detected automatically when there are 6 or more columns). Rows are expected oldest first. |
| `GenerateSampleOHLCV` | Count: Integer; Seed: Integer = 42; StartPrice: Double = 100.0 | TQOHLCV | Generates a reproducible random-walk OHLCV series for demos and tests. |
| `QTFmt` | X: Double; Decimals: Integer = 4 | string | Formats a value with the given decimals; NaN becomes 'n/a'. |

### `QuantTech4D.Core` - Core helpers

Low-level helpers used by the indicator units.

| Function | Parameters | Returns | Description |
|---|---|---|---|
| `QTNaNSeries` | N: Integer | TQDoubleArray | Returns an array of N elements, all set to NaN. |
| `QTFirstValid` | X: TQDoubleArray | Integer | Index of the first non-NaN element, or -1 if there is none. |
| `QTLookback` | X: TQDoubleArray | Integer | Number of leading NaN values in an indicator output (its "lookback"). |
| `QTCheckPeriod` | Period, MinPeriod: Integer; FuncName: string | - | Raises EQuantTechError when Period < MinPeriod. |
| `QTCheckLength` | A, B: Integer; FuncName: string | - | Raises EQuantTechError when two input arrays differ in length. |
| `QTEMAAt` | X: TQDoubleArray; Period: Integer; K: Double; SeedIdx: Integer | TQDoubleArray | EMA whose first value (an SMA seed) is placed at SeedIdx. The seed is the average of X[SeedIdx-Period+1 .. SeedIdx]. |
| `QTEMA` | X: TQDoubleArray; Period: Integer; K: Double | TQDoubleArray | EMA seeded at the first valid index + Period - 1 (TA-Lib classic behaviour). |
| `QTRollingStdDev` | X: TQDoubleArray; Period: Integer | TQDoubleArray | Rolling population standard deviation (divides by N, like TA-Lib). |

### `QuantTech4D.Patterns` - Candlestick patterns

61 functions, see the [pattern list](#pattern-list). Additional members: `QTCandleSettings`
(variable of type `TQCandleSettings`) and `procedure QTResetCandleSettings`.

### `QuantTech4D.Types`

Shared types listed in [Data types](#data-types) plus `EQuantTechError`.

## TA-Lib name mapping

Names that would clash with Pascal/RTL identifiers differ from TA-Lib:

| TA-Lib | QuantTech4D |
|---|---|
| `MAX`, `MIN`, `SUM` | `RollingMax`, `RollingMin`, `RollingSum` |
| `MAXINDEX`, `MININDEX`, `MINMAX`, `MINMAXINDEX` | `RollingMaxIndex`, `RollingMinIndex`, `RollingMinMax`, `RollingMinMaxIndex` |
| `MEDIAN`, `CUMSUM` | `RollingMedian`, `CumSum` |
| `ADD`, `SUB`, `MULT`, `DIV` | `VecAdd`, `VecSub`, `VecMult`, `VecDiv` |
| `ACOS`, `ASIN`, `ATAN`, `CEIL`, `COS`, `COSH`, `EXP`, `FLOOR`, `LN`, `LOG10`, `SIN`, `SINH`, `SQRT`, `TAN`, `TANH` | `Vec` + the same name (`VecAcos`, `VecLn`, ...) |
| `STDDEV`, `VAR`, `BETA` | `StdDevRoll`, `VarianceRoll`, `BetaRoll` |
| `SKEW`, `KURTOSIS`, `PERCENTILE` | `SkewRoll`, `KurtosisRoll`, `PercentileRoll` |
| `HA` | `HeikinAshi` |

All other functions keep their TA-Lib name.

## Algorithm notes

### Compatibility with TA-Lib

* **EMA** is seeded with the simple average of the first `Period` values; `K = 2 / (Period + 1)`.
* **MACD** seeds the fast EMA at the first bar of the slow EMA (as TA-Lib does). `MACDFIX` uses the fixed
  12/26 periods with TA-Lib's 0.15 / 0.075 smoothing factors.
* **RSI, CMO, ATR, ADX family** use Wilder smoothing seeded with a simple average.
* **Bollinger Bands** use the population standard deviation (divides by N); `NbDev` multipliers apply per band.
* **SAR / SAREXT** follow TA-Lib's reversal logic; `SAREXT` returns negative values while short.
* **Stochastic** `%K` is 0 when the window range is zero; `%D` and slow `%K` accept any `TQMAType`.
* **Candlestick lookbacks** are derived from the candle settings, as in TA-Lib.
* **Hilbert Transform** functions share one state machine (4-bar WMA smoother plus even/odd Hilbert
  transformer). Lookbacks: `MAMA`, `HT_DCPERIOD`, `HT_PHASOR` 32 bars; `HT_TRENDLINE`, `HT_DCPHASE`,
  `HT_SINE`, `HT_TRENDMODE` 63 bars.

### Differences in the API

* Results are full-length arrays with `NaN` warm-up instead of `begIdx` / `nbElement` pairs.
* `TA_SetUnstablePeriod` and `TA_SetCompatibility` are not exposed; the classic (non-Metastock) behaviour
  with zero unstable period is always used.
* `MA` with `maMAMA` returns the MAMA line using the default limits (0.5 / 0.05); the period is ignored.

### Definitions used by `QuantTech4D.Extended`

| Indicator | Definition / defaults |
|---|---|
| `AC` | `AO - SMA(AO, 5)` |
| `ACCBANDS` | Headley bands: `SMA(High * (1 + 4 * (H - L) / (H + L)))`, `SMA(Close)`, `SMA(Low * (1 - 4 * (H - L) / (H + L)))`, period 20 |
| `ADR` | `SMA(High - Low, 14)` |
| `ALMA` | Gaussian-weighted MA, offset 0.85, sigma 6, period 9 |
| `SI`, `ASI` | Wilder swing index / cumulative swing index, limit move 0.5 |
| `AVGDEV` | Mean absolute deviation from the mean, period 14 |
| `BBW`, `PERCENTB` | `(Upper - Lower) / Middle` and `(Price - Lower) / (Upper - Lower)`, 20 bars, 2 deviations |
| `CE` | Chandelier exit: `HH(22) - 3 * ATR` (long) and `LL(22) + 3 * ATR` (short) |
| `CKSP` | Chande-Kroll stop, `P = 10`, `X = 1`, `Q = 9` |
| `CG` | Ehlers center of gravity, period 10 |
| `CHOP`, `CHOPTR` | `100 * log10(sum(TR) / (HH - LL)) / log10(N)`, period 14; `CHOPTR` widens the box with the previous close |
| `CMOU` | CMO from plain window sums of ups and downs (no Wilder smoothing), period 14 |
| `COPPOCK` | `WMA(ROC(14) + ROC(11), 10)` |
| `CRSI` | `(RSI(price, 3) + RSI(streak, 2) + PercentRank(ROC(1), 100)) / 3` |
| `CTI` | Correlation of price with time over 20 bars |
| `CVI` | Chaikin volatility: 10-bar ROC of `EMA(High - Low, 10)` |
| `DONCHIAN`, `KC` | Highest high / lowest low; `EMA(20) +- 2 * ATR(10)` |
| `DOSC` | Smoothed RSI(14) with EMA 5 and 3 minus a 9-bar SMA signal |
| `DPO` | `Price[i - (N/2 + 1)] - SMA(N)`, period 20 |
| `EFI` | `EMA(Volume * (Close - PrevClose), 13)` |
| `EMV` | Arms ease of movement, SMA 14, box ratio `(Volume / VolumeScale) / (High - Low)` |
| `ER` | Kaufman efficiency ratio, period 10 |
| `ERI` | Bull power `High - EMA(13)`, bear power `Low - EMA(13)` |
| `FISHER` | Ehlers Fisher transform, period 9, trigger = previous value |
| `FOSC` | `100 * (Close - TSF(14)) / Close` |
| `FRACTAL` | Williams 5-bar fractals, value reported at the centre bar |
| `FRAMA` | Ehlers fractal adaptive MA, period 16 |
| `IBS` | `(Close - Low) / (High - Low)` |
| `ICHIMOKU` | 9 / 26 / 52 with displacement 26 (Senkou spans shifted forward, Chikou back) |
| `IMI` | Intraday momentum index, period 14 |
| `KDJ` | RSV period 9 with recursive 1/3 smoothing, `J = 3K - 2D`, seeds 50 |
| `KST`, `KSTEXT` | Pring's KST, ROC 10/15/20/30 smoothed 10/10/10/15, weights 1-4, signal 9 |
| `KVO` | Klinger oscillator 34/55 with signal 13 |
| `MACDEXT`, `MACDV` | MACD with MA types; MACD divided by `ATR(26)` times 100 |
| `MARKETFI`, `MASSI` | `(High - Low) / Volume`; mass index EMA 9, sum 25 |
| `MAVP` | Per-bar period selected from `Periods[i]`, clipped to `[MinPeriod, MaxPeriod]` |
| `MCGD` | McGinley dynamic, period 14 |
| `NVI`, `PVI`, `PVT` | Volume indexes starting at 1000; price-volume trend |
| `PERCENTILE`, `PERCENTRANK` | Nearest-rank percentile; share of the previous N values <= current |
| `PSO` | Premier stochastic oscillator, stochastic period 8, smoothing 5, range -1..1 |
| `PVO` | `(EMA12(V) - EMA26(V)) / EMA26(V) * 100`, signal 9 |
| `QSTICK` | `SMA(Close - Open, 8)` |
| `ROGERSSATCHELL` | Per-bar Rogers-Satchell volatility, 20 bars |
| `RVI`, `RVIR` | Dorsey relative volatility index (std 10, EMA 14); refined = average of high and low forms |
| `RVOL` | `Volume / SMA(Volume, 20)` |
| `SKEW`, `KURTOSIS` | Rolling population skewness / excess kurtosis |
| `SMI` | Blau stochastic momentum index 10/3/3 with signal 3 |
| `SQZMOM` | Bollinger vs Keltner squeeze flag and linear-regression momentum |
| `STC` | Schaff trend cycle 23/50, cycle 10, smoothing 0.5 |
| `SUPERTREND` | ATR(10) x 3 with ratcheting bands |
| `SWAK_*` | Ehlers high-pass, two-pole high-pass, Butterworth, Gaussian and band-pass filters, period 20 |
| `TSI` | True strength index 25 / 13 |
| `VHF` | Vertical horizontal filter, period 28 |
| `VIDYA` | Chande VIDYA, EMA period 14 scaled by `|CMO(9)|` |
| `VORTEX` | Vortex indicator, period 14 |
| `VWAP` | Cumulative volume weighted average price of the series |
| `WAD` | Williams accumulation/distribution |
| `WAVETREND` | LazyBear WaveTrend 10 / 21, signal SMA 4 |
| `ZIGZAG` | Percentage deviation zig-zag on highs/lows, default 5% |

## Examples

Both folders contain the same four programs (console applications):

| Program | Shows |
|---|---|
| `BasicIndicators` | SMA, EMA, RSI, ATR, ADX, Bollinger Bands, MACD and Stochastic printed for the last bars |
| `CandlestickScan` | Scanning data for Hammer, Engulfing, Morning Star, Three White Soldiers and Doji |
| `SmaCrossover` | A long-only SMA(10)/SMA(30) crossover back-test |
| `AdvancedIndicators` | HT_SINE, SuperTrend, Ichimoku, Keltner, ZigZag and Kicking patterns |

**Delphi** - open `examples/delphi/<Name>.dpr` and press F9. The projects reference `..\..\src` directly.

**Free Pascal**

```
cd examples/freepascal
fpc -Fu../../src BasicIndicators.lpr
./BasicIndicators
```

The examples use `GenerateSampleOHLCV` (a reproducible random walk), so they run without any data file.

## Project layout

```
QuantTech4D/
  LICENSE                      BSD 3-Clause license
  NOTICE                       TA-Lib attribution and original license text
  README.md
  src/
    QuantTech4D.inc            compiler directives shared by all units
    QuantTech4D.Types.pas      types, records, exception class
    QuantTech4D.Core.pas       helpers (NaN series, lookback, EMA engine, ...)
    QuantTech4D.Overlap.pas    moving averages, bands, SAR
    QuantTech4D.Momentum.pas   oscillators and directional movement
    QuantTech4D.Volatility.pas TRANGE, ATR, NATR
    QuantTech4D.Volume.pas     AD, ADOSC, OBV, CMF
    QuantTech4D.Price.pas      price transforms, Heikin-Ashi
    QuantTech4D.Statistic.pas  rolling statistics, regression
    QuantTech4D.MathOps.pas    vector math, rolling windows
    QuantTech4D.Cycle.pas      MAMA and Hilbert Transform
    QuantTech4D.Extended.pas   newer indicators
    QuantTech4D.Patterns.pas   61 candlestick patterns
    QuantTech4D.Data.pas       CSV loader, sample data, formatting
  examples/
    delphi/                    .dpr console programs
    freepascal/                .lpr console programs
```

## License and credits

Copyright (c) 2026, Shaahin Ashayeri - https://github.com/DelphiMan68

QuantTech4D is released under the **BSD 3-Clause License** (see `LICENSE`).

It is a Pascal port of the algorithms of **TA-Lib** (https://github.com/TA-Lib/ta-lib), also BSD-3-Clause.
TA-Lib's copyright notice and license text are reproduced in `NOTICE` and must accompany every
redistribution of QuantTech4D.
