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

uses
  SysUtils, Math,
  QuantTech4D.Types in '..\..\src\QuantTech4D.Types.pas',
  QuantTech4D.Core in '..\..\src\QuantTech4D.Core.pas',
  QuantTech4D.Overlap in '..\..\src\QuantTech4D.Overlap.pas',
  QuantTech4D.MathOps in '..\..\src\QuantTech4D.MathOps.pas',
  QuantTech4D.Price in '..\..\src\QuantTech4D.Price.pas',
  QuantTech4D.Volatility in '..\..\src\QuantTech4D.Volatility.pas',
  QuantTech4D.Volume in '..\..\src\QuantTech4D.Volume.pas',
  QuantTech4D.Statistic in '..\..\src\QuantTech4D.Statistic.pas',
  QuantTech4D.Momentum in '..\..\src\QuantTech4D.Momentum.pas',
  QuantTech4D.Cycle in '..\..\src\QuantTech4D.Cycle.pas',
  QuantTech4D.Extended in '..\..\src\QuantTech4D.Extended.pas',
  QuantTech4D.Patterns in '..\..\src\QuantTech4D.Patterns.pas',
  QuantTech4D.Data in '..\..\src\QuantTech4D.Data.pas';

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
