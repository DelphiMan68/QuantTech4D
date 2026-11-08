{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ Extended indicators (the newer part of TA-Lib's function list).
  IMPORTANT: these are implemented from the standard published definitions of
  each indicator. TA-Lib's own parameter defaults and edge handling for these
  functions were NOT available while writing, so results may differ slightly
  from TA-Lib. Every function documents its formula and defaults. }
unit QuantTech4D.Extended;

{$I QuantTech4D.inc}

interface

uses
  SysUtils, Math, QuantTech4D.Types, QuantTech4D.Core, QuantTech4D.MathOps,
  QuantTech4D.Overlap, QuantTech4D.Momentum, QuantTech4D.Volatility,
  QuantTech4D.Statistic;

type
  /// Generic two-output result. Field meaning is documented per function.
  TQPair = record
    First, Second: TQDoubleArray;
  end;

  TQKDJ = record
    K, D, J: TQDoubleArray;
  end;

  TQIchimoku = record
    Tenkan, Kijun, SenkouA, SenkouB, Chikou: TQDoubleArray;
  end;

{ ---- trend / moving averages ---- }
/// Arnaud Legoux Moving Average.
function ALMA(const Data: TQDoubleArray; Period: Integer = 9; Offset: Double = 0.85;
  Sigma: Double = 6.0): TQDoubleArray;
/// Fractal Adaptive Moving Average (Ehlers). Period must be even (>= 4).
function FRAMA(const Data: TQDoubleArray; Period: Integer = 16): TQDoubleArray;
/// Variable Index Dynamic Average (Chande): EMA whose alpha scales with |CMO|.
function VIDYA(const Data: TQDoubleArray; Period: Integer = 14;
  CMOPeriod: Integer = 9): TQDoubleArray;
/// McGinley Dynamic.
function MCGD(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Moving average with variable period (Periods[i] selects the period at bar i).
function MAVP(const Data, Periods: TQDoubleArray; MinPeriod: Integer = 2;
  MaxPeriod: Integer = 30; MAType: TQMAType = maSMA): TQDoubleArray;
/// MACD with controllable MA types.
function MACDEXT(const Data: TQDoubleArray; FastPeriod: Integer = 12;
  FastMAType: TQMAType = maSMA; SlowPeriod: Integer = 26; SlowMAType: TQMAType = maSMA;
  SignalPeriod: Integer = 9; SignalMAType: TQMAType = maSMA): TQMACD;
/// MACD-V: (EMA fast - EMA slow) / ATR(slow) * 100.
function MACDV(const High, Low, Close: TQDoubleArray; FastPeriod: Integer = 12;
  SlowPeriod: Integer = 26; SignalPeriod: Integer = 9): TQMACD;
/// Parabolic SAR extended. Short-side values are returned negative (TA-Lib convention).
function SAREXT(const High, Low: TQDoubleArray; StartValue: Double = 0.0;
  OffsetOnReverse: Double = 0.0; AFInitLong: Double = 0.02; AFLong: Double = 0.02;
  AFMaxLong: Double = 0.2; AFInitShort: Double = 0.02; AFShort: Double = 0.02;
  AFMaxShort: Double = 0.2): TQDoubleArray;
/// SuperTrend. First = SuperTrend line, Second = direction (1 up, -1 down).
function SUPERTREND(const High, Low, Close: TQDoubleArray; Period: Integer = 10;
  Multiplier: Double = 3.0): TQPair;

{ ---- Swiss Army Knife filters (Ehlers) ---- }
function SWAK_HP(const Data: TQDoubleArray; Period: Integer = 20): TQDoubleArray;
function SWAK_2PHP(const Data: TQDoubleArray; Period: Integer = 20): TQDoubleArray;
function SWAK_BUTTER(const Data: TQDoubleArray; Period: Integer = 20): TQDoubleArray;
function SWAK_GAUSS(const Data: TQDoubleArray; Period: Integer = 20): TQDoubleArray;
function SWAK_BP(const Data: TQDoubleArray; Period: Integer = 20;
  Bandwidth: Double = 0.1): TQDoubleArray;

{ ---- bands / channels ---- }
/// Headley Acceleration Bands.
function ACCBANDS(const High, Low, Close: TQDoubleArray; Period: Integer = 20): TQBBands;
/// Bollinger BandWidth: (upper - lower) / middle.
function BBW(const Data: TQDoubleArray; Period: Integer = 20; NbDev: Double = 2.0): TQDoubleArray;
/// Bollinger %B.
function PERCENTB(const Data: TQDoubleArray; Period: Integer = 20; NbDev: Double = 2.0): TQDoubleArray;
/// Donchian Channels (Upper = highest high, Lower = lowest low).
function DONCHIAN(const High, Low: TQDoubleArray; Period: Integer = 20): TQBBands;
/// Keltner Channels: EMA(close) +/- Multiplier * ATR.
function KC(const High, Low, Close: TQDoubleArray; Period: Integer = 20;
  Multiplier: Double = 2.0; ATRPeriod: Integer = 10): TQBBands;
/// Chandelier Exit. First = long exit, Second = short exit.
function CE(const High, Low, Close: TQDoubleArray; Period: Integer = 22;
  Multiplier: Double = 3.0): TQPair;
/// Chande Kroll Stop. First = stop for longs, Second = stop for shorts.
function CKSP(const High, Low, Close: TQDoubleArray; P: Integer = 10;
  X: Double = 1.0; Q: Integer = 9): TQPair;
/// Ichimoku Kinko Hyo (Senkou spans are shifted forward, Chikou back).
function ICHIMOKU(const High, Low, Close: TQDoubleArray; TenkanPeriod: Integer = 9;
  KijunPeriod: Integer = 26; SenkouBPeriod: Integer = 52;
  Displacement: Integer = 26): TQIchimoku;

{ ---- volatility / range ---- }
/// Average Day Range: SMA(high - low).
function ADR(const High, Low: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Rogers-Satchell volatility (per-bar, not annualised).
function ROGERSSATCHELL(const Open, High, Low, Close: TQDoubleArray;
  Period: Integer = 20): TQDoubleArray;
/// Chaikin's Volatility: ROC of EMA(high - low).
function CVI(const High, Low: TQDoubleArray; Period: Integer = 10;
  ROCPeriod: Integer = 10): TQDoubleArray;
/// Choppiness Index.
function CHOP(const High, Low, Close: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Choppiness Index using the True Range box (prior close widens the high/low).
function CHOPTR(const High, Low, Close: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Mass Index.
function MASSI(const High, Low: TQDoubleArray; EMAPeriod: Integer = 9;
  SumPeriod: Integer = 25): TQDoubleArray;
/// Vertical Horizontal Filter.
function VHF(const Data: TQDoubleArray; Period: Integer = 28): TQDoubleArray;

{ ---- oscillators / momentum ---- }
/// Accelerator/Decelerator Oscillator: AO - SMA(AO, 5).
function AC(const High, Low: TQDoubleArray): TQDoubleArray;
/// Center of Gravity oscillator (Ehlers).
function CG(const Data: TQDoubleArray; Period: Integer = 10): TQDoubleArray;
/// Chande Momentum Oscillator, unsmoothed (plain window sums).
function CMOU(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Coppock Curve: WMA(ROC1 + ROC2, WMAPeriod).
function COPPOCK(const Data: TQDoubleArray; ROC1: Integer = 14; ROC2: Integer = 11;
  WMAPeriod: Integer = 10): TQDoubleArray;
/// Connors RSI: average of RSI(price), RSI(streak) and PercentRank(ROC).
function CRSI(const Data: TQDoubleArray; RSIPeriod: Integer = 3;
  StreakPeriod: Integer = 2; RankPeriod: Integer = 100): TQDoubleArray;
/// Correlation Trend Indicator (Ehlers): correlation of price with time.
function CTI(const Data: TQDoubleArray; Period: Integer = 20): TQDoubleArray;
/// Derivative Oscillator: smoothed RSI minus its signal line.
function DOSC(const Data: TQDoubleArray; RSIPeriod: Integer = 14; EMA1: Integer = 5;
  EMA2: Integer = 3; SignalPeriod: Integer = 9): TQDoubleArray;
/// Detrended Price Oscillator.
function DPO(const Data: TQDoubleArray; Period: Integer = 20): TQDoubleArray;
/// Kaufman Efficiency Ratio.
function ER(const Data: TQDoubleArray; Period: Integer = 10): TQDoubleArray;
/// Elder Ray Index. First = bull power, Second = bear power.
function ERI(const High, Low, Close: TQDoubleArray; Period: Integer = 13): TQPair;
/// Fisher Transform. First = Fisher, Second = trigger (previous Fisher).
function FISHER(const High, Low: TQDoubleArray; Period: Integer = 9): TQPair;
/// Forecast Oscillator: 100 * (close - TSF) / close.
function FOSC(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Internal Bar Strength: (close - low) / (high - low).
function IBS(const High, Low, Close: TQDoubleArray): TQDoubleArray;
/// Intraday Momentum Index.
function IMI(const Open, Close: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// KDJ stochastic with recursive 1/3 smoothing; seeds are 50.
function KDJ(const High, Low, Close: TQDoubleArray; Period: Integer = 9;
  KSmooth: Integer = 3; DSmooth: Integer = 3): TQKDJ;
/// Know Sure Thing (Pring). First = KST, Second = signal.
function KST(const Data: TQDoubleArray; R1: Integer = 10; R2: Integer = 15;
  R3: Integer = 20; R4: Integer = 30; S1: Integer = 10; S2: Integer = 10;
  S3: Integer = 10; S4: Integer = 15; SignalPeriod: Integer = 9): TQPair;
/// Know Sure Thing with controllable MA type.
function KSTEXT(const Data: TQDoubleArray; R1: Integer = 10; R2: Integer = 15;
  R3: Integer = 20; R4: Integer = 30; S1: Integer = 10; S2: Integer = 10;
  S3: Integer = 10; S4: Integer = 15; SignalPeriod: Integer = 9;
  MAType: TQMAType = maSMA): TQPair;
/// Premier Stochastic Oscillator (Leibfarth), range -1..1.
function PSO(const High, Low, Close: TQDoubleArray; StochPeriod: Integer = 8;
  SmoothPeriod: Integer = 5): TQDoubleArray;
/// Relative Volatility Index (Dorsey) on closes.
function RVI(const Data: TQDoubleArray; StdPeriod: Integer = 10;
  SmoothPeriod: Integer = 14): TQDoubleArray;
/// Relative Volatility Index, refined: average of RVI(high) and RVI(low).
function RVIR(const High, Low: TQDoubleArray; StdPeriod: Integer = 10;
  SmoothPeriod: Integer = 14): TQDoubleArray;
/// Stochastic Momentum Index (Blau). First = SMI, Second = signal.
function SMI(const High, Low, Close: TQDoubleArray; Period: Integer = 10;
  Smooth1: Integer = 3; Smooth2: Integer = 3; SignalPeriod: Integer = 3): TQPair;
/// Squeeze Momentum. First = momentum, Second = squeeze flag (1 = squeeze on).
function SQZMOM(const High, Low, Close: TQDoubleArray; BBPeriod: Integer = 20;
  BBMult: Double = 2.0; KCPeriod: Integer = 20; KCMult: Double = 1.5): TQPair;
/// Schaff Trend Cycle.
function STC(const Data: TQDoubleArray; FastPeriod: Integer = 23;
  SlowPeriod: Integer = 50; CyclePeriod: Integer = 10; Smooth: Double = 0.5): TQDoubleArray;
/// True Strength Index.
function TSI(const Data: TQDoubleArray; LongPeriod: Integer = 25;
  ShortPeriod: Integer = 13): TQDoubleArray;
/// Vortex Indicator. First = VI+, Second = VI-.
function VORTEX(const High, Low, Close: TQDoubleArray; Period: Integer = 14): TQPair;
/// WaveTrend Oscillator. First = WT1, Second = WT2 (SMA(WT1,4)).
function WAVETREND(const High, Low, Close: TQDoubleArray; ChannelPeriod: Integer = 10;
  AveragePeriod: Integer = 21): TQPair;
/// Wilder Swing Index.
function SI(const Open, High, Low, Close: TQDoubleArray; LimitMove: Double = 0.5): TQDoubleArray;
/// Wilder Accumulative Swing Index.
function ASI(const Open, High, Low, Close: TQDoubleArray; LimitMove: Double = 0.5): TQDoubleArray;

{ ---- statistics ---- }
function AVGDEV(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Rolling skewness (population moments).
function SkewRoll(const Data: TQDoubleArray; Period: Integer = 20): TQDoubleArray;
/// Rolling excess kurtosis (population moments).
function KurtosisRoll(const Data: TQDoubleArray; Period: Integer = 20): TQDoubleArray;
/// Rolling percentile, nearest-rank method (Percentile in 0..100).
function PercentileRoll(const Data: TQDoubleArray; Period: Integer = 20;
  Percentile: Double = 50.0): TQDoubleArray;
/// Percent rank: share of the previous Period values that are <= the current value.
function PERCENTRANK(const Data: TQDoubleArray; Period: Integer = 20): TQDoubleArray;

{ ---- volume ---- }
/// Elder's Force Index: EMA(volume * close change).
function EFI(const Close, Volume: TQDoubleArray; Period: Integer = 13): TQDoubleArray;
/// Arms Ease of Movement (VolumeScale divides the volume to size the box ratio).
function EMV(const High, Low, Volume: TQDoubleArray; Period: Integer = 14;
  VolumeScale: Double = 10000.0): TQDoubleArray;
/// Klinger Volume Oscillator. First = KVO, Second = signal.
function KVO(const High, Low, Close, Volume: TQDoubleArray; FastPeriod: Integer = 34;
  SlowPeriod: Integer = 55; SignalPeriod: Integer = 13): TQPair;
/// Market Facilitation Index: (high - low) / volume.
function MARKETFI(const High, Low, Volume: TQDoubleArray): TQDoubleArray;
/// Negative Volume Index (starts at 1000).
function NVI(const Close, Volume: TQDoubleArray): TQDoubleArray;
/// Positive Volume Index (starts at 1000).
function PVI(const Close, Volume: TQDoubleArray): TQDoubleArray;
/// Percentage Volume Oscillator (MACD of volume, in percent).
function PVO(const Volume: TQDoubleArray; FastPeriod: Integer = 12;
  SlowPeriod: Integer = 26; SignalPeriod: Integer = 9): TQMACD;
/// Price Volume Trend.
function PVT(const Close, Volume: TQDoubleArray): TQDoubleArray;
/// Qstick: SMA(close - open).
function QSTICK(const Open, Close: TQDoubleArray; Period: Integer = 8): TQDoubleArray;
/// Relative Volume: volume / SMA(volume).
function RVOL(const Volume: TQDoubleArray; Period: Integer = 20): TQDoubleArray;
/// Cumulative Volume Weighted Average Price of the whole series.
function VWAP(const High, Low, Close, Volume: TQDoubleArray): TQDoubleArray;
/// Williams' Accumulation/Distribution.
function WAD(const High, Low, Close: TQDoubleArray): TQDoubleArray;

{ ---- structure ---- }
/// Williams Fractal. First = fractal highs, Second = fractal lows (value at the centre bar).
function FRACTAL(const High, Low: TQDoubleArray): TQPair;
/// ZigZag with a percentage deviation. Pivot prices at pivot bars, NaN elsewhere.
function ZIGZAG(const High, Low: TQDoubleArray; Deviation: Double = 5.0): TQDoubleArray;

implementation

{ ---------- small helpers ---------- }

function Blank(const X: TQDoubleArray): TQDoubleArray;
begin
  Result := QTNaNSeries(Length(X));
end;

function Diff1(const X: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
begin
  Result := Blank(X);
  for i := 1 to (Length(X) - 1) do
    Result[i] := X[i] - X[i - 1];
end;

function RecursiveSmooth(const X: TQDoubleArray; Factor: Double): TQDoubleArray;
var
  S, i: Integer;
  Prev: Double;
begin
  Result := Blank(X);
  S := QTFirstValid(X);
  if S < 0 then Exit;
  Prev := X[S];
  Result[S] := Prev;
  for i := S + 1 to (Length(X) - 1) do
  begin
    Prev := Prev + Factor * (X[i] - Prev);
    Result[i] := Prev;
  end;
end;

function Pair(const A, B: TQDoubleArray): TQPair;
begin
  Result.First := A;
  Result.Second := B;
end;

function PercentRankOf(const X: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j, Cnt: Integer;
begin
  Result := Blank(X);
  S := QTFirstValid(X);
  if S < 0 then Exit;
  for i := S + Period to (Length(X) - 1) do
  begin
    Cnt := 0;
    for j := i - Period to i - 1 do
      if X[j] <= X[i] then Inc(Cnt);
    Result[i] := 100.0 * Cnt / Period;
  end;
end;

{ ---------- trend / moving averages ---------- }

function ALMA(const Data: TQDoubleArray; Period: Integer; Offset: Double;
  Sigma: Double): TQDoubleArray;
var
  W: TQDoubleArray;
  M, Sg, WSum, Sum: Double;
  S, i, j: Integer;
begin
  QTCheckPeriod(Period, 2, 'ALMA');
  Result := Blank(Data);
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  SetLength(W, Period);
  M := Offset * (Period - 1);
  Sg := Period / Sigma;
  WSum := 0;
  for j := 0 to Period - 1 do
  begin
    W[j] := Exp(-Sqr(j - M) / (2 * Sg * Sg));
    WSum := WSum + W[j];
  end;
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    Sum := 0;
    for j := 0 to Period - 1 do
      Sum := Sum + W[j] * Data[i - Period + 1 + j];
    Result[i] := Sum / WSum;
  end;
end;

function FRAMA(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  n, S, Half, i, j: Integer;
  H1, L1, H2, L2, H3, L3, N1, N2, N3, Dim, Alpha, Prev: Double;
begin
  QTCheckPeriod(Period, 4, 'FRAMA');
  if Odd(Period) then Inc(Period);
  n := Length(Data);
  Result := Blank(Data);
  S := QTFirstValid(Data);
  if (S < 0) or (n - S < Period) then Exit;
  Half := Period div 2;
  Prev := Data[S + Period - 1];
  Result[S + Period - 1] := Prev;
  for i := S + Period to n - 1 do
  begin
    H1 := Data[i]; L1 := Data[i];
    for j := i - Half + 1 to i do
    begin
      if Data[j] > H1 then H1 := Data[j];
      if Data[j] < L1 then L1 := Data[j];
    end;
    H2 := Data[i - Half]; L2 := Data[i - Half];
    for j := i - Period + 1 to i - Half do
    begin
      if Data[j] > H2 then H2 := Data[j];
      if Data[j] < L2 then L2 := Data[j];
    end;
    H3 := Max(H1, H2);
    L3 := Min(L1, L2);
    N1 := (H1 - L1) / Half;
    N2 := (H2 - L2) / Half;
    N3 := (H3 - L3) / Period;
    if (N1 > 0) and (N2 > 0) and (N3 > 0) then
      Dim := (Ln(N1 + N2) - Ln(N3)) / Ln(2.0)
    else
      Dim := 1.0;
    Alpha := Exp(-4.6 * (Dim - 1.0));
    if Alpha < 0.01 then Alpha := 0.01;
    if Alpha > 1.0 then Alpha := 1.0;
    Prev := Alpha * Data[i] + (1.0 - Alpha) * Prev;
    Result[i] := Prev;
  end;
end;

function VIDYA(const Data: TQDoubleArray; Period: Integer; CMOPeriod: Integer): TQDoubleArray;
var
  C: TQDoubleArray;
  S, i: Integer;
  Alpha, K, Prev: Double;
begin
  QTCheckPeriod(Period, 2, 'VIDYA');
  C := CMO(Data, CMOPeriod);
  Result := Blank(Data);
  S := QTFirstValid(C);
  if S < 0 then Exit;
  Alpha := 2.0 / (Period + 1);
  Prev := Data[S];
  Result[S] := Prev;
  for i := S + 1 to (Length(Data) - 1) do
  begin
    K := Abs(C[i]) / 100.0;
    Prev := Alpha * K * Data[i] + (1.0 - Alpha * K) * Prev;
    Result[i] := Prev;
  end;
end;

function MCGD(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i: Integer;
  MD, R: Double;
begin
  QTCheckPeriod(Period, 1, 'MCGD');
  Result := Blank(Data);
  S := QTFirstValid(Data);
  if S < 0 then Exit;
  MD := Data[S];
  Result[S] := MD;
  for i := S + 1 to (Length(Data) - 1) do
  begin
    if MD <> 0 then
    begin
      R := Data[i] / MD;
      MD := MD + (Data[i] - MD) / (Period * R * R * R * R);
    end
    else
      MD := Data[i];
    Result[i] := MD;
  end;
end;

function MAVP(const Data, Periods: TQDoubleArray; MinPeriod: Integer; MaxPeriod: Integer;
  MAType: TQMAType): TQDoubleArray;
var
  n, i, P, Lb: Integer;
  Cache: array of TQDoubleArray;
  Done: array of Boolean;
  Ones: TQDoubleArray;
begin
  QTCheckPeriod(MinPeriod, 2, 'MAVP');
  QTCheckPeriod(MaxPeriod, MinPeriod, 'MAVP');
  QTCheckLength(Length(Data), Length(Periods), 'MAVP');
  n := Length(Data);
  Result := Blank(Data);
  SetLength(Cache, MaxPeriod + 1);
  SetLength(Done, MaxPeriod + 1);
  SetLength(Ones, n);
  for i := 0 to n - 1 do Ones[i] := 1.0;
  Lb := QTLookback(MA(Ones, MaxPeriod, MAType));
  for i := Lb to n - 1 do
  begin
    if IsNaN(Periods[i]) then Continue;
    P := Round(Periods[i]);
    if P < MinPeriod then P := MinPeriod;
    if P > MaxPeriod then P := MaxPeriod;
    if not Done[P] then
    begin
      Cache[P] := MA(Data, P, MAType);
      Done[P] := True;
    end;
    Result[i] := Cache[P][i];
  end;
end;

function MACDEXT(const Data: TQDoubleArray; FastPeriod: Integer; FastMAType: TQMAType;
  SlowPeriod: Integer; SlowMAType: TQMAType; SignalPeriod: Integer;
  SignalMAType: TQMAType): TQMACD;
var
  F, S, Line: TQDoubleArray;
  i, TP: Integer;
  TT: TQMAType;
begin
  QTCheckPeriod(FastPeriod, 2, 'MACDEXT');
  QTCheckPeriod(SlowPeriod, 2, 'MACDEXT');
  QTCheckPeriod(SignalPeriod, 1, 'MACDEXT');
  if SlowPeriod < FastPeriod then
  begin
    TP := FastPeriod; FastPeriod := SlowPeriod; SlowPeriod := TP;
    TT := FastMAType; FastMAType := SlowMAType; SlowMAType := TT;
  end;
  F := MA(Data, FastPeriod, FastMAType);
  S := MA(Data, SlowPeriod, SlowMAType);
  Line := Blank(Data);
  for i := 0 to (Length(Data) - 1) do
    if (not IsNaN(F[i])) and (not IsNaN(S[i])) then
      Line[i] := F[i] - S[i];
  Result.MACD := Line;
  Result.Signal := MA(Line, SignalPeriod, SignalMAType);
  Result.Hist := Blank(Data);
  for i := 0 to (Length(Data) - 1) do
    if not IsNaN(Result.Signal[i]) then
      Result.Hist[i] := Line[i] - Result.Signal[i];
end;

function MACDV(const High, Low, Close: TQDoubleArray; FastPeriod: Integer;
  SlowPeriod: Integer; SignalPeriod: Integer): TQMACD;
var
  F, S, A, Line: TQDoubleArray;
  i: Integer;
begin
  QTCheckPeriod(FastPeriod, 2, 'MACDV');
  QTCheckPeriod(SlowPeriod, 2, 'MACDV');
  F := EMA(Close, FastPeriod);
  S := EMA(Close, SlowPeriod);
  A := ATR(High, Low, Close, SlowPeriod);
  Line := Blank(Close);
  for i := 0 to (Length(Close) - 1) do
    if (not IsNaN(F[i])) and (not IsNaN(S[i])) and (not IsNaN(A[i])) and (A[i] <> 0) then
      Line[i] := (F[i] - S[i]) / A[i] * 100;
  Result.MACD := Line;
  Result.Signal := EMA(Line, SignalPeriod);
  Result.Hist := Blank(Close);
  for i := 0 to (Length(Close) - 1) do
    if not IsNaN(Result.Signal[i]) then
      Result.Hist[i] := Line[i] - Result.Signal[i];
end;

function SAREXT(const High, Low: TQDoubleArray; StartValue: Double; OffsetOnReverse: Double;
  AFInitLong: Double; AFLong: Double; AFMaxLong: Double; AFInitShort: Double;
  AFShort: Double; AFMaxShort: Double): TQDoubleArray;
var
  n, i: Integer;
  IsLong: Boolean;
  AF, EP, SarV, NewHigh, NewLow, PrevHigh, PrevLow, DiffP, DiffM, MinusDM: Double;
begin
  QTCheckLength(Length(High), Length(Low), 'SAREXT');
  n := Length(High);
  Result := QTNaNSeries(n);
  if n < 2 then Exit;
  if AFInitLong > AFMaxLong then AFInitLong := AFMaxLong;
  if AFLong > AFMaxLong then AFLong := AFMaxLong;
  if AFInitShort > AFMaxShort then AFInitShort := AFMaxShort;
  if AFShort > AFMaxShort then AFShort := AFMaxShort;
  if StartValue = 0 then
  begin
    DiffP := High[1] - High[0];
    DiffM := Low[0] - Low[1];
    if (DiffM > 0) and (DiffM > DiffP) then MinusDM := DiffM else MinusDM := 0;
    IsLong := not (MinusDM > 0);
    if IsLong then SarV := Low[0] else SarV := High[0];
  end
  else
  begin
    IsLong := StartValue > 0;
    SarV := Abs(StartValue);
  end;
  if IsLong then
  begin
    AF := AFInitLong;
    EP := High[1];
  end
  else
  begin
    AF := AFInitShort;
    EP := Low[1];
  end;
  NewHigh := High[0];
  NewLow := Low[0];
  for i := 1 to n - 1 do
  begin
    PrevLow := NewLow;
    PrevHigh := NewHigh;
    NewLow := Low[i];
    NewHigh := High[i];
    if IsLong then
    begin
      if NewLow <= SarV then
      begin // reverse to short
        IsLong := False;
        SarV := EP;
        if SarV < PrevHigh then SarV := PrevHigh;
        if SarV < NewHigh then SarV := NewHigh;
        if OffsetOnReverse <> 0 then SarV := SarV + SarV * OffsetOnReverse;
        Result[i] := -SarV;
        AF := AFInitShort;
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
          AF := AF + AFLong;
          if AF > AFMaxLong then AF := AFMaxLong;
        end;
        SarV := SarV + AF * (EP - SarV);
        if SarV > PrevLow then SarV := PrevLow;
        if SarV > NewLow then SarV := NewLow;
      end;
    end
    else
    begin
      if NewHigh >= SarV then
      begin // reverse to long
        IsLong := True;
        SarV := EP;
        if SarV > PrevLow then SarV := PrevLow;
        if SarV > NewLow then SarV := NewLow;
        if OffsetOnReverse <> 0 then SarV := SarV - SarV * OffsetOnReverse;
        Result[i] := SarV;
        AF := AFInitLong;
        EP := NewHigh;
        SarV := SarV + AF * (EP - SarV);
        if SarV > PrevLow then SarV := PrevLow;
        if SarV > NewLow then SarV := NewLow;
      end
      else
      begin
        Result[i] := -SarV;
        if NewLow < EP then
        begin
          EP := NewLow;
          AF := AF + AFShort;
          if AF > AFMaxShort then AF := AFMaxShort;
        end;
        SarV := SarV + AF * (EP - SarV);
        if SarV < PrevHigh then SarV := PrevHigh;
        if SarV < NewHigh then SarV := NewHigh;
      end;
    end;
  end;
end;

function SUPERTREND(const High, Low, Close: TQDoubleArray; Period: Integer;
  Multiplier: Double): TQPair;
var
  A, FU, FL, ST, Dir: TQDoubleArray;
  n, i, S: Integer;
  BU, BL, Mid: Double;
  D: Integer;
begin
  QTCheckPeriod(Period, 1, 'SUPERTREND');
  A := ATR(High, Low, Close, Period);
  n := Length(High);
  ST := Blank(High);
  Dir := Blank(High);
  SetLength(FU, n);
  SetLength(FL, n);
  S := QTFirstValid(A);
  if S >= 0 then
  begin
    D := 1;
    for i := S to n - 1 do
    begin
      Mid := (High[i] + Low[i]) / 2;
      BU := Mid + Multiplier * A[i];
      BL := Mid - Multiplier * A[i];
      if i = S then
      begin
        FU[i] := BU;
        FL[i] := BL;
      end
      else
      begin
        if (BU < FU[i - 1]) or (Close[i - 1] > FU[i - 1]) then FU[i] := BU else FU[i] := FU[i - 1];
        if (BL > FL[i - 1]) or (Close[i - 1] < FL[i - 1]) then FL[i] := BL else FL[i] := FL[i - 1];
        if (D = -1) and (Close[i] > FU[i]) then D := 1
        else if (D = 1) and (Close[i] < FL[i]) then D := -1;
      end;
      Dir[i] := D;
      if D = 1 then ST[i] := FL[i] else ST[i] := FU[i];
    end;
  end;
  Result := Pair(ST, Dir);
end;

{ ---------- Swiss Army Knife filters ---------- }

function SWAK_HP(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  i: Integer;
  Alpha, A: Double;
begin
  QTCheckPeriod(Period, 2, 'SWAK_HP');
  Result := Blank(Data);
  if Length(Data) < 2 then Exit;
  A := 2 * Pi / Period;
  Alpha := (Cos(A) + Sin(A) - 1) / Cos(A);
  Result[0] := 0;
  for i := 1 to (Length(Data) - 1) do
    Result[i] := (1 - Alpha / 2) * (Data[i] - Data[i - 1]) + (1 - Alpha) * Result[i - 1];
  Result[0] := NaN;
end;

function SWAK_2PHP(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  i: Integer;
  Alpha, A, C1: Double;
  H: TQDoubleArray;
begin
  QTCheckPeriod(Period, 2, 'SWAK_2PHP');
  Result := Blank(Data);
  if Length(Data) < 3 then Exit;
  A := 0.707 * 2 * Pi / Period;
  Alpha := (Cos(A) + Sin(A) - 1) / Cos(A);
  C1 := Sqr(1 - Alpha / 2);
  SetLength(H, Length(Data));
  H[0] := 0;
  H[1] := 0;
  for i := 2 to (Length(Data) - 1) do
  begin
    H[i] := C1 * (Data[i] - 2 * Data[i - 1] + Data[i - 2]) +
            2 * (1 - Alpha) * H[i - 1] - Sqr(1 - Alpha) * H[i - 2];
    Result[i] := H[i];
  end;
end;

function SWAK_BUTTER(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  i: Integer;
  A1, B1, C1, C2, C3: Double;
  F: TQDoubleArray;
begin
  QTCheckPeriod(Period, 2, 'SWAK_BUTTER');
  Result := Blank(Data);
  if Length(Data) < 3 then Exit;
  A1 := Exp(-1.414 * Pi / Period);
  B1 := 2 * A1 * Cos(1.414 * Pi / Period);
  C2 := B1;
  C3 := -A1 * A1;
  C1 := (1 - C2 - C3) / 4;
  SetLength(F, Length(Data));
  F[0] := Data[0];
  F[1] := Data[1];
  for i := 2 to (Length(Data) - 1) do
  begin
    F[i] := C1 * (Data[i] + 2 * Data[i - 1] + Data[i - 2]) + C2 * F[i - 1] + C3 * F[i - 2];
    Result[i] := F[i];
  end;
end;

function SWAK_GAUSS(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  i: Integer;
  Beta, Alpha: Double;
  F: TQDoubleArray;
begin
  QTCheckPeriod(Period, 2, 'SWAK_GAUSS');
  Result := Blank(Data);
  if Length(Data) < 3 then Exit;
  Beta := 2.415 * (1 - Cos(2 * Pi / Period));
  Alpha := -Beta + Sqrt(Beta * Beta + 2 * Beta);
  SetLength(F, Length(Data));
  F[0] := Data[0];
  F[1] := Data[1];
  for i := 2 to (Length(Data) - 1) do
  begin
    F[i] := Alpha * Alpha * Data[i] + 2 * (1 - Alpha) * F[i - 1] - Sqr(1 - Alpha) * F[i - 2];
    Result[i] := F[i];
  end;
end;

function SWAK_BP(const Data: TQDoubleArray; Period: Integer; Bandwidth: Double): TQDoubleArray;
var
  i: Integer;
  Beta, Gamma, Alpha: Double;
  F: TQDoubleArray;
begin
  QTCheckPeriod(Period, 2, 'SWAK_BP');
  Result := Blank(Data);
  if Length(Data) < 3 then Exit;
  Beta := Cos(2 * Pi / Period);
  Gamma := 1 / Cos(4 * Pi * Bandwidth / Period);
  Alpha := Gamma - Sqrt(Gamma * Gamma - 1);
  SetLength(F, Length(Data));
  F[0] := 0;
  F[1] := 0;
  for i := 2 to (Length(Data) - 1) do
  begin
    F[i] := 0.5 * (1 - Alpha) * (Data[i] - Data[i - 2]) +
            Beta * (1 + Alpha) * F[i - 1] - Alpha * F[i - 2];
    Result[i] := F[i];
  end;
end;

{ ---------- bands / channels ---------- }

function ACCBANDS(const High, Low, Close: TQDoubleArray; Period: Integer): TQBBands;
var
  U, L: TQDoubleArray;
  i: Integer;
  Den: Double;
begin
  QTCheckPeriod(Period, 2, 'ACCBANDS');
  QTCheckLength(Length(High), Length(Low), 'ACCBANDS');
  QTCheckLength(Length(High), Length(Close), 'ACCBANDS');
  SetLength(U, Length(High));
  SetLength(L, Length(High));
  for i := 0 to Length(High) - 1 do
  begin
    Den := High[i] + Low[i];
    if Den <> 0 then
    begin
      U[i] := High[i] * (1 + 4 * (High[i] - Low[i]) / Den);
      L[i] := Low[i] * (1 - 4 * (High[i] - Low[i]) / Den);
    end
    else
    begin
      U[i] := High[i];
      L[i] := Low[i];
    end;
  end;
  Result.Upper := SMA(U, Period);
  Result.Middle := SMA(Close, Period);
  Result.Lower := SMA(L, Period);
end;

function BBW(const Data: TQDoubleArray; Period: Integer; NbDev: Double): TQDoubleArray;
var
  B: TQBBands;
  i: Integer;
begin
  B := BBANDS(Data, Period, NbDev, NbDev);
  Result := Blank(Data);
  for i := 0 to (Length(Data) - 1) do
    if (not IsNaN(B.Middle[i])) and (not IsNaN(B.Upper[i])) then
      if B.Middle[i] <> 0 then Result[i] := (B.Upper[i] - B.Lower[i]) / B.Middle[i]
      else Result[i] := 0;
end;

function PERCENTB(const Data: TQDoubleArray; Period: Integer; NbDev: Double): TQDoubleArray;
var
  B: TQBBands;
  i: Integer;
  W: Double;
begin
  B := BBANDS(Data, Period, NbDev, NbDev);
  Result := Blank(Data);
  for i := 0 to (Length(Data) - 1) do
    if (not IsNaN(B.Upper[i])) and (not IsNaN(B.Lower[i])) then
    begin
      W := B.Upper[i] - B.Lower[i];
      if W <> 0 then Result[i] := (Data[i] - B.Lower[i]) / W else Result[i] := 0;
    end;
end;

function DONCHIAN(const High, Low: TQDoubleArray; Period: Integer): TQBBands;
var
  i: Integer;
begin
  Result.Upper := RollingMax(High, Period);
  Result.Lower := RollingMin(Low, Period);
  Result.Middle := Blank(High);
  for i := 0 to Length(High) - 1 do
    if not IsNaN(Result.Upper[i]) then
      Result.Middle[i] := (Result.Upper[i] + Result.Lower[i]) / 2;
end;

function KC(const High, Low, Close: TQDoubleArray; Period: Integer; Multiplier: Double;
  ATRPeriod: Integer): TQBBands;
var
  A: TQDoubleArray;
  i: Integer;
begin
  Result.Middle := EMA(Close, Period);
  A := ATR(High, Low, Close, ATRPeriod);
  Result.Upper := Blank(Close);
  Result.Lower := Blank(Close);
  for i := 0 to Length(Close) - 1 do
    if (not IsNaN(Result.Middle[i])) and (not IsNaN(A[i])) then
    begin
      Result.Upper[i] := Result.Middle[i] + Multiplier * A[i];
      Result.Lower[i] := Result.Middle[i] - Multiplier * A[i];
    end;
end;

function CE(const High, Low, Close: TQDoubleArray; Period: Integer; Multiplier: Double): TQPair;
var
  A, HH, LL, LongX, ShortX: TQDoubleArray;
  i: Integer;
begin
  A := ATR(High, Low, Close, Period);
  HH := RollingMax(High, Period);
  LL := RollingMin(Low, Period);
  LongX := Blank(Close);
  ShortX := Blank(Close);
  for i := 0 to Length(Close) - 1 do
    if (not IsNaN(A[i])) and (not IsNaN(HH[i])) then
    begin
      LongX[i] := HH[i] - Multiplier * A[i];
      ShortX[i] := LL[i] + Multiplier * A[i];
    end;
  Result := Pair(LongX, ShortX);
end;

function CKSP(const High, Low, Close: TQDoubleArray; P: Integer; X: Double; Q: Integer): TQPair;
var
  A, HH, LL, FH, FL: TQDoubleArray;
  i: Integer;
begin
  A := ATR(High, Low, Close, P);
  HH := RollingMax(High, P);
  LL := RollingMin(Low, P);
  FH := Blank(Close);
  FL := Blank(Close);
  for i := 0 to Length(Close) - 1 do
    if (not IsNaN(A[i])) and (not IsNaN(HH[i])) then
    begin
      FH[i] := HH[i] - X * A[i];
      FL[i] := LL[i] + X * A[i];
    end;
  Result := Pair(RollingMax(FH, Q), RollingMin(FL, Q));
end;

function ICHIMOKU(const High, Low, Close: TQDoubleArray; TenkanPeriod: Integer;
  KijunPeriod: Integer; SenkouBPeriod: Integer; Displacement: Integer): TQIchimoku;
var
  n, i: Integer;
  TH, TL, KH, KL, BH, BL: TQDoubleArray;
begin
  n := Length(Close);
  TH := RollingMax(High, TenkanPeriod);
  TL := RollingMin(Low, TenkanPeriod);
  KH := RollingMax(High, KijunPeriod);
  KL := RollingMin(Low, KijunPeriod);
  BH := RollingMax(High, SenkouBPeriod);
  BL := RollingMin(Low, SenkouBPeriod);
  Result.Tenkan := Blank(Close);
  Result.Kijun := Blank(Close);
  Result.SenkouA := Blank(Close);
  Result.SenkouB := Blank(Close);
  Result.Chikou := Blank(Close);
  for i := 0 to n - 1 do
  begin
    if not IsNaN(TH[i]) then Result.Tenkan[i] := (TH[i] + TL[i]) / 2;
    if not IsNaN(KH[i]) then Result.Kijun[i] := (KH[i] + KL[i]) / 2;
  end;
  for i := 0 to n - 1 do
  begin
    if (i + Displacement < n) then
    begin
      if (not IsNaN(Result.Tenkan[i])) and (not IsNaN(Result.Kijun[i])) then
        Result.SenkouA[i + Displacement] := (Result.Tenkan[i] + Result.Kijun[i]) / 2;
      if not IsNaN(BH[i]) then
        Result.SenkouB[i + Displacement] := (BH[i] + BL[i]) / 2;
    end;
    if i - Displacement >= 0 then
      Result.Chikou[i - Displacement] := Close[i];
  end;
end;

{ ---------- volatility / range ---------- }

function ADR(const High, Low: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  R: TQDoubleArray;
  i: Integer;
begin
  QTCheckLength(Length(High), Length(Low), 'ADR');
  SetLength(R, Length(High));
  for i := 0 to Length(High) - 1 do R[i] := High[i] - Low[i];
  Result := SMA(R, Period);
end;

function ROGERSSATCHELL(const Open, High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  T, M: TQDoubleArray;
  i: Integer;
begin
  QTCheckLength(Length(Open), Length(High), 'ROGERSSATCHELL');
  QTCheckLength(Length(Open), Length(Low), 'ROGERSSATCHELL');
  QTCheckLength(Length(Open), Length(Close), 'ROGERSSATCHELL');
  SetLength(T, Length(Open));
  for i := 0 to Length(Open) - 1 do
    T[i] := Ln(High[i] / Close[i]) * Ln(High[i] / Open[i]) +
            Ln(Low[i] / Close[i]) * Ln(Low[i] / Open[i]);
  M := SMA(T, Period);
  Result := Blank(Open);
  for i := 0 to Length(Open) - 1 do
    if not IsNaN(M[i]) then
      if M[i] > 0 then Result[i] := Sqrt(M[i]) else Result[i] := 0;
end;

function CVI(const High, Low: TQDoubleArray; Period: Integer; ROCPeriod: Integer): TQDoubleArray;
var
  R, E: TQDoubleArray;
  i: Integer;
begin
  QTCheckLength(Length(High), Length(Low), 'CVI');
  SetLength(R, Length(High));
  for i := 0 to Length(High) - 1 do R[i] := High[i] - Low[i];
  E := EMA(R, Period);
  Result := Blank(R);
  for i := ROCPeriod to (Length(E) - 1) do
    if (not IsNaN(E[i])) and (not IsNaN(E[i - ROCPeriod])) and (E[i - ROCPeriod] <> 0) then
      Result[i] := (E[i] - E[i - ROCPeriod]) / E[i - ROCPeriod] * 100;
end;

function ChopCore(const High, Low, Close: TQDoubleArray; Period: Integer;
  TrueRangeBox: Boolean): TQDoubleArray;
var
  n, i, j: Integer;
  TR: TQDoubleArray;
  SumTR, HH, LL, H, L: Double;
begin
  QTCheckPeriod(Period, 2, 'CHOP');
  QTCheckLength(Length(High), Length(Low), 'CHOP');
  QTCheckLength(Length(High), Length(Close), 'CHOP');
  n := Length(High);
  Result := QTNaNSeries(n);
  TR := TRANGE(High, Low, Close);
  for i := Period to n - 1 do
  begin
    SumTR := 0;
    HH := -1E300;
    LL := 1E300;
    for j := i - Period + 1 to i do
    begin
      SumTR := SumTR + TR[j];
      H := High[j];
      L := Low[j];
      if TrueRangeBox then
      begin
        if Close[j - 1] > H then H := Close[j - 1];
        if Close[j - 1] < L then L := Close[j - 1];
      end;
      if H > HH then HH := H;
      if L < LL then LL := L;
    end;
    if (HH > LL) and (SumTR > 0) then
      Result[i] := 100 * Log10(SumTR / (HH - LL)) / Log10(Period)
    else
      Result[i] := 0;
  end;
end;

function CHOP(const High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  Result := ChopCore(High, Low, Close, Period, False);
end;

function CHOPTR(const High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  Result := ChopCore(High, Low, Close, Period, True);
end;

function MASSI(const High, Low: TQDoubleArray; EMAPeriod: Integer; SumPeriod: Integer): TQDoubleArray;
var
  R, E1, E2, Ratio: TQDoubleArray;
  i: Integer;
begin
  QTCheckLength(Length(High), Length(Low), 'MASSI');
  SetLength(R, Length(High));
  for i := 0 to Length(High) - 1 do R[i] := High[i] - Low[i];
  E1 := EMA(R, EMAPeriod);
  E2 := EMA(E1, EMAPeriod);
  Ratio := Blank(R);
  for i := 0 to Length(R) - 1 do
    if (not IsNaN(E2[i])) and (E2[i] <> 0) then Ratio[i] := E1[i] / E2[i];
  Result := RollingSum(Ratio, SumPeriod);
end;

function VHF(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j: Integer;
  HH, LL, Sum: Double;
begin
  QTCheckPeriod(Period, 2, 'VHF');
  Result := Blank(Data);
  S := QTFirstValid(Data);
  if S < 0 then Exit;
  for i := S + Period to (Length(Data) - 1) do
  begin
    HH := Data[i - Period + 1];
    LL := HH;
    Sum := 0;
    for j := i - Period + 1 to i do
    begin
      if Data[j] > HH then HH := Data[j];
      if Data[j] < LL then LL := Data[j];
      Sum := Sum + Abs(Data[j] - Data[j - 1]);
    end;
    if Sum <> 0 then Result[i] := (HH - LL) / Sum else Result[i] := 0;
  end;
end;

{ ---------- oscillators / momentum ---------- }

function AC(const High, Low: TQDoubleArray): TQDoubleArray;
var
  A, S: TQDoubleArray;
  i: Integer;
begin
  A := AO(High, Low, 5, 34);
  S := SMA(A, 5);
  Result := Blank(A);
  for i := 0 to (Length(A) - 1) do
    if not IsNaN(S[i]) then Result[i] := A[i] - S[i];
end;

function CG(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j: Integer;
  Num, Den: Double;
begin
  QTCheckPeriod(Period, 2, 'CG');
  Result := Blank(Data);
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    Num := 0;
    Den := 0;
    for j := 0 to Period - 1 do
    begin
      Num := Num + (j + 1) * Data[i - j];
      Den := Den + Data[i - j];
    end;
    if Den <> 0 then Result[i] := -Num / Den else Result[i] := 0;
  end;
end;

function CMOU(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j: Integer;
  Up, Dn, D: Double;
begin
  QTCheckPeriod(Period, 2, 'CMOU');
  Result := Blank(Data);
  S := QTFirstValid(Data);
  if S < 0 then Exit;
  for i := S + Period to (Length(Data) - 1) do
  begin
    Up := 0;
    Dn := 0;
    for j := i - Period + 1 to i do
    begin
      D := Data[j] - Data[j - 1];
      if D > 0 then Up := Up + D else Dn := Dn - D;
    end;
    if Up + Dn <> 0 then Result[i] := 100 * (Up - Dn) / (Up + Dn) else Result[i] := 0;
  end;
end;

function COPPOCK(const Data: TQDoubleArray; ROC1: Integer; ROC2: Integer;
  WMAPeriod: Integer): TQDoubleArray;
var
  A, B, Sum: TQDoubleArray;
  i: Integer;
begin
  A := ROC(Data, ROC1);
  B := ROC(Data, ROC2);
  Sum := Blank(Data);
  for i := 0 to (Length(Data) - 1) do
    if (not IsNaN(A[i])) and (not IsNaN(B[i])) then Sum[i] := A[i] + B[i];
  Result := WMA(Sum, WMAPeriod);
end;

function CRSI(const Data: TQDoubleArray; RSIPeriod: Integer; StreakPeriod: Integer;
  RankPeriod: Integer): TQDoubleArray;
var
  n, i: Integer;
  Streak, R1, R2, Rk, Roc1: TQDoubleArray;
begin
  n := Length(Data);
  Result := Blank(Data);
  if n < 2 then Exit;
  Streak := Blank(Data);
  Streak[0] := 0;
  Roc1 := Blank(Data);
  for i := 1 to n - 1 do
  begin
    if Data[i] > Data[i - 1] then
    begin
      if Streak[i - 1] > 0 then Streak[i] := Streak[i - 1] + 1 else Streak[i] := 1;
    end
    else if Data[i] < Data[i - 1] then
    begin
      if Streak[i - 1] < 0 then Streak[i] := Streak[i - 1] - 1 else Streak[i] := -1;
    end
    else
      Streak[i] := 0;
    if Data[i - 1] <> 0 then Roc1[i] := (Data[i] / Data[i - 1] - 1) * 100 else Roc1[i] := 0;
  end;
  R1 := RSI(Data, RSIPeriod);
  R2 := RSI(Streak, StreakPeriod);
  Rk := PercentRankOf(Roc1, RankPeriod);
  for i := 0 to n - 1 do
    if (not IsNaN(R1[i])) and (not IsNaN(R2[i])) and (not IsNaN(Rk[i])) then
      Result[i] := (R1[i] + R2[i] + Rk[i]) / 3;
end;

function CTI(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j: Integer;
  Sx, Sy, Sxx, Syy, Sxy, X, D: Double;
begin
  QTCheckPeriod(Period, 2, 'CTI');
  Result := Blank(Data);
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    Sx := 0; Sy := 0; Sxx := 0; Syy := 0; Sxy := 0;
    for j := 0 to Period - 1 do
    begin
      X := j + 1;
      Sx := Sx + X;
      Sy := Sy + Data[i - Period + 1 + j];
      Sxx := Sxx + X * X;
      Syy := Syy + Sqr(Data[i - Period + 1 + j]);
      Sxy := Sxy + X * Data[i - Period + 1 + j];
    end;
    D := (Period * Sxx - Sx * Sx) * (Period * Syy - Sy * Sy);
    if D > 0 then Result[i] := (Period * Sxy - Sx * Sy) / Sqrt(D) else Result[i] := 0;
  end;
end;

function DOSC(const Data: TQDoubleArray; RSIPeriod: Integer; EMA1: Integer; EMA2: Integer;
  SignalPeriod: Integer): TQDoubleArray;
var
  R, Sm, Sg: TQDoubleArray;
  i: Integer;
begin
  R := RSI(Data, RSIPeriod);
  Sm := QTEMA(QTEMA(R, EMA1, 2.0 / (EMA1 + 1)), EMA2, 2.0 / (EMA2 + 1));
  Sg := SMA(Sm, SignalPeriod);
  Result := Blank(Data);
  for i := 0 to (Length(Data) - 1) do
    if not IsNaN(Sg[i]) then Result[i] := Sm[i] - Sg[i];
end;

function DPO(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  M: TQDoubleArray;
  Sh, i: Integer;
begin
  QTCheckPeriod(Period, 2, 'DPO');
  M := SMA(Data, Period);
  Sh := Period div 2 + 1;
  Result := Blank(Data);
  for i := Sh to (Length(Data) - 1) do
    if not IsNaN(M[i]) then Result[i] := Data[i - Sh] - M[i];
end;

function ER(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j: Integer;
  Sum: Double;
begin
  QTCheckPeriod(Period, 1, 'ER');
  Result := Blank(Data);
  S := QTFirstValid(Data);
  if S < 0 then Exit;
  for i := S + Period to (Length(Data) - 1) do
  begin
    Sum := 0;
    for j := i - Period + 1 to i do
      Sum := Sum + Abs(Data[j] - Data[j - 1]);
    if Sum <> 0 then Result[i] := Abs(Data[i] - Data[i - Period]) / Sum else Result[i] := 0;
  end;
end;

function ERI(const High, Low, Close: TQDoubleArray; Period: Integer): TQPair;
var
  E, Bull, Bear: TQDoubleArray;
  i: Integer;
begin
  E := EMA(Close, Period);
  Bull := Blank(Close);
  Bear := Blank(Close);
  for i := 0 to Length(Close) - 1 do
    if not IsNaN(E[i]) then
    begin
      Bull[i] := High[i] - E[i];
      Bear[i] := Low[i] - E[i];
    end;
  Result := Pair(Bull, Bear);
end;

function FISHER(const High, Low: TQDoubleArray; Period: Integer): TQPair;
var
  n, i, j: Integer;
  Fi, Tr: TQDoubleArray;
  HH, LL, Mid, V, PrevV, PrevF, F: Double;
begin
  QTCheckPeriod(Period, 2, 'FISHER');
  QTCheckLength(Length(High), Length(Low), 'FISHER');
  n := Length(High);
  Fi := QTNaNSeries(n);
  Tr := QTNaNSeries(n);
  PrevV := 0;
  PrevF := 0;
  for i := Period - 1 to n - 1 do
  begin
    HH := High[i];
    LL := Low[i];
    for j := i - Period + 1 to i do
    begin
      if High[j] > HH then HH := High[j];
      if Low[j] < LL then LL := Low[j];
    end;
    Mid := (High[i] + Low[i]) / 2;
    if HH > LL then V := 0.66 * ((Mid - LL) / (HH - LL) - 0.5) + 0.67 * PrevV else V := 0.67 * PrevV;
    if V > 0.999 then V := 0.999;
    if V < -0.999 then V := -0.999;
    F := 0.5 * Ln((1 + V) / (1 - V)) + 0.5 * PrevF;
    Fi[i] := F;
    Tr[i] := PrevF;
    PrevV := V;
    PrevF := F;
  end;
  Result := Pair(Fi, Tr);
end;

function FOSC(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  T: TQDoubleArray;
  i: Integer;
begin
  T := TSF(Data, Period);
  Result := Blank(Data);
  for i := 0 to (Length(Data) - 1) do
    if (not IsNaN(T[i])) and (Data[i] <> 0) then Result[i] := 100 * (Data[i] - T[i]) / Data[i];
end;

function IBS(const High, Low, Close: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
begin
  QTCheckLength(Length(High), Length(Low), 'IBS');
  QTCheckLength(Length(High), Length(Close), 'IBS');
  SetLength(Result, Length(High));
  for i := 0 to Length(High) - 1 do
    if High[i] > Low[i] then Result[i] := (Close[i] - Low[i]) / (High[i] - Low[i])
    else Result[i] := 0;
end;

function IMI(const Open, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  n, i, j: Integer;
  G, L: Double;
begin
  QTCheckPeriod(Period, 2, 'IMI');
  QTCheckLength(Length(Open), Length(Close), 'IMI');
  n := Length(Open);
  Result := QTNaNSeries(n);
  for i := Period - 1 to n - 1 do
  begin
    G := 0;
    L := 0;
    for j := i - Period + 1 to i do
      if Close[j] > Open[j] then G := G + (Close[j] - Open[j])
      else L := L + (Open[j] - Close[j]);
    if G + L <> 0 then Result[i] := 100 * G / (G + L) else Result[i] := 0;
  end;
end;

function KDJ(const High, Low, Close: TQDoubleArray; Period: Integer; KSmooth: Integer;
  DSmooth: Integer): TQKDJ;
var
  n, i, j: Integer;
  HH, LL, RSV, K, D: Double;
begin
  QTCheckPeriod(Period, 2, 'KDJ');
  QTCheckLength(Length(High), Length(Low), 'KDJ');
  QTCheckLength(Length(High), Length(Close), 'KDJ');
  n := Length(High);
  Result.K := QTNaNSeries(n);
  Result.D := QTNaNSeries(n);
  Result.J := QTNaNSeries(n);
  K := 50;
  D := 50;
  for i := Period - 1 to n - 1 do
  begin
    HH := High[i];
    LL := Low[i];
    for j := i - Period + 1 to i do
    begin
      if High[j] > HH then HH := High[j];
      if Low[j] < LL then LL := Low[j];
    end;
    if HH > LL then RSV := 100 * (Close[i] - LL) / (HH - LL) else RSV := 50;
    K := (KSmooth - 1) / KSmooth * K + RSV / KSmooth;
    D := (DSmooth - 1) / DSmooth * D + K / DSmooth;
    Result.K[i] := K;
    Result.D[i] := D;
    Result.J[i] := 3 * K - 2 * D;
  end;
end;

function KSTEXT(const Data: TQDoubleArray; R1: Integer; R2: Integer; R3: Integer; R4: Integer;
  S1: Integer; S2: Integer; S3: Integer; S4: Integer; SignalPeriod: Integer;
  MAType: TQMAType): TQPair;
var
  A, B, C, D, K: TQDoubleArray;
  i: Integer;
begin
  A := MA(ROC(Data, R1), S1, MAType);
  B := MA(ROC(Data, R2), S2, MAType);
  C := MA(ROC(Data, R3), S3, MAType);
  D := MA(ROC(Data, R4), S4, MAType);
  K := Blank(Data);
  for i := 0 to (Length(Data) - 1) do
    if (not IsNaN(A[i])) and (not IsNaN(B[i])) and (not IsNaN(C[i])) and (not IsNaN(D[i])) then
      K[i] := A[i] + 2 * B[i] + 3 * C[i] + 4 * D[i];
  Result := Pair(K, MA(K, SignalPeriod, MAType));
end;

function KST(const Data: TQDoubleArray; R1: Integer; R2: Integer; R3: Integer; R4: Integer;
  S1: Integer; S2: Integer; S3: Integer; S4: Integer; SignalPeriod: Integer): TQPair;
begin
  Result := KSTEXT(Data, R1, R2, R3, R4, S1, S2, S3, S4, SignalPeriod, maSMA);
end;

function PSO(const High, Low, Close: TQDoubleArray; StochPeriod: Integer;
  SmoothPeriod: Integer): TQDoubleArray;
var
  FK, NK, SS: TQDoubleArray;
  i, M: Integer;
  E: Double;
begin
  QTCheckPeriod(StochPeriod, 2, 'PSO');
  FK := STOCHF(High, Low, Close, StochPeriod, 1, maSMA).K;
  NK := Blank(Close);
  for i := 0 to Length(Close) - 1 do
    if not IsNaN(FK[i]) then NK[i] := 0.1 * (FK[i] - 50);
  M := Max(Round(Sqrt(SmoothPeriod)), 1);
  SS := EMA(EMA(NK, M), M);
  Result := Blank(Close);
  for i := 0 to Length(Close) - 1 do
    if not IsNaN(SS[i]) then
    begin
      E := Exp(SS[i]);
      Result[i] := (E - 1) / (E + 1);
    end;
end;

function RviCore(const X: TQDoubleArray; StdPeriod, SmoothPeriod: Integer;
  out U, D: TQDoubleArray): Boolean;
var
  SD, Up, Dn: TQDoubleArray;
  i: Integer;
begin
  SD := QTRollingStdDev(X, StdPeriod);
  Up := Blank(X);
  Dn := Blank(X);
  for i := 1 to (Length(X) - 1) do
    if not IsNaN(SD[i]) then
    begin
      if X[i] > X[i - 1] then begin Up[i] := SD[i]; Dn[i] := 0; end
      else if X[i] < X[i - 1] then begin Up[i] := 0; Dn[i] := SD[i]; end
      else begin Up[i] := 0; Dn[i] := 0; end;
    end;
  U := EMA(Up, SmoothPeriod);
  D := EMA(Dn, SmoothPeriod);
  Result := True;
end;

function RVI(const Data: TQDoubleArray; StdPeriod: Integer; SmoothPeriod: Integer): TQDoubleArray;
var
  U, D: TQDoubleArray;
  i: Integer;
begin
  QTCheckPeriod(StdPeriod, 2, 'RVI');
  RviCore(Data, StdPeriod, SmoothPeriod, U, D);
  Result := Blank(Data);
  for i := 0 to (Length(Data) - 1) do
    if (not IsNaN(U[i])) and (not IsNaN(D[i])) then
      if U[i] + D[i] <> 0 then Result[i] := 100 * U[i] / (U[i] + D[i]) else Result[i] := 50;
end;

function RVIR(const High, Low: TQDoubleArray; StdPeriod: Integer; SmoothPeriod: Integer): TQDoubleArray;
var
  RH, RL: TQDoubleArray;
  i: Integer;
begin
  QTCheckLength(Length(High), Length(Low), 'RVIR');
  RH := RVI(High, StdPeriod, SmoothPeriod);
  RL := RVI(Low, StdPeriod, SmoothPeriod);
  Result := Blank(High);
  for i := 0 to Length(High) - 1 do
    if (not IsNaN(RH[i])) and (not IsNaN(RL[i])) then Result[i] := (RH[i] + RL[i]) / 2;
end;

function SMI(const High, Low, Close: TQDoubleArray; Period: Integer; Smooth1: Integer;
  Smooth2: Integer; SignalPeriod: Integer): TQPair;
var
  HH, LL, Dd, Rr, DS, RS, Line: TQDoubleArray;
  i: Integer;
begin
  QTCheckPeriod(Period, 2, 'SMI');
  HH := RollingMax(High, Period);
  LL := RollingMin(Low, Period);
  Dd := Blank(Close);
  Rr := Blank(Close);
  for i := 0 to Length(Close) - 1 do
    if not IsNaN(HH[i]) then
    begin
      Dd[i] := Close[i] - (HH[i] + LL[i]) / 2;
      Rr[i] := HH[i] - LL[i];
    end;
  DS := EMA(EMA(Dd, Smooth1), Smooth2);
  RS := EMA(EMA(Rr, Smooth1), Smooth2);
  Line := Blank(Close);
  for i := 0 to Length(Close) - 1 do
    if (not IsNaN(DS[i])) and (not IsNaN(RS[i])) then
      if RS[i] <> 0 then Line[i] := 100 * DS[i] / (RS[i] / 2) else Line[i] := 0;
  Result := Pair(Line, EMA(Line, SignalPeriod));
end;

function SQZMOM(const High, Low, Close: TQDoubleArray; BBPeriod: Integer; BBMult: Double;
  KCPeriod: Integer; KCMult: Double): TQPair;
var
  n, i: Integer;
  Basis, SD, MAK, TR, RangeMA, HH, LL, Src, Mom, Sq: TQDoubleArray;
  BU, BL, KU, KL: Double;
begin
  n := Length(Close);
  Basis := SMA(Close, BBPeriod);
  SD := QTRollingStdDev(Close, BBPeriod);
  MAK := SMA(Close, KCPeriod);
  TR := TRANGE(High, Low, Close);
  RangeMA := SMA(TR, KCPeriod);
  HH := RollingMax(High, KCPeriod);
  LL := RollingMin(Low, KCPeriod);
  Src := Blank(Close);
  Sq := Blank(Close);
  for i := 0 to n - 1 do
  begin
    if (not IsNaN(HH[i])) and (not IsNaN(MAK[i])) then
      Src[i] := Close[i] - ((HH[i] + LL[i]) / 2 + MAK[i]) / 2;
    if (not IsNaN(Basis[i])) and (not IsNaN(RangeMA[i])) and (not IsNaN(MAK[i])) then
    begin
      BU := Basis[i] + BBMult * SD[i];
      BL := Basis[i] - BBMult * SD[i];
      KU := MAK[i] + KCMult * RangeMA[i];
      KL := MAK[i] - KCMult * RangeMA[i];
      if (BL > KL) and (BU < KU) then Sq[i] := 1 else Sq[i] := 0;
    end;
  end;
  Mom := LINEARREG(Src, KCPeriod);
  Result := Pair(Mom, Sq);
end;

function STC(const Data: TQDoubleArray; FastPeriod: Integer; SlowPeriod: Integer;
  CyclePeriod: Integer; Smooth: Double): TQDoubleArray;
var
  M, HH, LL, K1, D1, HH2, LL2, K2: TQDoubleArray;
  i: Integer;
begin
  M := APO(Data, FastPeriod, SlowPeriod, maEMA);
  HH := RollingMax(M, CyclePeriod);
  LL := RollingMin(M, CyclePeriod);
  K1 := Blank(Data);
  for i := 0 to (Length(Data) - 1) do
    if not IsNaN(HH[i]) then
      if HH[i] > LL[i] then K1[i] := 100 * (M[i] - LL[i]) / (HH[i] - LL[i]) else K1[i] := 0;
  D1 := RecursiveSmooth(K1, Smooth);
  HH2 := RollingMax(D1, CyclePeriod);
  LL2 := RollingMin(D1, CyclePeriod);
  K2 := Blank(Data);
  for i := 0 to (Length(Data) - 1) do
    if not IsNaN(HH2[i]) then
      if HH2[i] > LL2[i] then K2[i] := 100 * (D1[i] - LL2[i]) / (HH2[i] - LL2[i]) else K2[i] := 0;
  Result := RecursiveSmooth(K2, Smooth);
end;

function TSI(const Data: TQDoubleArray; LongPeriod: Integer; ShortPeriod: Integer): TQDoubleArray;
var
  M, AM, N, D: TQDoubleArray;
  i: Integer;
begin
  M := Diff1(Data);
  AM := Blank(Data);
  for i := 1 to (Length(Data) - 1) do AM[i] := Abs(M[i]);
  N := EMA(EMA(M, LongPeriod), ShortPeriod);
  D := EMA(EMA(AM, LongPeriod), ShortPeriod);
  Result := Blank(Data);
  for i := 0 to (Length(Data) - 1) do
    if (not IsNaN(N[i])) and (not IsNaN(D[i])) then
      if D[i] <> 0 then Result[i] := 100 * N[i] / D[i] else Result[i] := 0;
end;

function VORTEX(const High, Low, Close: TQDoubleArray; Period: Integer): TQPair;
var
  n, i, j: Integer;
  TR, VP, VM: TQDoubleArray;
  SP, SM, ST: Double;
begin
  QTCheckPeriod(Period, 2, 'VORTEX');
  n := Length(High);
  TR := TRANGE(High, Low, Close);
  VP := QTNaNSeries(n);
  VM := QTNaNSeries(n);
  for i := Period to n - 1 do
  begin
    SP := 0; SM := 0; ST := 0;
    for j := i - Period + 1 to i do
    begin
      SP := SP + Abs(High[j] - Low[j - 1]);
      SM := SM + Abs(Low[j] - High[j - 1]);
      ST := ST + TR[j];
    end;
    if ST <> 0 then
    begin
      VP[i] := SP / ST;
      VM[i] := SM / ST;
    end
    else
    begin
      VP[i] := 0;
      VM[i] := 0;
    end;
  end;
  Result := Pair(VP, VM);
end;

function WAVETREND(const High, Low, Close: TQDoubleArray; ChannelPeriod: Integer;
  AveragePeriod: Integer): TQPair;
var
  AP, ESA, AD, CI, WT1: TQDoubleArray;
  i: Integer;
begin
  QTCheckLength(Length(High), Length(Low), 'WAVETREND');
  QTCheckLength(Length(High), Length(Close), 'WAVETREND');
  SetLength(AP, Length(High));
  for i := 0 to Length(High) - 1 do AP[i] := (High[i] + Low[i] + Close[i]) / 3;
  ESA := EMA(AP, ChannelPeriod);
  AD := Blank(AP);
  for i := 0 to (Length(AP) - 1) do
    if not IsNaN(ESA[i]) then AD[i] := Abs(AP[i] - ESA[i]);
  AD := EMA(AD, ChannelPeriod);
  CI := Blank(AP);
  for i := 0 to (Length(AP) - 1) do
    if (not IsNaN(ESA[i])) and (not IsNaN(AD[i])) then
      if AD[i] <> 0 then CI[i] := (AP[i] - ESA[i]) / (0.015 * AD[i]) else CI[i] := 0;
  WT1 := EMA(CI, AveragePeriod);
  Result := Pair(WT1, SMA(WT1, 4));
end;

function SiCore(const Open, High, Low, Close: TQDoubleArray; T: Double): TQDoubleArray;
var
  i: Integer;
  A, B, C, D, R, K, Nn: Double;
begin
  QTCheckLength(Length(Open), Length(High), 'SI');
  QTCheckLength(Length(Open), Length(Low), 'SI');
  QTCheckLength(Length(Open), Length(Close), 'SI');
  Result := QTNaNSeries(Length(Open));
  for i := 1 to Length(Open) - 1 do
  begin
    A := Abs(High[i] - Close[i - 1]);
    B := Abs(Low[i] - Close[i - 1]);
    C := Abs(High[i] - Low[i]);
    D := Abs(Close[i - 1] - Open[i - 1]);
    if (A >= B) and (A >= C) then R := A - 0.5 * B + 0.25 * D
    else if (B >= A) and (B >= C) then R := B - 0.5 * A + 0.25 * D
    else R := C + 0.25 * D;
    K := Max(A, B);
    Nn := (Close[i] - Close[i - 1]) + 0.5 * (Close[i] - Open[i]) + 0.25 * (Close[i - 1] - Open[i - 1]);
    if (R <> 0) and (T <> 0) then Result[i] := 50 * Nn / R * K / T else Result[i] := 0;
  end;
end;

function SI(const Open, High, Low, Close: TQDoubleArray; LimitMove: Double): TQDoubleArray;
begin
  Result := SiCore(Open, High, Low, Close, LimitMove);
end;

function ASI(const Open, High, Low, Close: TQDoubleArray; LimitMove: Double): TQDoubleArray;
var
  S: TQDoubleArray;
  i: Integer;
  Acc: Double;
begin
  S := SiCore(Open, High, Low, Close, LimitMove);
  Result := Blank(S);
  Acc := 0;
  for i := 1 to (Length(S) - 1) do
  begin
    Acc := Acc + S[i];
    Result[i] := Acc;
  end;
end;

{ ---------- statistics ---------- }

function AVGDEV(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  S, i, j: Integer;
  Mean, Dev: Double;
begin
  QTCheckPeriod(Period, 2, 'AVGDEV');
  Result := Blank(Data);
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    Mean := 0;
    for j := i - Period + 1 to i do Mean := Mean + Data[j];
    Mean := Mean / Period;
    Dev := 0;
    for j := i - Period + 1 to i do Dev := Dev + Abs(Data[j] - Mean);
    Result[i] := Dev / Period;
  end;
end;

function Moments(const Data: TQDoubleArray; Period: Integer; Kurt: Boolean): TQDoubleArray;
var
  S, i, j: Integer;
  Mean, M2, M3, M4, D: Double;
begin
  QTCheckPeriod(Period, 3, 'Moments');
  Result := Blank(Data);
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    Mean := 0;
    for j := i - Period + 1 to i do Mean := Mean + Data[j];
    Mean := Mean / Period;
    M2 := 0; M3 := 0; M4 := 0;
    for j := i - Period + 1 to i do
    begin
      D := Data[j] - Mean;
      M2 := M2 + D * D;
      M3 := M3 + D * D * D;
      M4 := M4 + D * D * D * D;
    end;
    M2 := M2 / Period;
    M3 := M3 / Period;
    M4 := M4 / Period;
    if M2 > 0 then
      if Kurt then Result[i] := M4 / (M2 * M2) - 3.0
      else Result[i] := M3 / (M2 * Sqrt(M2))
    else
      Result[i] := 0;
  end;
end;

function SkewRoll(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  Result := Moments(Data, Period, False);
end;

function KurtosisRoll(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  Result := Moments(Data, Period, True);
end;

function PercentileRoll(const Data: TQDoubleArray; Period: Integer;
  Percentile: Double): TQDoubleArray;
var
  S, i, j, k, Rank: Integer;
  W: TQDoubleArray;
  T: Double;
begin
  QTCheckPeriod(Period, 1, 'PercentileRoll');
  Result := Blank(Data);
  S := QTFirstValid(Data);
  if (S < 0) or (Length(Data) - S < Period) then Exit;
  SetLength(W, Period);
  for i := S + Period - 1 to (Length(Data) - 1) do
  begin
    for j := 0 to Period - 1 do W[j] := Data[i - Period + 1 + j];
    for j := 1 to Period - 1 do
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
    Rank := Ceil(Percentile / 100.0 * Period);
    if Rank < 1 then Rank := 1;
    if Rank > Period then Rank := Period;
    Result[i] := W[Rank - 1];
  end;
end;

function PERCENTRANK(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  QTCheckPeriod(Period, 1, 'PERCENTRANK');
  Result := PercentRankOf(Data, Period);
end;

{ ---------- volume ---------- }

function EFI(const Close, Volume: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  F: TQDoubleArray;
  i: Integer;
begin
  QTCheckLength(Length(Close), Length(Volume), 'EFI');
  F := Blank(Close);
  for i := 1 to (Length(Close) - 1) do F[i] := Volume[i] * (Close[i] - Close[i - 1]);
  Result := EMA(F, Period);
end;

function EMV(const High, Low, Volume: TQDoubleArray; Period: Integer; VolumeScale: Double): TQDoubleArray;
var
  E: TQDoubleArray;
  i: Integer;
  DM, BR: Double;
begin
  QTCheckLength(Length(High), Length(Low), 'EMV');
  QTCheckLength(Length(High), Length(Volume), 'EMV');
  E := QTNaNSeries(Length(High));
  for i := 1 to Length(High) - 1 do
  begin
    DM := (High[i] + Low[i]) / 2 - (High[i - 1] + Low[i - 1]) / 2;
    if (High[i] > Low[i]) and (Volume[i] > 0) then
    begin
      BR := (Volume[i] / VolumeScale) / (High[i] - Low[i]);
      E[i] := DM / BR;
    end
    else
      E[i] := 0;
  end;
  Result := SMA(E, Period);
end;

function KVO(const High, Low, Close, Volume: TQDoubleArray; FastPeriod: Integer;
  SlowPeriod: Integer; SignalPeriod: Integer): TQPair;
var
  n, i, Trend, PrevTrend: Integer;
  VF, F, S, K: TQDoubleArray;
  DM, CM, PrevDM, PrevCM: Double;
begin
  QTCheckLength(Length(High), Length(Low), 'KVO');
  QTCheckLength(Length(High), Length(Close), 'KVO');
  QTCheckLength(Length(High), Length(Volume), 'KVO');
  n := Length(High);
  VF := QTNaNSeries(n);
  PrevTrend := 0;
  PrevDM := 0;
  PrevCM := 0;
  if n > 0 then
  begin
    PrevDM := High[0] - Low[0];
    PrevCM := PrevDM;
  end;
  for i := 1 to n - 1 do
  begin
    DM := High[i] - Low[i];
    if (High[i] + Low[i] + Close[i]) > (High[i - 1] + Low[i - 1] + Close[i - 1]) then Trend := 1 else Trend := -1;
    if (i > 1) and (Trend = PrevTrend) then CM := PrevCM + DM else CM := PrevDM + DM;
    if CM <> 0 then VF[i] := Volume[i] * Abs(2 * DM / CM - 1) * Trend * 100 else VF[i] := 0;
    PrevTrend := Trend;
    PrevDM := DM;
    PrevCM := CM;
  end;
  F := EMA(VF, FastPeriod);
  S := EMA(VF, SlowPeriod);
  K := QTNaNSeries(n);
  for i := 0 to n - 1 do
    if (not IsNaN(F[i])) and (not IsNaN(S[i])) then K[i] := F[i] - S[i];
  Result := Pair(K, EMA(K, SignalPeriod));
end;

function MARKETFI(const High, Low, Volume: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
begin
  QTCheckLength(Length(High), Length(Low), 'MARKETFI');
  QTCheckLength(Length(High), Length(Volume), 'MARKETFI');
  SetLength(Result, Length(High));
  for i := 0 to Length(High) - 1 do
    if Volume[i] <> 0 then Result[i] := (High[i] - Low[i]) / Volume[i] else Result[i] := 0;
end;

function VolIndex(const Close, Volume: TQDoubleArray; Negative: Boolean): TQDoubleArray;
var
  i: Integer;
  V: Double;
  Hit: Boolean;
begin
  QTCheckLength(Length(Close), Length(Volume), 'VolumeIndex');
  SetLength(Result, Length(Close));
  V := 1000;
  for i := 0 to Length(Close) - 1 do
  begin
    if i > 0 then
    begin
      if Negative then Hit := Volume[i] < Volume[i - 1] else Hit := Volume[i] > Volume[i - 1];
      if Hit and (Close[i - 1] <> 0) then V := V * (1 + (Close[i] - Close[i - 1]) / Close[i - 1]);
    end;
    Result[i] := V;
  end;
end;

function NVI(const Close, Volume: TQDoubleArray): TQDoubleArray;
begin
  Result := VolIndex(Close, Volume, True);
end;

function PVI(const Close, Volume: TQDoubleArray): TQDoubleArray;
begin
  Result := VolIndex(Close, Volume, False);
end;

function PVO(const Volume: TQDoubleArray; FastPeriod: Integer; SlowPeriod: Integer;
  SignalPeriod: Integer): TQMACD;
var
  F, S, Line: TQDoubleArray;
  i: Integer;
begin
  F := EMA(Volume, FastPeriod);
  S := EMA(Volume, SlowPeriod);
  Line := Blank(Volume);
  for i := 0 to (Length(Volume) - 1) do
    if (not IsNaN(F[i])) and (not IsNaN(S[i])) and (S[i] <> 0) then
      Line[i] := (F[i] - S[i]) / S[i] * 100;
  Result.MACD := Line;
  Result.Signal := EMA(Line, SignalPeriod);
  Result.Hist := Blank(Volume);
  for i := 0 to (Length(Volume) - 1) do
    if not IsNaN(Result.Signal[i]) then Result.Hist[i] := Line[i] - Result.Signal[i];
end;

function PVT(const Close, Volume: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
  Acc: Double;
begin
  QTCheckLength(Length(Close), Length(Volume), 'PVT');
  SetLength(Result, Length(Close));
  Acc := 0;
  for i := 0 to Length(Close) - 1 do
  begin
    if (i > 0) and (Close[i - 1] <> 0) then
      Acc := Acc + Volume[i] * (Close[i] - Close[i - 1]) / Close[i - 1];
    Result[i] := Acc;
  end;
end;

function QSTICK(const Open, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  D: TQDoubleArray;
  i: Integer;
begin
  QTCheckLength(Length(Open), Length(Close), 'QSTICK');
  SetLength(D, Length(Open));
  for i := 0 to Length(Open) - 1 do D[i] := Close[i] - Open[i];
  Result := SMA(D, Period);
end;

function RVOL(const Volume: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  M: TQDoubleArray;
  i: Integer;
begin
  M := SMA(Volume, Period);
  Result := Blank(Volume);
  for i := 0 to (Length(Volume) - 1) do
    if (not IsNaN(M[i])) and (M[i] <> 0) then Result[i] := Volume[i] / M[i];
end;

function VWAP(const High, Low, Close, Volume: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
  CV, CPV: Double;
begin
  QTCheckLength(Length(High), Length(Low), 'VWAP');
  QTCheckLength(Length(High), Length(Close), 'VWAP');
  QTCheckLength(Length(High), Length(Volume), 'VWAP');
  SetLength(Result, Length(High));
  CV := 0;
  CPV := 0;
  for i := 0 to Length(High) - 1 do
  begin
    CV := CV + Volume[i];
    CPV := CPV + (High[i] + Low[i] + Close[i]) / 3 * Volume[i];
    if CV <> 0 then Result[i] := CPV / CV else Result[i] := (High[i] + Low[i] + Close[i]) / 3;
  end;
end;

function WAD(const High, Low, Close: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
  Acc, TRH, TRL: Double;
begin
  QTCheckLength(Length(High), Length(Low), 'WAD');
  QTCheckLength(Length(High), Length(Close), 'WAD');
  SetLength(Result, Length(High));
  Acc := 0;
  for i := 0 to Length(High) - 1 do
  begin
    if i > 0 then
    begin
      TRH := Max(High[i], Close[i - 1]);
      TRL := Min(Low[i], Close[i - 1]);
      if Close[i] > Close[i - 1] then Acc := Acc + (Close[i] - TRL)
      else if Close[i] < Close[i - 1] then Acc := Acc + (Close[i] - TRH);
    end;
    Result[i] := Acc;
  end;
end;

{ ---------- structure ---------- }

function FRACTAL(const High, Low: TQDoubleArray): TQPair;
var
  n, i: Integer;
  Up, Dn: TQDoubleArray;
begin
  QTCheckLength(Length(High), Length(Low), 'FRACTAL');
  n := Length(High);
  Up := QTNaNSeries(n);
  Dn := QTNaNSeries(n);
  for i := 2 to n - 3 do
  begin
    if (High[i] > High[i - 1]) and (High[i] > High[i - 2]) and
       (High[i] > High[i + 1]) and (High[i] > High[i + 2]) then
      Up[i] := High[i];
    if (Low[i] < Low[i - 1]) and (Low[i] < Low[i - 2]) and
       (Low[i] < Low[i + 1]) and (Low[i] < Low[i + 2]) then
      Dn[i] := Low[i];
  end;
  Result := Pair(Up, Dn);
end;

function ZIGZAG(const High, Low: TQDoubleArray; Deviation: Double): TQDoubleArray;
var
  n, i, Dir, CurIdx, HiIdx, LoIdx: Integer;
  CurVal, HiVal, LoVal, Dev: Double;
begin
  QTCheckLength(Length(High), Length(Low), 'ZIGZAG');
  n := Length(High);
  Result := QTNaNSeries(n);
  if n < 2 then Exit;
  Dev := Deviation / 100.0;
  Dir := 0;
  HiVal := High[0]; HiIdx := 0;
  LoVal := Low[0]; LoIdx := 0;
  CurVal := 0; CurIdx := 0;
  for i := 1 to n - 1 do
  begin
    if Dir = 0 then
    begin
      if High[i] > HiVal then begin HiVal := High[i]; HiIdx := i; end;
      if Low[i] < LoVal then begin LoVal := Low[i]; LoIdx := i; end;
      if Low[i] <= HiVal * (1 - Dev) then
      begin
        Result[HiIdx] := HiVal;
        Dir := -1;
        CurVal := Low[i];
        CurIdx := i;
      end
      else if High[i] >= LoVal * (1 + Dev) then
      begin
        Result[LoIdx] := LoVal;
        Dir := 1;
        CurVal := High[i];
        CurIdx := i;
      end;
    end
    else if Dir = 1 then
    begin
      if High[i] > CurVal then begin CurVal := High[i]; CurIdx := i; end
      else if Low[i] <= CurVal * (1 - Dev) then
      begin
        Result[CurIdx] := CurVal;
        Dir := -1;
        CurVal := Low[i];
        CurIdx := i;
      end;
    end
    else
    begin
      if Low[i] < CurVal then begin CurVal := Low[i]; CurIdx := i; end
      else if High[i] >= CurVal * (1 + Dev) then
      begin
        Result[CurIdx] := CurVal;
        Dir := 1;
        CurVal := High[i];
        CurIdx := i;
      end;
    end;
  end;
  if Dir <> 0 then
    Result[CurIdx] := CurVal; // last (still provisional) pivot
end;

end.
