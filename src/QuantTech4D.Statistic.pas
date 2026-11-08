{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ Statistic functions: variance, standard deviation, beta, correlation,
  linear regression family. }
unit QuantTech4D.Statistic;

{$I QuantTech4D.inc}

interface

uses
  SysUtils, Math, QuantTech4D.Types, QuantTech4D.Core;

/// Rolling population standard deviation times NbDev (TA-Lib: STDDEV).
function StdDevRoll(const Data: TQDoubleArray; Period: Integer = 5;
  NbDev: Double = 1.0): TQDoubleArray;
/// Rolling population variance (TA-Lib: VAR).
function VarianceRoll(const Data: TQDoubleArray; Period: Integer = 5): TQDoubleArray;
/// Beta of Data1 returns regressed on Data0 returns (TA-Lib: BETA).
function BetaRoll(const Data0, Data1: TQDoubleArray; Period: Integer = 5): TQDoubleArray;
/// Pearson's correlation coefficient (TA-Lib: CORREL).
function CORREL(const Data0, Data1: TQDoubleArray; Period: Integer = 30): TQDoubleArray;
/// Linear regression value at the last bar of each window.
function LINEARREG(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Linear regression slope.
function LINEARREG_SLOPE(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Linear regression intercept (value at the first bar of the window).
function LINEARREG_INTERCEPT(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Linear regression angle in degrees.
function LINEARREG_ANGLE(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Time Series Forecast (regression projected one bar ahead).
function TSF(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;

implementation

function VarianceRoll(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  SD: TQDoubleArray;
  i: Integer;
begin
  QTCheckPeriod(Period, 1, 'VarianceRoll');
  SD := QTRollingStdDev(Data, Period);
  Result := QTNaNSeries(Length(Data));
  for i := 0 to (Length(SD) - 1) do
    if not IsNaN(SD[i]) then
      Result[i] := Sqr(SD[i]);
end;

function StdDevRoll(const Data: TQDoubleArray; Period: Integer;
  NbDev: Double): TQDoubleArray;
var
  i: Integer;
begin
  QTCheckPeriod(Period, 1, 'StdDevRoll');
  Result := QTRollingStdDev(Data, Period);
  for i := 0 to (Length(Result) - 1) do
    if not IsNaN(Result[i]) then
      Result[i] := Result[i] * NbDev;
end;

function BetaRoll(const Data0, Data1: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  n, i, j: Integer;
  X, Y: TQDoubleArray;
  Sx, Sy, Sxx, Sxy, D: Double;
begin
  QTCheckPeriod(Period, 1, 'BetaRoll');
  QTCheckLength(Length(Data0), Length(Data1), 'BetaRoll');
  n := Length(Data0);
  Result := QTNaNSeries(n);
  SetLength(X, n);
  SetLength(Y, n);
  for i := 1 to n - 1 do
  begin
    if Data0[i - 1] <> 0 then X[i] := (Data0[i] - Data0[i - 1]) / Data0[i - 1] else X[i] := 0;
    if Data1[i - 1] <> 0 then Y[i] := (Data1[i] - Data1[i - 1]) / Data1[i - 1] else Y[i] := 0;
  end;
  for i := Period to n - 1 do
  begin
    Sx := 0; Sy := 0; Sxx := 0; Sxy := 0;
    for j := i - Period + 1 to i do
    begin
      Sx := Sx + X[j];
      Sy := Sy + Y[j];
      Sxx := Sxx + X[j] * X[j];
      Sxy := Sxy + X[j] * Y[j];
    end;
    D := Period * Sxx - Sx * Sx;
    if D <> 0 then Result[i] := (Period * Sxy - Sx * Sy) / D else Result[i] := 0;
  end;
end;

function CORREL(const Data0, Data1: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  n, i, j: Integer;
  Sx, Sy, Sxx, Syy, Sxy, D: Double;
begin
  QTCheckPeriod(Period, 1, 'CORREL');
  QTCheckLength(Length(Data0), Length(Data1), 'CORREL');
  n := Length(Data0);
  Result := QTNaNSeries(n);
  for i := Period - 1 to n - 1 do
  begin
    Sx := 0; Sy := 0; Sxx := 0; Syy := 0; Sxy := 0;
    for j := i - Period + 1 to i do
    begin
      Sx := Sx + Data0[j];
      Sy := Sy + Data1[j];
      Sxx := Sxx + Data0[j] * Data0[j];
      Syy := Syy + Data1[j] * Data1[j];
      Sxy := Sxy + Data0[j] * Data1[j];
    end;
    D := (Sxx - Sx * Sx / Period) * (Syy - Sy * Sy / Period);
    if D > 0 then Result[i] := (Sxy - Sx * Sy / Period) / Sqrt(D) else Result[i] := 0;
  end;
end;

// Mode: 0 = value at last bar, 1 = slope, 2 = intercept, 3 = angle, 4 = forecast.
function LinReg(const Data: TQDoubleArray; Period: Integer; Mode: Integer;
  const Name: string): TQDoubleArray;
var
  S, i, j: Integer;
  SumX, SumXX, Div_, SumY, SumXY, M, B: Double;
begin
  QTCheckPeriod(Period, 2, Name);
  Result := QTNaNSeries(Length(Data));
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  SumX := Period * (Period - 1) / 2.0;
  SumXX := (Period - 1) * Period * (2 * Period - 1) / 6.0;
  Div_ := Period * SumXX - SumX * SumX;
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    SumY := 0;
    SumXY := 0;
    for j := 0 to Period - 1 do // x = 0 (oldest) .. Period-1 (newest)
    begin
      SumY := SumY + Data[i - Period + 1 + j];
      SumXY := SumXY + j * Data[i - Period + 1 + j];
    end;
    M := (Period * SumXY - SumX * SumY) / Div_;
    B := (SumY - M * SumX) / Period;
    case Mode of
      0: Result[i] := B + M * (Period - 1);
      1: Result[i] := M;
      2: Result[i] := B;
      3: Result[i] := ArcTan(M) * 180 / Pi;
    else
      Result[i] := B + M * Period;
    end;
  end;
end;

function LINEARREG(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  Result := LinReg(Data, Period, 0, 'LINEARREG');
end;

function LINEARREG_SLOPE(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  Result := LinReg(Data, Period, 1, 'LINEARREG_SLOPE');
end;

function LINEARREG_INTERCEPT(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  Result := LinReg(Data, Period, 2, 'LINEARREG_INTERCEPT');
end;

function LINEARREG_ANGLE(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  Result := LinReg(Data, Period, 3, 'LINEARREG_ANGLE');
end;

function TSF(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  Result := LinReg(Data, Period, 4, 'TSF');
end;

end.
