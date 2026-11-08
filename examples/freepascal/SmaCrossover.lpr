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

{$mode delphi}

{ Build: fpc -Fu../../src SmaCrossover.lpr }

uses
  SysUtils,
  QuantTech4D.Types,
  QuantTech4D.Core,
  QuantTech4D.Overlap,
  QuantTech4D.MathOps,
  QuantTech4D.Price,
  QuantTech4D.Volatility,
  QuantTech4D.Volume,
  QuantTech4D.Statistic,
  QuantTech4D.Momentum,
  QuantTech4D.Patterns,
  QuantTech4D.Data;

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
