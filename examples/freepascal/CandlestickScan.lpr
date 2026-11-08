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

{$mode delphi}

{ Build: fpc -Fu../../src CandlestickScan.lpr }

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
