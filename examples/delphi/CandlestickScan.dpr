{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

program CandlestickScan;

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
  Doji, Hammer, Engulf, Morning, Soldiers: TQIntArray;
  i, Found: Integer;
begin
  D := GenerateSampleOHLCV(500, 7);
  Doji := CDLDOJI(D);
  Hammer := CDLHAMMER(D);
  Engulf := CDLENGULFING(D);
  Morning := CDLMORNINGSTAR(D);
  Soldiers := CDL3WHITESOLDIERS(D);

  Found := 0;
  for i := 0 to D.Count - 1 do
    if (Hammer[i] <> 0) or (Engulf[i] <> 0) or (Morning[i] <> 0) or (Soldiers[i] <> 0) then
    begin
      Inc(Found);
      if Found <= 15 then
        WriteLn(Format('Bar %3d  Hammer=%4d  Engulfing=%4d  MorningStar=%4d  3WhiteSoldiers=%4d',
          [i, Hammer[i], Engulf[i], Morning[i], Soldiers[i]]));
    end;
  WriteLn('Bars with at least one signal: ', Found);
  Found := 0;
  for i := 0 to D.Count - 1 do
    if Doji[i] <> 0 then Inc(Found);
  WriteLn('Doji count: ', Found);
  ReadLn;
end.
