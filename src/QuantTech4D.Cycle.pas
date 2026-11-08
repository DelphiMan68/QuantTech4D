{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ Cycle indicators based on John Ehlers' Hilbert Transform:
  MAMA/FAMA, HT_TRENDLINE, HT_DCPERIOD, HT_DCPHASE, HT_PHASOR, HT_SINE,
  HT_TRENDMODE. They share one state machine (WMA price smoother + even/odd
  Hilbert transformer), exactly like TA-Lib's C implementation.
  Lookbacks: MAMA 32, HT_DCPERIOD 32, HT_PHASOR 32, others 63. }
unit QuantTech4D.Cycle;

{$I QuantTech4D.inc}

interface

uses
  SysUtils, Math, QuantTech4D.Types, QuantTech4D.Core;

type
  TQMAMA = record
    Mama, Fama: TQDoubleArray;
  end;

  TQPhasor = record
    InPhase, Quadrature: TQDoubleArray;
  end;

  TQHTSine = record
    Sine, LeadSine: TQDoubleArray;
  end;

/// MESA Adaptive Moving Average and its companion FAMA.
function MAMA(const Data: TQDoubleArray; FastLimit: Double = 0.5;
  SlowLimit: Double = 0.05): TQMAMA;
/// Hilbert Transform - Instantaneous Trendline.
function HT_TRENDLINE(const Data: TQDoubleArray): TQDoubleArray;
/// Hilbert Transform - Dominant Cycle Period.
function HT_DCPERIOD(const Data: TQDoubleArray): TQDoubleArray;
/// Hilbert Transform - Dominant Cycle Phase.
function HT_DCPHASE(const Data: TQDoubleArray): TQDoubleArray;
/// Hilbert Transform - Phasor Components (in-phase and quadrature).
function HT_PHASOR(const Data: TQDoubleArray): TQPhasor;
/// Hilbert Transform - SineWave (sine and lead sine).
function HT_SINE(const Data: TQDoubleArray): TQHTSine;
/// Hilbert Transform - Trend vs Cycle Mode: 1 = trend, 0 = cycle (0 in warm-up).
function HT_TRENDMODE(const Data: TQDoubleArray): TQIntArray;

implementation

type
  TTriple = array[0..2] of Double;

  THilbert = class
  public
    PeriodWMASub, PeriodWMASum, TrailingWMAValue, SmoothedValue: Double;
    TrailingWMAIdx: Integer;
    A, B, Rad2Deg, Deg2Rad, Const360: Double;
    HilbertIdx: Integer;
    DetrenderOdd, DetrenderEven: TTriple;
    Detrender, PrevDetrenderOdd, PrevDetrenderEven,
      PrevDetrenderInputOdd, PrevDetrenderInputEven: Double;
    Q1Odd, Q1Even: TTriple;
    Q1, PrevQ1Odd, PrevQ1Even, PrevQ1InputOdd, PrevQ1InputEven: Double;
    JIOdd, JIEven: TTriple;
    JI, PrevJIOdd, PrevJIEven, PrevJIInputOdd, PrevJIInputEven: Double;
    JQOdd, JQEven: TTriple;
    JQ, PrevJQOdd, PrevJQEven, PrevJQInputOdd, PrevJQInputEven: Double;
    Period, Q2, I2, PrevQ2, PrevI2, Re, Im: Double;
    I1ForOddPrev2, I1ForOddPrev3, I1ForEvenPrev2, I1ForEvenPrev3: Double;
    PrevPhase, MamaV, FamaV: Double;
    SmoothPeriod: Double;
    SmoothPrice: array[0..49] of Double;
    SmoothPriceIdx: Integer;
    DCPhase: Double;
    Sine, PrevSine, LeadSine, PrevLeadSine: Double;
    DaysInTrend, Trend: Integer;
    PrevDCPhase, ITrend1, ITrend2, ITrend3, Trendline: Double;
    TodayValue: Double;
    constructor Create;
    function Init(const V: TQDoubleArray; LookbackTotal, WmaInitIters: Integer): Integer;
    function Step(const V: TQDoubleArray; Today: Integer; TV: Double): Double;
    procedure UpdatePeriod;
    procedure ComputeDCPhase;
    procedure AdvanceFull(const V: TQDoubleArray; Today: Integer);
    procedure AdvancePeriodOnly(const V: TQDoubleArray; Today: Integer);
    procedure AdvanceTrend(const V: TQDoubleArray; Today: Integer);
  end;

constructor THilbert.Create;
begin
  inherited Create;
  FillChar(DetrenderOdd, SizeOf(DetrenderOdd), 0);
  FillChar(DetrenderEven, SizeOf(DetrenderEven), 0);
  FillChar(Q1Odd, SizeOf(Q1Odd), 0);
  FillChar(Q1Even, SizeOf(Q1Even), 0);
  FillChar(JIOdd, SizeOf(JIOdd), 0);
  FillChar(JIEven, SizeOf(JIEven), 0);
  FillChar(JQOdd, SizeOf(JQOdd), 0);
  FillChar(JQEven, SizeOf(JQEven), 0);
  FillChar(SmoothPrice, SizeOf(SmoothPrice), 0);
  PeriodWMASub := 0; PeriodWMASum := 0; TrailingWMAValue := 0; SmoothedValue := 0;
  TrailingWMAIdx := 0; HilbertIdx := 0;
  A := 0.0962;
  B := 0.5769;
  Rad2Deg := 180.0 / (4.0 * ArcTan(1.0));
  Deg2Rad := ArcTan(1.0) / 45.0;
  Const360 := ArcTan(1.0) * 8.0;
  Detrender := 0; PrevDetrenderOdd := 0; PrevDetrenderEven := 0;
  PrevDetrenderInputOdd := 0; PrevDetrenderInputEven := 0;
  Q1 := 0; PrevQ1Odd := 0; PrevQ1Even := 0; PrevQ1InputOdd := 0; PrevQ1InputEven := 0;
  JI := 0; PrevJIOdd := 0; PrevJIEven := 0; PrevJIInputOdd := 0; PrevJIInputEven := 0;
  JQ := 0; PrevJQOdd := 0; PrevJQEven := 0; PrevJQInputOdd := 0; PrevJQInputEven := 0;
  Period := 0; Q2 := 0; I2 := 0; PrevQ2 := 0; PrevI2 := 0; Re := 0; Im := 0;
  I1ForOddPrev2 := 0; I1ForOddPrev3 := 0; I1ForEvenPrev2 := 0; I1ForEvenPrev3 := 0;
  PrevPhase := 0; MamaV := 0; FamaV := 0;
  SmoothPeriod := 0; SmoothPriceIdx := 0; DCPhase := 0;
  Sine := 0; PrevSine := 0; LeadSine := 0; PrevLeadSine := 0;
  DaysInTrend := 0; Trend := 0; PrevDCPhase := 0;
  ITrend1 := 0; ITrend2 := 0; ITrend3 := 0; Trendline := 0; TodayValue := 0;
end;

function THilbert.Init(const V: TQDoubleArray; LookbackTotal, WmaInitIters: Integer): Integer;
var
  Today, I: Integer;
  T: Double;
begin
  TrailingWMAIdx := 0;
  Today := 0;
  T := V[Today]; Inc(Today);
  PeriodWMASub := T;
  PeriodWMASum := T;
  T := V[Today]; Inc(Today);
  PeriodWMASub := PeriodWMASub + T;
  PeriodWMASum := PeriodWMASum + T * 2.0;
  T := V[Today]; Inc(Today);
  PeriodWMASub := PeriodWMASub + T;
  PeriodWMASum := PeriodWMASum + T * 3.0;
  TrailingWMAValue := 0.0;
  for I := 1 to WmaInitIters do
  begin
    T := V[Today]; Inc(Today);
    PeriodWMASub := PeriodWMASub + T;
    PeriodWMASub := PeriodWMASub - TrailingWMAValue;
    PeriodWMASum := PeriodWMASum + T * 4.0;
    TrailingWMAValue := V[TrailingWMAIdx];
    Inc(TrailingWMAIdx);
    SmoothedValue := PeriodWMASum * 0.1;
    PeriodWMASum := PeriodWMASum - PeriodWMASub;
  end;
  Result := Today;
end;

function THilbert.Step(const V: TQDoubleArray; Today: Integer; TV: Double): Double;
var
  AdjPrev, H: Double;
begin
  AdjPrev := 0.075 * Period + 0.54;
  TodayValue := TV;
  PeriodWMASub := PeriodWMASub + TV;
  PeriodWMASub := PeriodWMASub - TrailingWMAValue;
  PeriodWMASum := PeriodWMASum + TV * 4.0;
  TrailingWMAValue := V[TrailingWMAIdx];
  Inc(TrailingWMAIdx);
  SmoothedValue := PeriodWMASum * 0.1;
  PeriodWMASum := PeriodWMASum - PeriodWMASub;

  if (Today mod 2) = 0 then
  begin
    H := A * SmoothedValue;
    Detrender := 0.0 - DetrenderEven[HilbertIdx];
    DetrenderEven[HilbertIdx] := H;
    Detrender := Detrender + H;
    Detrender := Detrender - PrevDetrenderEven;
    PrevDetrenderEven := B * PrevDetrenderInputEven;
    Detrender := Detrender + PrevDetrenderEven;
    PrevDetrenderInputEven := SmoothedValue;
    Detrender := Detrender * AdjPrev;

    H := A * Detrender;
    Q1 := 0.0 - Q1Even[HilbertIdx];
    Q1Even[HilbertIdx] := H;
    Q1 := Q1 + H;
    Q1 := Q1 - PrevQ1Even;
    PrevQ1Even := B * PrevQ1InputEven;
    Q1 := Q1 + PrevQ1Even;
    PrevQ1InputEven := Detrender;
    Q1 := Q1 * AdjPrev;

    H := A * I1ForEvenPrev3;
    JI := 0.0 - JIEven[HilbertIdx];
    JIEven[HilbertIdx] := H;
    JI := JI + H;
    JI := JI - PrevJIEven;
    PrevJIEven := B * PrevJIInputEven;
    JI := JI + PrevJIEven;
    PrevJIInputEven := I1ForEvenPrev3;
    JI := JI * AdjPrev;

    H := A * Q1;
    JQ := 0.0 - JQEven[HilbertIdx];
    JQEven[HilbertIdx] := H;
    JQ := JQ + H;
    JQ := JQ - PrevJQEven;
    PrevJQEven := B * PrevJQInputEven;
    JQ := JQ + PrevJQEven;
    PrevJQInputEven := Q1;
    JQ := JQ * AdjPrev;

    Inc(HilbertIdx);
    if HilbertIdx = 3 then HilbertIdx := 0;

    Q2 := 0.2 * (Q1 + JI) + 0.8 * PrevQ2;
    I2 := 0.2 * (I1ForEvenPrev3 - JQ) + 0.8 * PrevI2;

    I1ForOddPrev3 := I1ForOddPrev2;
    I1ForOddPrev2 := Detrender;

    if I1ForEvenPrev3 <> 0.0 then
      Result := ArcTan(Q1 / I1ForEvenPrev3) * Rad2Deg
    else
      Result := 0.0;
  end
  else
  begin
    H := A * SmoothedValue;
    Detrender := 0.0 - DetrenderOdd[HilbertIdx];
    DetrenderOdd[HilbertIdx] := H;
    Detrender := Detrender + H;
    Detrender := Detrender - PrevDetrenderOdd;
    PrevDetrenderOdd := B * PrevDetrenderInputOdd;
    Detrender := Detrender + PrevDetrenderOdd;
    PrevDetrenderInputOdd := SmoothedValue;
    Detrender := Detrender * AdjPrev;

    H := A * Detrender;
    Q1 := 0.0 - Q1Odd[HilbertIdx];
    Q1Odd[HilbertIdx] := H;
    Q1 := Q1 + H;
    Q1 := Q1 - PrevQ1Odd;
    PrevQ1Odd := B * PrevQ1InputOdd;
    Q1 := Q1 + PrevQ1Odd;
    PrevQ1InputOdd := Detrender;
    Q1 := Q1 * AdjPrev;

    H := A * I1ForOddPrev3;
    JI := 0.0 - JIOdd[HilbertIdx];
    JIOdd[HilbertIdx] := H;
    JI := JI + H;
    JI := JI - PrevJIOdd;
    PrevJIOdd := B * PrevJIInputOdd;
    JI := JI + PrevJIOdd;
    PrevJIInputOdd := I1ForOddPrev3;
    JI := JI * AdjPrev;

    H := A * Q1;
    JQ := 0.0 - JQOdd[HilbertIdx];
    JQOdd[HilbertIdx] := H;
    JQ := JQ + H;
    JQ := JQ - PrevJQOdd;
    PrevJQOdd := B * PrevJQInputOdd;
    JQ := JQ + PrevJQOdd;
    PrevJQInputOdd := Q1;
    JQ := JQ * AdjPrev;

    Inc(HilbertIdx);
    if HilbertIdx = 3 then HilbertIdx := 0;

    Q2 := 0.2 * (Q1 + JI) + 0.8 * PrevQ2;
    I2 := 0.2 * (I1ForOddPrev3 - JQ) + 0.8 * PrevI2;

    I1ForEvenPrev3 := I1ForEvenPrev2;
    I1ForEvenPrev2 := Detrender;

    if I1ForOddPrev3 <> 0.0 then
      Result := ArcTan(Q1 / I1ForOddPrev3) * Rad2Deg
    else
      Result := 0.0;
  end;
end;

procedure THilbert.UpdatePeriod;
var
  Prev, Hi, Lo: Double;
begin
  Re := 0.8 * Re + 0.2 * (I2 * PrevI2 + Q2 * PrevQ2);
  Im := 0.8 * Im + 0.2 * (I2 * PrevQ2 - Q2 * PrevI2);
  PrevQ2 := Q2;
  PrevI2 := I2;
  Prev := Period;
  if (Im <> 0.0) and (Re <> 0.0) then
    Period := 360.0 / (ArcTan(Im / Re) * Rad2Deg);
  Hi := 1.5 * Prev;
  if Period > Hi then Period := Hi;
  Lo := 0.67 * Prev;
  if Period < Lo then Period := Lo;
  if Period < 6.0 then
    Period := 6.0
  else if Period > 50.0 then
    Period := 50.0;
  Period := 0.2 * Period + 0.8 * Prev;
end;

procedure THilbert.ComputeDCPhase;
var
  DCInt, Idx, I: Integer;
  RealPart, ImagPart, Ang, SP, AbsImag: Double;
begin
  DCInt := Trunc(SmoothPeriod + 0.5);
  RealPart := 0.0;
  ImagPart := 0.0;
  Idx := SmoothPriceIdx;
  for I := 0 to DCInt - 1 do
  begin
    Ang := (I * Const360) / DCInt;
    SP := SmoothPrice[Idx];
    RealPart := RealPart + Sin(Ang) * SP;
    ImagPart := ImagPart + Cos(Ang) * SP;
    if Idx = 0 then Idx := 49 else Dec(Idx);
  end;
  AbsImag := Abs(ImagPart);
  if AbsImag > 0.0 then
    DCPhase := ArcTan(RealPart / ImagPart) * Rad2Deg
  else if AbsImag <= 0.01 then
  begin
    if RealPart < 0.0 then
      DCPhase := DCPhase - 90.0
    else if RealPart > 0.0 then
      DCPhase := DCPhase + 90.0;
  end;
  DCPhase := DCPhase + 90.0;
  DCPhase := DCPhase + 360.0 / SmoothPeriod; // compensate one bar of WMA lag
  if ImagPart < 0.0 then
    DCPhase := DCPhase + 180.0;
  if DCPhase > 315.0 then
    DCPhase := DCPhase - 360.0;
end;

procedure THilbert.AdvanceFull(const V: TQDoubleArray; Today: Integer);
begin
  Step(V, Today, V[Today]);
  UpdatePeriod;
  SmoothPeriod := 0.67 * SmoothPeriod + 0.33 * Period;
  SmoothPrice[SmoothPriceIdx] := SmoothedValue;
  ComputeDCPhase;
  PrevSine := Sine;
  PrevLeadSine := LeadSine;
  Sine := Sin(DCPhase * Deg2Rad);
  LeadSine := Sin((DCPhase + 45.0) * Deg2Rad);
  Inc(SmoothPriceIdx);
  if SmoothPriceIdx > 49 then SmoothPriceIdx := 0;
end;

procedure THilbert.AdvancePeriodOnly(const V: TQDoubleArray; Today: Integer);
begin
  Step(V, Today, V[Today]);
  UpdatePeriod;
  SmoothPeriod := 0.67 * SmoothPeriod + 0.33 * Period;
end;

procedure THilbert.AdvanceTrend(const V: TQDoubleArray; Today: Integer);
var
  Crossed: Boolean;
  Delta, Temp: Double;
  DCInt, J: Integer;
begin
  Trend := 1;
  Crossed := ((Sine > LeadSine) and (PrevSine <= PrevLeadSine)) or
             ((Sine < LeadSine) and (PrevSine >= PrevLeadSine));
  if Crossed then
  begin
    DaysInTrend := 0;
    Trend := 0;
  end;
  Inc(DaysInTrend);
  if DaysInTrend < 0.5 * SmoothPeriod then
    Trend := 0;
  Delta := DCPhase - PrevDCPhase;
  if (SmoothPeriod <> 0.0) and (Delta > 0.67 * 360.0 / SmoothPeriod) and
     (Delta < 1.5 * 360.0 / SmoothPeriod) then
    Trend := 0;
  DCInt := Trunc(SmoothPeriod + 0.5);
  Temp := 0.0;
  for J := 0 to 49 do
    if (J < DCInt) and (Today >= J) then
      Temp := Temp + V[Today - J];
  if DCInt > 0 then
    Temp := Temp / DCInt;
  Trendline := (2.0 * ITrend2 + 4.0 * Temp + 3.0 * ITrend1 + ITrend3) / 10.0;
  ITrend3 := ITrend2;
  ITrend2 := ITrend1;
  ITrend1 := Temp;
  if (Trendline <> 0.0) and (Abs((SmoothedValue - Trendline) / Trendline) >= 0.015) then
    Trend := 1;
  PrevDCPhase := DCPhase;
end;

{ ---------------- public functions ---------------- }

function MAMA(const Data: TQDoubleArray; FastLimit: Double; SlowLimit: Double): TQMAMA;
const
  Lookback = 32;
var
  N, Today: Integer;
  H: THilbert;
  Phase, DeltaPhase, Alpha, Alpha2: Double;
begin
  if (FastLimit < 0.01) or (FastLimit > 0.99) or (SlowLimit < 0.01) or (SlowLimit > 0.99) then
    raise EQuantTechError.Create('MAMA: limits must be within [0.01, 0.99]');
  N := Length(Data);
  Result.Mama := QTNaNSeries(N);
  Result.Fama := QTNaNSeries(N);
  if N <= Lookback then Exit;
  H := THilbert.Create;
  try
    Today := H.Init(Data, Lookback, 9);
    while Today <= N - 1 do
    begin
      Phase := H.Step(Data, Today, Data[Today]);
      DeltaPhase := H.PrevPhase - Phase;
      H.PrevPhase := Phase;
      Alpha := DeltaPhase;
      if Alpha < 1.0 then Alpha := 1.0;
      if Alpha > 1.0 then
      begin
        Alpha := FastLimit / Alpha;
        if Alpha < SlowLimit then Alpha := SlowLimit;
      end
      else
        Alpha := FastLimit;
      H.MamaV := (1.0 - Alpha) * H.MamaV + Alpha * H.TodayValue;
      Alpha2 := Alpha * 0.5;
      H.FamaV := (1.0 - Alpha2) * H.FamaV + Alpha2 * H.MamaV;
      H.UpdatePeriod;
      if Today >= Lookback then
      begin
        Result.Mama[Today] := H.MamaV;
        Result.Fama[Today] := H.FamaV;
      end;
      Inc(Today);
    end;
  finally
    H.Free;
  end;
end;

function HT_TRENDLINE(const Data: TQDoubleArray): TQDoubleArray;
const
  Lookback = 63;
var
  N, Today, DCInt, K, Terms, J: Integer;
  H: THilbert;
  SmoothP, Sum, Trend, IT1, IT2, IT3: Double;
begin
  N := Length(Data);
  Result := QTNaNSeries(N);
  if N <= Lookback then Exit;
  H := THilbert.Create;
  try
    Today := H.Init(Data, Lookback, 34);
    IT1 := 0; IT2 := 0; IT3 := 0; SmoothP := 0;
    while Today <= N - 1 do
    begin
      H.Step(Data, Today, Data[Today]);
      H.UpdatePeriod;
      SmoothP := 0.67 * SmoothP + 0.33 * H.Period;
      DCInt := Trunc(SmoothP + 0.5);
      K := DCInt;
      if K > 50 then K := 50;
      Terms := K;
      if Today + 1 < Terms then Terms := Today + 1;
      Sum := 0.0;
      for J := 0 to Terms - 1 do
        Sum := Sum + Data[Today - J];
      if DCInt > 0 then Sum := Sum / DCInt;
      Trend := (2.0 * IT2 + 4.0 * Sum + 3.0 * IT1 + IT3) / 10.0;
      IT3 := IT2;
      IT2 := IT1;
      IT1 := Sum;
      if Today >= Lookback then Result[Today] := Trend;
      Inc(Today);
    end;
  finally
    H.Free;
  end;
end;

function HT_DCPERIOD(const Data: TQDoubleArray): TQDoubleArray;
const
  Lookback = 32;
var
  N, Today: Integer;
  H: THilbert;
begin
  N := Length(Data);
  Result := QTNaNSeries(N);
  if N <= Lookback then Exit;
  H := THilbert.Create;
  try
    Today := H.Init(Data, Lookback, 9);
    while Today <= N - 1 do
    begin
      H.AdvancePeriodOnly(Data, Today);
      if Today >= Lookback then Result[Today] := H.SmoothPeriod;
      Inc(Today);
    end;
  finally
    H.Free;
  end;
end;

function HT_DCPHASE(const Data: TQDoubleArray): TQDoubleArray;
const
  Lookback = 63;
var
  N, Today: Integer;
  H: THilbert;
begin
  N := Length(Data);
  Result := QTNaNSeries(N);
  if N <= Lookback then Exit;
  H := THilbert.Create;
  try
    Today := H.Init(Data, Lookback, 34);
    while Today <= N - 1 do
    begin
      H.AdvanceFull(Data, Today);
      if Today >= Lookback then Result[Today] := H.DCPhase;
      Inc(Today);
    end;
  finally
    H.Free;
  end;
end;

function HT_PHASOR(const Data: TQDoubleArray): TQPhasor;
const
  Lookback = 32;
var
  N, Today: Integer;
  H: THilbert;
  Even: Boolean;
begin
  N := Length(Data);
  Result.InPhase := QTNaNSeries(N);
  Result.Quadrature := QTNaNSeries(N);
  if N <= Lookback then Exit;
  H := THilbert.Create;
  try
    Today := H.Init(Data, Lookback, 9);
    while Today <= N - 1 do
    begin
      Even := (Today mod 2) = 0;
      H.Step(Data, Today, Data[Today]);
      H.UpdatePeriod;
      if Today >= Lookback then
      begin
        Result.Quadrature[Today] := H.Q1;
        if Even then
          Result.InPhase[Today] := H.I1ForEvenPrev3
        else
          Result.InPhase[Today] := H.I1ForOddPrev3;
      end;
      Inc(Today);
    end;
  finally
    H.Free;
  end;
end;

function HT_SINE(const Data: TQDoubleArray): TQHTSine;
const
  Lookback = 63;
var
  N, Today: Integer;
  H: THilbert;
begin
  N := Length(Data);
  Result.Sine := QTNaNSeries(N);
  Result.LeadSine := QTNaNSeries(N);
  if N <= Lookback then Exit;
  H := THilbert.Create;
  try
    Today := H.Init(Data, Lookback, 34);
    while Today <= N - 1 do
    begin
      H.AdvanceFull(Data, Today);
      if Today >= Lookback then
      begin
        Result.Sine[Today] := H.Sine;
        Result.LeadSine[Today] := H.LeadSine;
      end;
      Inc(Today);
    end;
  finally
    H.Free;
  end;
end;

function HT_TRENDMODE(const Data: TQDoubleArray): TQIntArray;
const
  Lookback = 63;
var
  N, Today, I: Integer;
  H: THilbert;
begin
  N := Length(Data);
  SetLength(Result, N);
  for I := 0 to N - 1 do Result[I] := 0;
  if N <= Lookback then Exit;
  H := THilbert.Create;
  try
    Today := H.Init(Data, Lookback, 34);
    while Today <= N - 1 do
    begin
      H.AdvanceFull(Data, Today);
      H.AdvanceTrend(Data, Today);
      if Today >= Lookback then Result[Today] := H.Trend;
      Inc(Today);
    end;
  finally
    H.Free;
  end;
end;

end.
