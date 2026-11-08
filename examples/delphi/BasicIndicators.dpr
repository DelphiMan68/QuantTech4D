{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

program BasicIndicators;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  QuantTech4D.Types in '..\..\src\QuantTech4D.Types.pas',
  QuantTech4D.Core in '..\..\src\QuantTech4D.Core.pas',
  QuantTech4D.Overlap in '..\..\src\QuantTech4D.Overlap.pas',
  QuantTech4D.MathOps in '..\..\src\QuantTech4D.MathOps.pas',
  QuantTech4D.Price in '..\..\src\QuantTech4D.Price.pas',
  QuantTech4D.Volatility in '..\..\src\QuantTech4D.Volatility.pas',
  QuantTech4D.Volume in '..\..\src\QuantTech4D.Volume.pas',
  QuantTech4D.Statistic in '..\..\src\QuantTech4D.Statistic.pas',
  QuantTech4D.Momentum in '..\..\src\QuantTech4D.Momentum.pas',
  QuantTech4D.Patterns in '..\..\src\QuantTech4D.Patterns.pas',
  QuantTech4D.Data in '..\..\src\QuantTech4D.Data.pas',
  QuantTech4D.Cycle in '..\..\src\QuantTech4D.Cycle.pas';

var
  D: TQOHLCV;
  S20, E20, R14, A14, AX: TQDoubleArray;
  BB: TQBBands;
  M: TQMACD;
  ST: TQStoch;
  i, n: Integer;
begin
  // 1. Get data (use LoadOHLCVFromCSV('prices.csv') for real data).
  D := GenerateSampleOHLCV(200);
  n := D.Count;

  // 2. Every indicator is one call; defaults match TA-Lib.
  S20 := SMA(D.Close, 20);
  E20 := EMA(D.Close, 20);
  R14 := RSI(D.Close);
  A14 := ATR(D.High, D.Low, D.Close);
  AX := ADX(D.High, D.Low, D.Close);
  BB := BBANDS(D.Close, 20, 2.0, 2.0);
  M := MACD(D.Close);
  ST := STOCH(D.High, D.Low, D.Close);

  // 3. Outputs have the same length as the input; warm-up values are NaN.
  WriteLn('Bar   Close     SMA20     EMA20     RSI14     ATR14     ADX14   BB.Upper  MACD.Hist  Stoch.K');
  for i := n - 8 to n - 1 do
    WriteLn(Format('%3d %9s %9s %9s %9s %9s %9s %9s %10s %8s',
      [i, QTFmt(D.Close[i], 2), QTFmt(S20[i], 2), QTFmt(E20[i], 2), QTFmt(R14[i], 2),
       QTFmt(A14[i], 3), QTFmt(AX[i], 2), QTFmt(BB.Upper[i], 2),
       QTFmt(M.Hist[i], 4), QTFmt(ST.K[i], 2)]));
  WriteLn;
  WriteLn('SMA(20) lookback = ', QTLookback(S20), ' bars');
  ReadLn;
end.
