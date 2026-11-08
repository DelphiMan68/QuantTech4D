{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

program AdvancedIndicators;

{$APPTYPE CONSOLE}

{$mode delphi}

{ Build: fpc -Fu../../src AdvancedIndicators.lpr }

uses
  SysUtils, Math,
  QuantTech4D.Types,
  QuantTech4D.Core,
  QuantTech4D.Overlap,
  QuantTech4D.MathOps,
  QuantTech4D.Price,
  QuantTech4D.Volatility,
  QuantTech4D.Volume,
  QuantTech4D.Statistic,
  QuantTech4D.Momentum,
  QuantTech4D.Cycle,
  QuantTech4D.Extended,
  QuantTech4D.Patterns,
  QuantTech4D.Data;

var
  D: TQOHLCV;
  Sine: TQHTSine;
  ST, Pivots: TQDoubleArray;
  SuperT: TQPair;
  Ich: TQIchimoku;
  Kelt: TQBBands;
  Patt: TQIntArray;
  i, n, Found: Integer;
begin
  D := GenerateSampleOHLCV(300, 11);
  n := D.Count;

  // Cycle indicators (Hilbert Transform)
  Sine := HT_SINE(D.Close);
  // Trend / channel indicators
  SuperT := SUPERTREND(D.High, D.Low, D.Close, 10, 3.0);
  Ich := ICHIMOKU(D.High, D.Low, D.Close);
  Kelt := KC(D.High, D.Low, D.Close);
  Pivots := ZIGZAG(D.High, D.Low, 5.0);

  WriteLn('Bar  Close   HT_Sine  LeadSine  SuperTrend  Dir  Tenkan   Kijun  KC.Upper');
  for i := n - 6 to n - 1 do
    WriteLn(Format('%3d %7s %8s %9s %11s %4s %7s %7s %9s',
      [i, QTFmt(D.Close[i], 2), QTFmt(Sine.Sine[i], 3), QTFmt(Sine.LeadSine[i], 3),
       QTFmt(SuperT.First[i], 2), QTFmt(SuperT.Second[i], 0), QTFmt(Ich.Tenkan[i], 2),
       QTFmt(Ich.Kijun[i], 2), QTFmt(Kelt.Upper[i], 2)]));

  Found := 0;
  for i := 0 to n - 1 do
    if not IsNaN(Pivots[i]) then Inc(Found);
  WriteLn('ZigZag pivots (5%): ', Found);

  // Every one of the 61 TA-Lib candlestick patterns is available.
  Patt := CDLKICKING(D);
  Found := 0;
  for i := 0 to n - 1 do
    if Patt[i] <> 0 then Inc(Found);
  WriteLn('Kicking patterns found: ', Found);
  ReadLn;
end.
