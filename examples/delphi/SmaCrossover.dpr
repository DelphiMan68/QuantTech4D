{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

program SmaCrossover;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  QuantTech4D.Overlap in '..\..\src\QuantTech4D.Overlap.pas',
  QuantTech4D.MathOps in '..\..\src\QuantTech4D.MathOps.pas',
  QuantTech4D.Price in '..\..\src\QuantTech4D.Price.pas',
  QuantTech4D.Volatility in '..\..\src\QuantTech4D.Volatility.pas',
  QuantTech4D.Volume in '..\..\src\QuantTech4D.Volume.pas',
  QuantTech4D.Statistic in '..\..\src\QuantTech4D.Statistic.pas',
  QuantTech4D.Momentum in '..\..\src\QuantTech4D.Momentum.pas',
  QuantTech4D.Patterns in '..\..\src\QuantTech4D.Patterns.pas',
  QuantTech4D.Data in '..\..\src\QuantTech4D.Data.pas',
  QuantTech4D.Core in '..\..\src\QuantTech4D.Core.pas',
  QuantTech4D.Cycle in '..\..\src\QuantTech4D.Cycle.pas',
  QuantTech4D.Types in '..\..\src\QuantTech4D.Types.pas';

var
  D: TQOHLCV;
  Fast, Slow: TQDoubleArray;
  i, Pos, Trades: Integer;
  Equity, EntryPrice: Double;
begin
  // Simple long-only SMA(10)/SMA(30) crossover back-test on sample data.
  D := GenerateSampleOHLCV(1000, 3);
  Fast := SMA(D.Close, 10);
  Slow := SMA(D.Close, 30);
  Equity := 1.0;
  Pos := 0;
  Trades := 0;
  EntryPrice := 0;
  for i := 31 to D.Count - 1 do
  begin
    if (Pos = 0) and (Fast[i - 1] <= Slow[i - 1]) and (Fast[i] > Slow[i]) then
    begin
      Pos := 1;
      EntryPrice := D.Close[i];
    end
    else if (Pos = 1) and (Fast[i - 1] >= Slow[i - 1]) and (Fast[i] < Slow[i]) then
    begin
      Equity := Equity * D.Close[i] / EntryPrice;
      Pos := 0;
      Inc(Trades);
    end;
  end;
  WriteLn('Closed trades : ', Trades);
  WriteLn('Final equity  : ', QTFmt(Equity, 4), ' (starting at 1.0)');
  ReadLn;
end.
