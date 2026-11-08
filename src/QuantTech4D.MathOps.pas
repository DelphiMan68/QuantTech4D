{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ Math transforms, math operators and rolling window statistics.
  Names use the prefixes Vec* and Rolling* to avoid clashes with System/Math. }
unit QuantTech4D.MathOps;

{$I QuantTech4D.inc}

interface

uses
  SysUtils, Math, QuantTech4D.Types, QuantTech4D.Core;

{ ---- Vector arithmetic (TA-Lib: ADD, SUB, MULT, DIV) ---- }
function VecAdd(const A, B: TQDoubleArray): TQDoubleArray;
function VecSub(const A, B: TQDoubleArray): TQDoubleArray;
function VecMult(const A, B: TQDoubleArray): TQDoubleArray;
/// Element-wise division; division by zero yields NaN.
function VecDiv(const A, B: TQDoubleArray): TQDoubleArray;

{ ---- Vector transforms (TA-Lib: ACOS, ASIN, ATAN, CEIL, COS, COSH, EXP,
       FLOOR, LN, LOG10, SIN, SINH, SQRT, TAN, TANH).
       Out-of-domain inputs yield NaN. ---- }
function VecAcos(const A: TQDoubleArray): TQDoubleArray;
function VecAsin(const A: TQDoubleArray): TQDoubleArray;
function VecAtan(const A: TQDoubleArray): TQDoubleArray;
function VecCeil(const A: TQDoubleArray): TQDoubleArray;
function VecCos(const A: TQDoubleArray): TQDoubleArray;
function VecCosh(const A: TQDoubleArray): TQDoubleArray;
function VecExp(const A: TQDoubleArray): TQDoubleArray;
function VecFloor(const A: TQDoubleArray): TQDoubleArray;
function VecLn(const A: TQDoubleArray): TQDoubleArray;
function VecLog10(const A: TQDoubleArray): TQDoubleArray;
function VecSin(const A: TQDoubleArray): TQDoubleArray;
function VecSinh(const A: TQDoubleArray): TQDoubleArray;
function VecSqrt(const A: TQDoubleArray): TQDoubleArray;
function VecTan(const A: TQDoubleArray): TQDoubleArray;
function VecTanh(const A: TQDoubleArray): TQDoubleArray;

{ ---- Rolling windows (TA-Lib: MAX, MIN, SUM, MAXINDEX, MININDEX, MINMAX) ---- }
function RollingMax(const Data: TQDoubleArray; Period: Integer = 30): TQDoubleArray;
function RollingMin(const Data: TQDoubleArray; Period: Integer = 30): TQDoubleArray;
function RollingSum(const Data: TQDoubleArray; Period: Integer = 30): TQDoubleArray;
/// Absolute index (into Data) of the highest value in each window; -1 during warm-up.
function RollingMaxIndex(const Data: TQDoubleArray; Period: Integer = 30): TQIntArray;
/// Absolute index (into Data) of the lowest value in each window; -1 during warm-up.
function RollingMinIndex(const Data: TQDoubleArray; Period: Integer = 30): TQIntArray;
function RollingMinMax(const Data: TQDoubleArray; Period: Integer = 30): TQMinMax;
/// Indexes of the lowest and highest value in each window (TA-Lib: MINMAXINDEX).
function RollingMinMaxIndex(const Data: TQDoubleArray;
  out LowestIdx, HighestIdx: TQIntArray; Period: Integer = 30): Boolean;
/// Rolling median.
function RollingMedian(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Cumulative sum.
function CumSum(const Data: TQDoubleArray): TQDoubleArray;

implementation

type
  TUnaryFn = function(X: Double): Double;

function Binary(const A, B: TQDoubleArray; Op: Integer; const Name: string): TQDoubleArray;
var
  i: Integer;
begin
  QTCheckLength(Length(A), Length(B), Name);
  SetLength(Result, Length(A));
  for i := 0 to (Length(A) - 1) do
    case Op of
      0: Result[i] := A[i] + B[i];
      1: Result[i] := A[i] - B[i];
      2: Result[i] := A[i] * B[i];
    else
      if B[i] = 0 then Result[i] := NaN else Result[i] := A[i] / B[i];
    end;
end;

function VecAdd(const A, B: TQDoubleArray): TQDoubleArray;
begin
  Result := Binary(A, B, 0, 'VecAdd');
end;

function VecSub(const A, B: TQDoubleArray): TQDoubleArray;
begin
  Result := Binary(A, B, 1, 'VecSub');
end;

function VecMult(const A, B: TQDoubleArray): TQDoubleArray;
begin
  Result := Binary(A, B, 2, 'VecMult');
end;

function VecDiv(const A, B: TQDoubleArray): TQDoubleArray;
begin
  Result := Binary(A, B, 3, 'VecDiv');
end;

function SafeAcos(X: Double): Double;
begin
  if IsNaN(X) or (X < -1) or (X > 1) then Result := NaN else Result := ArcCos(X);
end;

function SafeAsin(X: Double): Double;
begin
  if IsNaN(X) or (X < -1) or (X > 1) then Result := NaN else Result := ArcSin(X);
end;

function SafeAtan(X: Double): Double;
begin
  if IsNaN(X) then Result := NaN else Result := ArcTan(X);
end;

function SafeCeil(X: Double): Double;
begin
  if IsNaN(X) then Result := NaN
  else if Frac(X) > 0 then Result := Int(X) + 1
  else Result := Int(X);
end;

function SafeFloor(X: Double): Double;
begin
  if IsNaN(X) then Result := NaN
  else if Frac(X) < 0 then Result := Int(X) - 1
  else Result := Int(X);
end;

function SafeCos(X: Double): Double;
begin
  if IsNaN(X) then Result := NaN else Result := Cos(X);
end;

function SafeSin(X: Double): Double;
begin
  if IsNaN(X) then Result := NaN else Result := Sin(X);
end;

function SafeTan(X: Double): Double;
begin
  if IsNaN(X) then Result := NaN else Result := Tan(X);
end;

function SafeCosh(X: Double): Double;
begin
  if IsNaN(X) then Result := NaN
  else if Abs(X) > 700 then Result := Infinity
  else Result := Cosh(X);
end;

function SafeSinh(X: Double): Double;
begin
  if IsNaN(X) then Result := NaN
  else if X > 700 then Result := Infinity
  else if X < -700 then Result := NegInfinity
  else Result := Sinh(X);
end;

function SafeTanh(X: Double): Double;
begin
  if IsNaN(X) then Result := NaN else Result := Tanh(X);
end;

function SafeExp(X: Double): Double;
begin
  if IsNaN(X) then Result := NaN
  else if X > 709 then Result := Infinity
  else Result := Exp(X);
end;

function SafeLn(X: Double): Double;
begin
  if IsNaN(X) or (X <= 0) then Result := NaN else Result := Ln(X);
end;

function SafeLog10(X: Double): Double;
begin
  if IsNaN(X) or (X <= 0) then Result := NaN else Result := Log10(X);
end;

function SafeSqrt(X: Double): Double;
begin
  if IsNaN(X) or (X < 0) then Result := NaN else Result := Sqrt(X);
end;

function MapFn(const A: TQDoubleArray; F: TUnaryFn): TQDoubleArray;
var
  i: Integer;
begin
  SetLength(Result, Length(A));
  for i := 0 to (Length(A) - 1) do
    Result[i] := F(A[i]);
end;

function VecAcos(const A: TQDoubleArray): TQDoubleArray;  begin Result := MapFn(A, SafeAcos);  end;
function VecAsin(const A: TQDoubleArray): TQDoubleArray;  begin Result := MapFn(A, SafeAsin);  end;
function VecAtan(const A: TQDoubleArray): TQDoubleArray;  begin Result := MapFn(A, SafeAtan);  end;
function VecCeil(const A: TQDoubleArray): TQDoubleArray;  begin Result := MapFn(A, SafeCeil);  end;
function VecCos(const A: TQDoubleArray): TQDoubleArray;   begin Result := MapFn(A, SafeCos);   end;
function VecCosh(const A: TQDoubleArray): TQDoubleArray;  begin Result := MapFn(A, SafeCosh);  end;
function VecExp(const A: TQDoubleArray): TQDoubleArray;   begin Result := MapFn(A, SafeExp);   end;
function VecFloor(const A: TQDoubleArray): TQDoubleArray; begin Result := MapFn(A, SafeFloor); end;
function VecLn(const A: TQDoubleArray): TQDoubleArray;    begin Result := MapFn(A, SafeLn);    end;
function VecLog10(const A: TQDoubleArray): TQDoubleArray; begin Result := MapFn(A, SafeLog10); end;
function VecSin(const A: TQDoubleArray): TQDoubleArray;   begin Result := MapFn(A, SafeSin);   end;
function VecSinh(const A: TQDoubleArray): TQDoubleArray;  begin Result := MapFn(A, SafeSinh);  end;
function VecSqrt(const A: TQDoubleArray): TQDoubleArray;  begin Result := MapFn(A, SafeSqrt);  end;
function VecTan(const A: TQDoubleArray): TQDoubleArray;   begin Result := MapFn(A, SafeTan);   end;
function VecTanh(const A: TQDoubleArray): TQDoubleArray;  begin Result := MapFn(A, SafeTanh);  end;

function RollingMax(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j: Integer;
  V: Double;
begin
  QTCheckPeriod(Period, 1, 'RollingMax');
  Result := QTNaNSeries(Length(Data));
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    V := Data[i];
    for j := i - Period + 1 to i do
      if Data[j] > V then V := Data[j];
    Result[i] := V;
  end;
end;

function RollingMin(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j: Integer;
  V: Double;
begin
  QTCheckPeriod(Period, 1, 'RollingMin');
  Result := QTNaNSeries(Length(Data));
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    V := Data[i];
    for j := i - Period + 1 to i do
      if Data[j] < V then V := Data[j];
    Result[i] := V;
  end;
end;

function RollingSum(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i: Integer;
  Sum: Double;
begin
  QTCheckPeriod(Period, 1, 'RollingSum');
  Result := QTNaNSeries(Length(Data));
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  Sum := 0;
  for i := S to S + Period - 1 do
    Sum := Sum + Data[i];
  Result[S + Period - 1] := Sum;
  for i := S + Period to (Length(Data) - 1) do
  begin
    Sum := Sum + Data[i] - Data[i - Period];
    Result[i] := Sum;
  end;
end;

function RollingMaxIndex(const Data: TQDoubleArray; Period: Integer): TQIntArray;
var
  S, i, j, Best: Integer;
begin
  QTCheckPeriod(Period, 1, 'RollingMaxIndex');
  SetLength(Result, Length(Data));
  for i := 0 to (Length(Data) - 1) do Result[i] := -1;
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    Best := i - Period + 1;
    for j := Best to i do
      if Data[j] >= Data[Best] then Best := j; // ties: most recent wins
    Result[i] := Best;
  end;
end;

function RollingMinIndex(const Data: TQDoubleArray; Period: Integer): TQIntArray;
var
  S, i, j, Best: Integer;
begin
  QTCheckPeriod(Period, 1, 'RollingMinIndex');
  SetLength(Result, Length(Data));
  for i := 0 to (Length(Data) - 1) do Result[i] := -1;
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    Best := i - Period + 1;
    for j := Best to i do
      if Data[j] <= Data[Best] then Best := j;
    Result[i] := Best;
  end;
end;

function RollingMinMax(const Data: TQDoubleArray; Period: Integer): TQMinMax;
begin
  Result.Lowest := RollingMin(Data, Period);
  Result.Highest := RollingMax(Data, Period);
end;

function RollingMinMaxIndex(const Data: TQDoubleArray;
  out LowestIdx, HighestIdx: TQIntArray; Period: Integer): Boolean;
begin
  LowestIdx := RollingMinIndex(Data, Period);
  HighestIdx := RollingMaxIndex(Data, Period);
  Result := True;
end;

function RollingMedian(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j, k: Integer;
  W: TQDoubleArray;
  T: Double;
begin
  QTCheckPeriod(Period, 1, 'RollingMedian');
  Result := QTNaNSeries(Length(Data));
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  SetLength(W, Period);
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    for j := 0 to Period - 1 do
      W[j] := Data[i - Period + 1 + j];
    for j := 1 to Period - 1 do // insertion sort
    begin
      T := W[j];
      k := j - 1;
      while (k >= 0) and (W[k] > T) do
      begin
        W[k + 1] := W[k];
        Dec(k);
      end;
      W[k + 1] := T;
    end;
    if Odd(Period) then
      Result[i] := W[Period div 2]
    else
      Result[i] := (W[Period div 2 - 1] + W[Period div 2]) / 2;
  end;
end;

function CumSum(const Data: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
  Acc: Double;
begin
  SetLength(Result, Length(Data));
  Acc := 0;
  for i := 0 to (Length(Data) - 1) do
  begin
    Acc := Acc + Data[i];
    Result[i] := Acc;
  end;
end;

end.
