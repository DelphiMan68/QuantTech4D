{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ Volatility indicators: True Range, ATR, NATR. }
unit QuantTech4D.Volatility;

{$I QuantTech4D.inc}

interface

uses
  SysUtils, Math, QuantTech4D.Types, QuantTech4D.Core;

/// True Range. The first element is NaN (needs the previous close).
function TRANGE(const High, Low, Close: TQDoubleArray): TQDoubleArray;
/// Average True Range (Wilder smoothing, seeded with the mean of the first TRs).
function ATR(const High, Low, Close: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Normalized ATR: ATR / Close * 100.
function NATR(const High, Low, Close: TQDoubleArray; Period: Integer = 14): TQDoubleArray;

implementation

function TRANGE(const High, Low, Close: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
  T, V: Double;
begin
  QTCheckLength(Length(High), Length(Low), 'TRANGE');
  QTCheckLength(Length(High), Length(Close), 'TRANGE');
  Result := QTNaNSeries(Length(High));
  for i := 1 to (Length(High) - 1) do
  begin
    T := High[i] - Low[i];
    V := Abs(High[i] - Close[i - 1]);
    if V > T then T := V;
    V := Abs(Low[i] - Close[i - 1]);
    if V > T then T := V;
    Result[i] := T;
  end;
end;

function ATR(const High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  TR: TQDoubleArray;
  n, i: Integer;
  Prev: Double;
begin
  QTCheckPeriod(Period, 1, 'ATR');
  TR := TRANGE(High, Low, Close);
  n := Length(High);
  Result := QTNaNSeries(n);
  if n <= Period then Exit;
  Prev := 0;
  for i := 1 to Period do
    Prev := Prev + TR[i];
  Prev := Prev / Period;
  Result[Period] := Prev;
  for i := Period + 1 to n - 1 do
  begin
    Prev := (Prev * (Period - 1) + TR[i]) / Period;
    Result[i] := Prev;
  end;
end;

function NATR(const High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  A: TQDoubleArray;
  i: Integer;
begin
  A := ATR(High, Low, Close, Period);
  Result := QTNaNSeries(Length(A));
  for i := 0 to (Length(A) - 1) do
    if not IsNaN(A[i]) then
      if Close[i] <> 0 then Result[i] := A[i] / Close[i] * 100
      else Result[i] := 0;
end;

end.
