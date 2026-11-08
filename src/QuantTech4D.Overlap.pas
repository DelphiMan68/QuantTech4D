{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ Overlap studies: moving averages, Bollinger Bands, Parabolic SAR, etc.
  Every function returns an array with the same length as its input.
  Leading elements that cannot be computed (the lookback) are NaN. }
unit QuantTech4D.Overlap;

{$I QuantTech4D.inc}

interface

uses
  SysUtils, Math, QuantTech4D.Types, QuantTech4D.Core, QuantTech4D.Cycle;

/// Simple Moving Average.
function SMA(const Data: TQDoubleArray; Period: Integer = 30): TQDoubleArray;
/// Exponential Moving Average (seeded with an SMA, like TA-Lib).
function EMA(const Data: TQDoubleArray; Period: Integer = 30): TQDoubleArray;
/// Weighted Moving Average (linear weights 1..Period).
function WMA(const Data: TQDoubleArray; Period: Integer = 30): TQDoubleArray;
/// Double Exponential Moving Average.
function DEMA(const Data: TQDoubleArray; Period: Integer = 30): TQDoubleArray;
/// Triple Exponential Moving Average.
function TEMA(const Data: TQDoubleArray; Period: Integer = 30): TQDoubleArray;
/// Triangular Moving Average.
function TRIMA(const Data: TQDoubleArray; Period: Integer = 30): TQDoubleArray;
/// Kaufman Adaptive Moving Average.
function KAMA(const Data: TQDoubleArray; Period: Integer = 30;
  FastLimit: Integer = 2; SlowLimit: Integer = 30): TQDoubleArray;
/// Triple Exponential Moving Average (T3, Tillson).
function T3(const Data: TQDoubleArray; Period: Integer = 5;
  VFactor: Double = 0.7): TQDoubleArray;
/// Generic moving average selected by type.
function MA(const Data: TQDoubleArray; Period: Integer = 30;
  MAType: TQMAType = maSMA): TQDoubleArray;
/// Hull Moving Average.
function HMA(const Data: TQDoubleArray; Period: Integer = 20): TQDoubleArray;
/// Zero-Lag Exponential Moving Average.
function ZLEMA(const Data: TQDoubleArray; Period: Integer = 20): TQDoubleArray;
/// Wilder's smoothed moving average (alpha = 1/Period).
function RMA(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Volume Weighted Moving Average.
function VWMA(const Price, Volume: TQDoubleArray; Period: Integer = 20): TQDoubleArray;
/// Bollinger Bands (population standard deviation, like TA-Lib).
function BBANDS(const Data: TQDoubleArray; Period: Integer = 5;
  NbDevUp: Double = 2.0; NbDevDn: Double = 2.0; MAType: TQMAType = maSMA): TQBBands;
/// MidPoint over period: (highest + lowest) / 2 of one series.
function MIDPOINT(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Midpoint price over period: (highest high + lowest low) / 2.
function MIDPRICE(const High, Low: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Parabolic SAR.
function SAR(const High, Low: TQDoubleArray; Acceleration: Double = 0.02;
  Maximum: Double = 0.2): TQDoubleArray;

implementation

function SMA(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i: Integer;
  Sum: Double;
begin
  QTCheckPeriod(Period, 1, 'SMA');
  Result := QTNaNSeries(Length(Data));
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then
    Exit;
  Sum := 0;
  for i := S to S + Period - 1 do
    Sum := Sum + Data[i];
  Result[S + Period - 1] := Sum / Period;
  for i := S + Period to (Length(Data) - 1) do
  begin
    Sum := Sum + Data[i] - Data[i - Period];
    Result[i] := Sum / Period;
  end;
end;

function EMA(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  QTCheckPeriod(Period, 1, 'EMA');
  Result := QTEMA(Data, Period, 2.0 / (Period + 1));
end;

function WMA(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j: Integer;
  Sum, Divisor: Double;
begin
  QTCheckPeriod(Period, 1, 'WMA');
  Result := QTNaNSeries(Length(Data));
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then
    Exit;
  Divisor := Period * (Period + 1) / 2.0;
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    Sum := 0;
    for j := 0 to Period - 1 do
      Sum := Sum + Data[i - Period + 1 + j] * (j + 1);
    Result[i] := Sum / Divisor;
  end;
end;

function DEMA(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  E1, E2: TQDoubleArray;
  i: Integer;
begin
  QTCheckPeriod(Period, 1, 'DEMA');
  E1 := EMA(Data, Period);
  E2 := EMA(E1, Period);
  Result := QTNaNSeries(Length(Data));
  for i := 0 to (Length(Data) - 1) do
    if not IsNaN(E2[i]) then
      Result[i] := 2 * E1[i] - E2[i];
end;

function TEMA(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  E1, E2, E3: TQDoubleArray;
  i: Integer;
begin
  QTCheckPeriod(Period, 1, 'TEMA');
  E1 := EMA(Data, Period);
  E2 := EMA(E1, Period);
  E3 := EMA(E2, Period);
  Result := QTNaNSeries(Length(Data));
  for i := 0 to (Length(Data) - 1) do
    if not IsNaN(E3[i]) then
      Result[i] := 3 * E1[i] - 3 * E2[i] + E3[i];
end;

function TRIMA(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  N1, N2: Integer;
begin
  QTCheckPeriod(Period, 1, 'TRIMA');
  if Odd(Period) then
  begin
    N1 := (Period + 1) div 2;
    N2 := N1;
  end
  else
  begin
    N1 := Period div 2;
    N2 := N1 + 1;
  end;
  Result := SMA(SMA(Data, N1), N2);
end;

function KAMA(const Data: TQDoubleArray; Period: Integer; FastLimit: Integer;
  SlowLimit: Integer): TQDoubleArray;
var
  n, S, i, j: Integer;
  SumROC, PeriodROC, ER, SC, Prev, FastSC, SlowSC: Double;
begin
  QTCheckPeriod(Period, 2, 'KAMA');
  n := Length(Data);
  Result := QTNaNSeries(n);
  S := QTFirstValid(Data);
  if (S < 0) or (n - S <= Period) then
    Exit;
  FastSC := 2.0 / (FastLimit + 1);
  SlowSC := 2.0 / (SlowLimit + 1);
  SumROC := 0;
  for j := S + 1 to S + Period do
    SumROC := SumROC + Abs(Data[j] - Data[j - 1]);
  Prev := Data[S + Period - 1];
  for i := S + Period to n - 1 do
  begin
    PeriodROC := Abs(Data[i] - Data[i - Period]);
    if SumROC <= PeriodROC then
      ER := 1.0
    else
      ER := PeriodROC / SumROC;
    SC := Sqr(ER * (FastSC - SlowSC) + SlowSC);
    Prev := Prev + SC * (Data[i] - Prev);
    Result[i] := Prev;
    if i < n - 1 then
      SumROC := SumROC + Abs(Data[i + 1] - Data[i])
                       - Abs(Data[i - Period + 1] - Data[i - Period]);
  end;
end;

function T3(const Data: TQDoubleArray; Period: Integer; VFactor: Double): TQDoubleArray;
var
  E1, E2, E3, E4, E5, E6: TQDoubleArray;
  a, a2, a3, c1, c2, c3, c4: Double;
  i: Integer;
begin
  QTCheckPeriod(Period, 2, 'T3');
  E1 := EMA(Data, Period);
  E2 := EMA(E1, Period);
  E3 := EMA(E2, Period);
  E4 := EMA(E3, Period);
  E5 := EMA(E4, Period);
  E6 := EMA(E5, Period);
  a := VFactor;
  a2 := a * a;
  a3 := a2 * a;
  c1 := -a3;
  c2 := 3 * a2 + 3 * a3;
  c3 := -6 * a2 - 3 * a - 3 * a3;
  c4 := 1 + 3 * a + a3 + 3 * a2;
  Result := QTNaNSeries(Length(Data));
  for i := 0 to (Length(Data) - 1) do
    if not IsNaN(E6[i]) then
      Result[i] := c1 * E6[i] + c2 * E5[i] + c3 * E4[i] + c4 * E3[i];
end;

function MA(const Data: TQDoubleArray; Period: Integer; MAType: TQMAType): TQDoubleArray;
begin
  QTCheckPeriod(Period, 1, 'MA');
  if Period = 1 then
  begin
    Result := Copy(Data, 0, Length(Data));
    Exit;
  end;
  case MAType of
    maSMA:   Result := SMA(Data, Period);
    maEMA:   Result := EMA(Data, Period);
    maWMA:   Result := WMA(Data, Period);
    maDEMA:  Result := DEMA(Data, Period);
    maTEMA:  Result := TEMA(Data, Period);
    maTRIMA: Result := TRIMA(Data, Period);
    maKAMA:  Result := KAMA(Data, Period);
    maT3:    Result := T3(Data, Period);
    maMAMA:  Result := MAMA(Data).Mama; // Period is ignored (TA-Lib behaviour)
  end;
end;

function HMA(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  W1, W2, Diff: TQDoubleArray;
  Half, Root, i: Integer;
begin
  QTCheckPeriod(Period, 2, 'HMA');
  Half := Max(Period div 2, 1);
  Root := Max(Round(Sqrt(Period)), 1);
  W1 := WMA(Data, Half);
  W2 := WMA(Data, Period);
  Diff := QTNaNSeries(Length(Data));
  for i := 0 to (Length(Data) - 1) do
    if not IsNaN(W2[i]) then
      Diff[i] := 2 * W1[i] - W2[i];
  Result := WMA(Diff, Root);
end;

function ZLEMA(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  Lag, i: Integer;
  Adj: TQDoubleArray;
begin
  QTCheckPeriod(Period, 2, 'ZLEMA');
  Lag := (Period - 1) div 2;
  Adj := QTNaNSeries(Length(Data));
  for i := Lag to (Length(Data) - 1) do
    Adj[i] := Data[i] + (Data[i] - Data[i - Lag]);
  Result := EMA(Adj, Period);
end;

function RMA(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  QTCheckPeriod(Period, 1, 'RMA');
  Result := QTEMA(Data, Period, 1.0 / Period);
end;

function VWMA(const Price, Volume: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  i, j: Integer;
  SumPV, SumV: Double;
begin
  QTCheckPeriod(Period, 1, 'VWMA');
  QTCheckLength(Length(Price), Length(Volume), 'VWMA');
  Result := QTNaNSeries(Length(Price));
  for i := Period - 1 to (Length(Price) - 1) do
  begin
    SumPV := 0;
    SumV := 0;
    for j := i - Period + 1 to i do
    begin
      SumPV := SumPV + Price[j] * Volume[j];
      SumV := SumV + Volume[j];
    end;
    if SumV <> 0 then
      Result[i] := SumPV / SumV
    else
      Result[i] := 0;
  end;
end;

function BBANDS(const Data: TQDoubleArray; Period: Integer; NbDevUp: Double;
  NbDevDn: Double; MAType: TQMAType): TQBBands;
var
  SD: TQDoubleArray;
  i: Integer;
begin
  QTCheckPeriod(Period, 2, 'BBANDS');
  Result.Middle := MA(Data, Period, MAType);
  SD := QTRollingStdDev(Data, Period);
  Result.Upper := QTNaNSeries(Length(Data));
  Result.Lower := QTNaNSeries(Length(Data));
  for i := 0 to (Length(Data) - 1) do
    if (not IsNaN(Result.Middle[i])) and (not IsNaN(SD[i])) then
    begin
      Result.Upper[i] := Result.Middle[i] + NbDevUp * SD[i];
      Result.Lower[i] := Result.Middle[i] - NbDevDn * SD[i];
    end;
end;

function MIDPOINT(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j: Integer;
  Hi, Lo: Double;
begin
  QTCheckPeriod(Period, 2, 'MIDPOINT');
  Result := QTNaNSeries(Length(Data));
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then
    Exit;
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    Hi := Data[i];
    Lo := Data[i];
    for j := i - Period + 1 to i do
    begin
      if Data[j] > Hi then Hi := Data[j];
      if Data[j] < Lo then Lo := Data[j];
    end;
    Result[i] := (Hi + Lo) / 2;
  end;
end;

function MIDPRICE(const High, Low: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  i, j: Integer;
  Hi, Lo: Double;
begin
  QTCheckPeriod(Period, 2, 'MIDPRICE');
  QTCheckLength(Length(High), Length(Low), 'MIDPRICE');
  Result := QTNaNSeries(Length(High));
  for i := Period - 1 to Length(High) - 1 do
  begin
    Hi := High[i];
    Lo := Low[i];
    for j := i - Period + 1 to i do
    begin
      if High[j] > Hi then Hi := High[j];
      if Low[j] < Lo then Lo := Low[j];
    end;
    Result[i] := (Hi + Lo) / 2;
  end;
end;

function SAR(const High, Low: TQDoubleArray; Acceleration: Double;
  Maximum: Double): TQDoubleArray;
var
  n, i: Integer;
  IsLong: Boolean;
  AF, EP, SarV, NewHigh, NewLow, PrevHigh, PrevLow, DiffP, DiffM, MinusDM: Double;
begin
  QTCheckLength(Length(High), Length(Low), 'SAR');
  n := Length(High);
  Result := QTNaNSeries(n);
  if n < 2 then
    Exit;
  AF := Acceleration;
  if AF > Maximum then
    AF := Maximum;
  // Initial direction: short if MINUS_DM(1) > 0, otherwise long.
  DiffP := High[1] - High[0];
  DiffM := Low[0] - Low[1];
  if (DiffM > 0) and (DiffM > DiffP) then
    MinusDM := DiffM
  else
    MinusDM := 0;
  IsLong := not (MinusDM > 0);
  NewHigh := High[0];
  NewLow := Low[0];
  if IsLong then
  begin
    EP := High[1];
    SarV := Low[0];
  end
  else
  begin
    EP := Low[1];
    SarV := High[0];
  end;
  for i := 1 to n - 1 do
  begin
    PrevLow := NewLow;
    PrevHigh := NewHigh;
    NewLow := Low[i];
    NewHigh := High[i];
    if IsLong then
    begin
      if NewLow <= SarV then
      begin // reversal: long -> short
        IsLong := False;
        SarV := EP;
        if SarV < PrevHigh then SarV := PrevHigh;
        if SarV < NewHigh then SarV := NewHigh;
        Result[i] := SarV;
        AF := Acceleration;
        EP := NewLow;
        SarV := SarV + AF * (EP - SarV);
        if SarV < PrevHigh then SarV := PrevHigh;
        if SarV < NewHigh then SarV := NewHigh;
      end
      else
      begin
        Result[i] := SarV;
        if NewHigh > EP then
        begin
          EP := NewHigh;
          AF := AF + Acceleration;
          if AF > Maximum then AF := Maximum;
        end;
        SarV := SarV + AF * (EP - SarV);
        if SarV > PrevLow then SarV := PrevLow;
        if SarV > NewLow then SarV := NewLow;
      end;
    end
    else
    begin
      if NewHigh >= SarV then
      begin // reversal: short -> long
        IsLong := True;
        SarV := EP;
        if SarV > PrevLow then SarV := PrevLow;
        if SarV > NewLow then SarV := NewLow;
        Result[i] := SarV;
        AF := Acceleration;
        EP := NewHigh;
        SarV := SarV + AF * (EP - SarV);
        if SarV > PrevLow then SarV := PrevLow;
        if SarV > NewLow then SarV := NewLow;
      end
      else
      begin
        Result[i] := SarV;
        if NewLow < EP then
        begin
          EP := NewLow;
          AF := AF + Acceleration;
          if AF > Maximum then AF := Maximum;
        end;
        SarV := SarV + AF * (EP - SarV);
        if SarV < PrevHigh then SarV := PrevHigh;
        if SarV < NewHigh then SarV := NewHigh;
      end;
    end;
  end;
end;

end.
