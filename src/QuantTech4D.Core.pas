{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ Shared helpers used by all indicator units. }
unit QuantTech4D.Core;

{$I QuantTech4D.inc}

interface

uses
  SysUtils, Math, QuantTech4D.Types;

/// Returns an array of N elements, all set to NaN.
function QTNaNSeries(N: Integer): TQDoubleArray;

/// Index of the first non-NaN element, or -1 if there is none.
function QTFirstValid(const X: TQDoubleArray): Integer;

/// Number of leading NaN values in an indicator output (its "lookback").
function QTLookback(const X: TQDoubleArray): Integer;

/// Raises EQuantTechError when Period < MinPeriod.
procedure QTCheckPeriod(Period, MinPeriod: Integer; const FuncName: string);

/// Raises EQuantTechError when two input arrays differ in length.
procedure QTCheckLength(A, B: Integer; const FuncName: string);

/// EMA whose first value (an SMA seed) is placed at SeedIdx.
/// The seed is the average of X[SeedIdx-Period+1 .. SeedIdx].
function QTEMAAt(const X: TQDoubleArray; Period: Integer; K: Double;
  SeedIdx: Integer): TQDoubleArray;

/// EMA seeded at the first valid index + Period - 1 (TA-Lib classic behaviour).
function QTEMA(const X: TQDoubleArray; Period: Integer; K: Double): TQDoubleArray;

/// Rolling population standard deviation (divides by N, like TA-Lib).
function QTRollingStdDev(const X: TQDoubleArray; Period: Integer): TQDoubleArray;

implementation

function QTNaNSeries(N: Integer): TQDoubleArray;
var
  i: Integer;
begin
  SetLength(Result, N);
  for i := 0 to N - 1 do
    Result[i] := NaN;
end;

function QTFirstValid(const X: TQDoubleArray): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to (Length(X) - 1) do
    if not IsNaN(X[i]) then
    begin
      Result := i;
      Exit;
    end;
end;

function QTLookback(const X: TQDoubleArray): Integer;
begin
  Result := QTFirstValid(X);
  if Result < 0 then
    Result := Length(X);
end;

procedure QTCheckPeriod(Period, MinPeriod: Integer; const FuncName: string);
begin
  if Period < MinPeriod then
    raise EQuantTechError.CreateFmt('%s: period must be >= %d (got %d)',
      [FuncName, MinPeriod, Period]);
end;

procedure QTCheckLength(A, B: Integer; const FuncName: string);
begin
  if A <> B then
    raise EQuantTechError.CreateFmt('%s: input arrays must have equal length (%d <> %d)',
      [FuncName, A, B]);
end;

function QTEMAAt(const X: TQDoubleArray; Period: Integer; K: Double;
  SeedIdx: Integer): TQDoubleArray;
var
  i: Integer;
  Sum, Prev: Double;
begin
  Result := QTNaNSeries(Length(X));
  if (SeedIdx - Period + 1 < 0) or (SeedIdx > (Length(X) - 1)) then
    Exit;
  Sum := 0;
  for i := SeedIdx - Period + 1 to SeedIdx do
    Sum := Sum + X[i];
  Prev := Sum / Period;
  Result[SeedIdx] := Prev;
  for i := SeedIdx + 1 to (Length(X) - 1) do
  begin
    Prev := Prev + K * (X[i] - Prev);
    Result[i] := Prev;
  end;
end;

function QTEMA(const X: TQDoubleArray; Period: Integer; K: Double): TQDoubleArray;
var
  S: Integer;
begin
  S := QTFirstValid(X);
  if S < 0 then
  begin
    Result := QTNaNSeries(Length(X));
    Exit;
  end;
  Result := QTEMAAt(X, Period, K, S + Period - 1);
end;

function QTRollingStdDev(const X: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j: Integer;
  Mean, Acc: Double;
begin
  Result := QTNaNSeries(Length(X));
  S := QTFirstValid(X);
  if (S < 0) or (Length(X) - S < Period) then
    Exit;
  for i := S + Period - 1 to (Length(X) - 1) do
  begin
    Mean := 0;
    for j := i - Period + 1 to i do
      Mean := Mean + X[j];
    Mean := Mean / Period;
    Acc := 0;
    for j := i - Period + 1 to i do
      Acc := Acc + Sqr(X[j] - Mean);
    Result[i] := Sqrt(Acc / Period);
  end;
end;

end.
