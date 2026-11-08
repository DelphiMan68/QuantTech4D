{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ Volume indicators: A/D line, Chaikin oscillator, OBV, Chaikin Money Flow. }
unit QuantTech4D.Volume;

{$I QuantTech4D.inc}

interface

uses
  SysUtils, Math, QuantTech4D.Types, QuantTech4D.Core;

/// Chaikin Accumulation/Distribution line.
function AD(const High, Low, Close, Volume: TQDoubleArray): TQDoubleArray;
/// Chaikin A/D Oscillator (fast EMA - slow EMA of the A/D line).
function ADOSC(const High, Low, Close, Volume: TQDoubleArray;
  FastPeriod: Integer = 3; SlowPeriod: Integer = 10): TQDoubleArray;
/// On Balance Volume.
function OBV(const Close, Volume: TQDoubleArray): TQDoubleArray;
/// Chaikin Money Flow.
function CMF(const High, Low, Close, Volume: TQDoubleArray;
  Period: Integer = 20): TQDoubleArray;

implementation

function MFV(const High, Low, Close, Volume: TQDoubleArray; i: Integer): Double;
var
  HL: Double;
begin
  HL := High[i] - Low[i];
  if HL > 0 then
    Result := ((Close[i] - Low[i]) - (High[i] - Close[i])) / HL * Volume[i]
  else
    Result := 0;
end;

function AD(const High, Low, Close, Volume: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
  Acc: Double;
begin
  QTCheckLength(Length(High), Length(Low), 'AD');
  QTCheckLength(Length(High), Length(Close), 'AD');
  QTCheckLength(Length(High), Length(Volume), 'AD');
  SetLength(Result, Length(High));
  Acc := 0;
  for i := 0 to (Length(High) - 1) do
  begin
    Acc := Acc + MFV(High, Low, Close, Volume, i);
    Result[i] := Acc;
  end;
end;

function ADOSC(const High, Low, Close, Volume: TQDoubleArray;
  FastPeriod: Integer; SlowPeriod: Integer): TQDoubleArray;
var
  A: TQDoubleArray;
  i, T: Integer;
  FK, SK, FE, SE: Double;
begin
  QTCheckPeriod(FastPeriod, 2, 'ADOSC');
  QTCheckPeriod(SlowPeriod, 2, 'ADOSC');
  if FastPeriod > SlowPeriod then
  begin
    T := FastPeriod; FastPeriod := SlowPeriod; SlowPeriod := T;
  end;
  A := AD(High, Low, Close, Volume);
  Result := QTNaNSeries(Length(A));
  if Length(A) < SlowPeriod then Exit;
  FK := 2.0 / (FastPeriod + 1);
  SK := 2.0 / (SlowPeriod + 1);
  FE := A[0];
  SE := A[0];
  for i := 1 to (Length(A) - 1) do
  begin
    FE := FE + FK * (A[i] - FE);
    SE := SE + SK * (A[i] - SE);
    if i >= SlowPeriod - 1 then
      Result[i] := FE - SE;
  end;
end;

function OBV(const Close, Volume: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
begin
  QTCheckLength(Length(Close), Length(Volume), 'OBV');
  SetLength(Result, Length(Close));
  if Length(Close) = 0 then Exit;
  Result[0] := Volume[0];
  for i := 1 to (Length(Close) - 1) do
  begin
    if Close[i] > Close[i - 1] then Result[i] := Result[i - 1] + Volume[i]
    else if Close[i] < Close[i - 1] then Result[i] := Result[i - 1] - Volume[i]
    else Result[i] := Result[i - 1];
  end;
end;

function CMF(const High, Low, Close, Volume: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  i, j: Integer;
  SM, SV: Double;
begin
  QTCheckPeriod(Period, 1, 'CMF');
  QTCheckLength(Length(High), Length(Volume), 'CMF');
  Result := QTNaNSeries(Length(High));
  for i := Period - 1 to (Length(High) - 1) do
  begin
    SM := 0;
    SV := 0;
    for j := i - Period + 1 to i do
    begin
      SM := SM + MFV(High, Low, Close, Volume, j);
      SV := SV + Volume[j];
    end;
    if SV <> 0 then Result[i] := SM / SV else Result[i] := 0;
  end;
end;

end.
