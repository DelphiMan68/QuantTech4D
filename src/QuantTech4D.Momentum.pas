{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ Momentum indicators: RSI, MACD, Stochastic, ADX family, CCI, ROC family, etc. }
unit QuantTech4D.Momentum;

{$I QuantTech4D.inc}

interface

uses
  SysUtils, Math, QuantTech4D.Types, QuantTech4D.Core, QuantTech4D.Overlap;

/// Relative Strength Index (Wilder smoothing).
function RSI(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Chande Momentum Oscillator.
function CMO(const Data: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// MACD (fast EMA is seeded at the slow EMA's first bar, like TA-Lib).
function MACD(const Data: TQDoubleArray; FastPeriod: Integer = 12;
  SlowPeriod: Integer = 26; SignalPeriod: Integer = 9): TQMACD;
/// MACD with fixed 12/26 periods and TA-Lib's legacy 0.15 / 0.075 factors.
function MACDFIX(const Data: TQDoubleArray; SignalPeriod: Integer = 9): TQMACD;
/// Fast Stochastic.
function STOCHF(const High, Low, Close: TQDoubleArray; FastKPeriod: Integer = 5;
  FastDPeriod: Integer = 3; FastDMAType: TQMAType = maSMA): TQStoch;
/// Slow Stochastic.
function STOCH(const High, Low, Close: TQDoubleArray; FastKPeriod: Integer = 5;
  SlowKPeriod: Integer = 3; SlowKMAType: TQMAType = maSMA;
  SlowDPeriod: Integer = 3; SlowDMAType: TQMAType = maSMA): TQStoch;
/// Stochastic RSI.
function STOCHRSI(const Data: TQDoubleArray; Period: Integer = 14;
  FastKPeriod: Integer = 5; FastDPeriod: Integer = 3;
  FastDMAType: TQMAType = maSMA): TQStoch;
/// Wilder-smoothed plus directional movement.
function PLUS_DM(const High, Low: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Wilder-smoothed minus directional movement.
function MINUS_DM(const High, Low: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
function PLUS_DI(const High, Low, Close: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
function MINUS_DI(const High, Low, Close: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Directional Movement Index.
function DX(const High, Low, Close: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Average Directional Movement Index.
function ADX(const High, Low, Close: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Average Directional Movement Index Rating.
function ADXR(const High, Low, Close: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Commodity Channel Index.
function CCI(const High, Low, Close: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Momentum: price - price[Period ago].
function MOM(const Data: TQDoubleArray; Period: Integer = 10): TQDoubleArray;
/// Rate of change: ((price/prev) - 1) * 100.
function ROC(const Data: TQDoubleArray; Period: Integer = 10): TQDoubleArray;
/// Rate of change percentage: (price - prev) / prev.
function ROCP(const Data: TQDoubleArray; Period: Integer = 10): TQDoubleArray;
/// Rate of change ratio: price / prev.
function ROCR(const Data: TQDoubleArray; Period: Integer = 10): TQDoubleArray;
/// Rate of change ratio, 100 scale: price / prev * 100.
function ROCR100(const Data: TQDoubleArray; Period: Integer = 10): TQDoubleArray;
/// Williams' %R.
function WILLR(const High, Low, Close: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Absolute Price Oscillator.
function APO(const Data: TQDoubleArray; FastPeriod: Integer = 12;
  SlowPeriod: Integer = 26; MAType: TQMAType = maSMA): TQDoubleArray;
/// Percentage Price Oscillator.
function PPO(const Data: TQDoubleArray; FastPeriod: Integer = 12;
  SlowPeriod: Integer = 26; MAType: TQMAType = maSMA): TQDoubleArray;
/// Aroon (down and up).
function AROON(const High, Low: TQDoubleArray; Period: Integer = 14): TQAroon;
/// Aroon Oscillator (up - down).
function AROONOSC(const High, Low: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// Balance Of Power.
function BOP(const Open, High, Low, Close: TQDoubleArray): TQDoubleArray;
/// Money Flow Index.
function MFI(const High, Low, Close, Volume: TQDoubleArray; Period: Integer = 14): TQDoubleArray;
/// 1-period rate of change of a triple smoothed EMA.
function TRIX(const Data: TQDoubleArray; Period: Integer = 30): TQDoubleArray;
/// Ultimate Oscillator.
function ULTOSC(const High, Low, Close: TQDoubleArray; Period1: Integer = 7;
  Period2: Integer = 14; Period3: Integer = 28): TQDoubleArray;
/// Awesome Oscillator: SMA(median,5) - SMA(median,34).
function AO(const High, Low: TQDoubleArray; FastPeriod: Integer = 5;
  SlowPeriod: Integer = 34): TQDoubleArray;

implementation

{ ---------- RSI / CMO ---------- }

function WilderMomentum(const Data: TQDoubleArray; Period: Integer;
  IsRSI: Boolean): TQDoubleArray;
var
  n, S, i: Integer;
  Gain, Loss, Diff, AvgG, AvgL, Tot: Double;

  procedure Emit(Idx: Integer);
  begin
    Tot := AvgG + AvgL;
    if Tot = 0 then
      Result[Idx] := 0
    else if IsRSI then
      Result[Idx] := 100 * AvgG / Tot
    else
      Result[Idx] := 100 * (AvgG - AvgL) / Tot;
  end;

begin
  n := Length(Data);
  Result := QTNaNSeries(n);
  S := QTFirstValid(Data);
  if (S < 0) or (n - S <= Period) then Exit;
  Gain := 0;
  Loss := 0;
  for i := S + 1 to S + Period do
  begin
    Diff := Data[i] - Data[i - 1];
    if Diff > 0 then Gain := Gain + Diff else Loss := Loss - Diff;
  end;
  AvgG := Gain / Period;
  AvgL := Loss / Period;
  Emit(S + Period);
  for i := S + Period + 1 to n - 1 do
  begin
    Diff := Data[i] - Data[i - 1];
    if Diff > 0 then
    begin
      AvgG := (AvgG * (Period - 1) + Diff) / Period;
      AvgL := AvgL * (Period - 1) / Period;
    end
    else
    begin
      AvgG := AvgG * (Period - 1) / Period;
      AvgL := (AvgL * (Period - 1) - Diff) / Period;
    end;
    Emit(i);
  end;
end;

function RSI(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  QTCheckPeriod(Period, 2, 'RSI');
  Result := WilderMomentum(Data, Period, True);
end;

function CMO(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  QTCheckPeriod(Period, 2, 'CMO');
  Result := WilderMomentum(Data, Period, False);
end;

{ ---------- MACD ---------- }

function MacdCore(const Data: TQDoubleArray; Fast, Slow, Signal: Integer;
  KFast, KSlow: Double): TQMACD;
var
  n, S, Seed, i: Integer;
  FE, SE, Line: TQDoubleArray;
begin
  n := Length(Data);
  Result.MACD := QTNaNSeries(n);
  Result.Signal := QTNaNSeries(n);
  Result.Hist := QTNaNSeries(n);
  S := QTFirstValid(Data);
  if (S < 0) or (n - S < Slow + Signal - 1) then Exit;
  Seed := S + Slow - 1;
  SE := QTEMAAt(Data, Slow, KSlow, Seed);
  FE := QTEMAAt(Data, Fast, KFast, Seed);
  Line := QTNaNSeries(n);
  for i := Seed to n - 1 do
    Line[i] := FE[i] - SE[i];
  Result.MACD := Line;
  Result.Signal := QTEMA(Line, Signal, 2.0 / (Signal + 1));
  for i := 0 to n - 1 do
    if not IsNaN(Result.Signal[i]) then
      Result.Hist[i] := Line[i] - Result.Signal[i];
end;

function MACD(const Data: TQDoubleArray; FastPeriod: Integer; SlowPeriod: Integer;
  SignalPeriod: Integer): TQMACD;
var
  T: Integer;
begin
  QTCheckPeriod(FastPeriod, 2, 'MACD');
  QTCheckPeriod(SlowPeriod, 2, 'MACD');
  QTCheckPeriod(SignalPeriod, 1, 'MACD');
  if FastPeriod > SlowPeriod then
  begin
    T := FastPeriod; FastPeriod := SlowPeriod; SlowPeriod := T;
  end;
  Result := MacdCore(Data, FastPeriod, SlowPeriod, SignalPeriod,
    2.0 / (FastPeriod + 1), 2.0 / (SlowPeriod + 1));
end;

function MACDFIX(const Data: TQDoubleArray; SignalPeriod: Integer): TQMACD;
begin
  QTCheckPeriod(SignalPeriod, 1, 'MACDFIX');
  Result := MacdCore(Data, 12, 26, SignalPeriod, 0.15, 0.075);
end;

{ ---------- Stochastic ---------- }

// Raw %K of a single series (used by STOCHRSI) or of H/L/C (Single = nil).
function FastKHLC(const High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  i, j: Integer;
  HH, LL, Diff: Double;
begin
  QTCheckLength(Length(High), Length(Low), 'STOCH');
  QTCheckLength(Length(High), Length(Close), 'STOCH');
  Result := QTNaNSeries(Length(High));
  for i := Period - 1 to (Length(High) - 1) do
  begin
    HH := High[i];
    LL := Low[i];
    for j := i - Period + 1 to i do
    begin
      if High[j] > HH then HH := High[j];
      if Low[j] < LL then LL := Low[j];
    end;
    Diff := HH - LL;
    if Diff <> 0 then Result[i] := 100 * (Close[i] - LL) / Diff else Result[i] := 0;
  end;
end;

function STOCHF(const High, Low, Close: TQDoubleArray; FastKPeriod: Integer;
  FastDPeriod: Integer; FastDMAType: TQMAType): TQStoch;
begin
  QTCheckPeriod(FastKPeriod, 1, 'STOCHF');
  QTCheckPeriod(FastDPeriod, 1, 'STOCHF');
  Result.K := FastKHLC(High, Low, Close, FastKPeriod);
  Result.D := MA(Result.K, FastDPeriod, FastDMAType);
end;

function STOCH(const High, Low, Close: TQDoubleArray; FastKPeriod: Integer;
  SlowKPeriod: Integer; SlowKMAType: TQMAType; SlowDPeriod: Integer;
  SlowDMAType: TQMAType): TQStoch;
var
  FK: TQDoubleArray;
begin
  QTCheckPeriod(FastKPeriod, 1, 'STOCH');
  QTCheckPeriod(SlowKPeriod, 1, 'STOCH');
  QTCheckPeriod(SlowDPeriod, 1, 'STOCH');
  FK := FastKHLC(High, Low, Close, FastKPeriod);
  Result.K := MA(FK, SlowKPeriod, SlowKMAType);
  Result.D := MA(Result.K, SlowDPeriod, SlowDMAType);
end;

function STOCHRSI(const Data: TQDoubleArray; Period: Integer; FastKPeriod: Integer;
  FastDPeriod: Integer; FastDMAType: TQMAType): TQStoch;
var
  R: TQDoubleArray;
  S, i, j: Integer;
  HH, LL, Diff: Double;
begin
  QTCheckPeriod(Period, 2, 'STOCHRSI');
  QTCheckPeriod(FastKPeriod, 1, 'STOCHRSI');
  QTCheckPeriod(FastDPeriod, 1, 'STOCHRSI');
  R := RSI(Data, Period);
  Result.K := QTNaNSeries(Length(Data));
  S := QTFirstValid(R);
  if S >= 0 then
    for i := S + FastKPeriod - 1 to (Length(R) - 1) do
    begin
      HH := R[i];
      LL := R[i];
      for j := i - FastKPeriod + 1 to i do
      begin
        if R[j] > HH then HH := R[j];
        if R[j] < LL then LL := R[j];
      end;
      Diff := HH - LL;
      if Diff <> 0 then Result.K[i] := 100 * (R[i] - LL) / Diff else Result.K[i] := 0;
    end;
  Result.D := MA(Result.K, FastDPeriod, FastDMAType);
end;

{ ---------- Directional movement family ---------- }

procedure WilderDM(const High, Low, Close: TQDoubleArray; Period: Integer;
  out PDM, MDM, TRs: TQDoubleArray);
var
  n, i: Integer;
  SP, SM, ST, DP, DM, T: Double;

  procedure Raw(Idx: Integer);
  var
    DiffP, DiffM, V: Double;
  begin
    DiffP := High[Idx] - High[Idx - 1];
    DiffM := Low[Idx - 1] - Low[Idx];
    if (DiffP > 0) and (DiffP > DiffM) then DP := DiffP else DP := 0;
    if (DiffM > 0) and (DiffM > DiffP) then DM := DiffM else DM := 0;
    T := High[Idx] - Low[Idx];
    V := Abs(High[Idx] - Close[Idx - 1]);
    if V > T then T := V;
    V := Abs(Low[Idx] - Close[Idx - 1]);
    if V > T then T := V;
  end;

begin
  QTCheckLength(Length(High), Length(Low), 'DirectionalMovement');
  QTCheckLength(Length(High), Length(Close), 'DirectionalMovement');
  n := Length(High);
  PDM := QTNaNSeries(n);
  MDM := QTNaNSeries(n);
  TRs := QTNaNSeries(n);
  if n <= Period then Exit;
  SP := 0; SM := 0; ST := 0;
  for i := 1 to Period - 1 do
  begin
    Raw(i);
    SP := SP + DP; SM := SM + DM; ST := ST + T;
  end;
  PDM[Period - 1] := SP;
  MDM[Period - 1] := SM;
  TRs[Period - 1] := ST;
  for i := Period to n - 1 do
  begin
    Raw(i);
    SP := SP - SP / Period + DP;
    SM := SM - SM / Period + DM;
    ST := ST - ST / Period + T;
    PDM[i] := SP;
    MDM[i] := SM;
    TRs[i] := ST;
  end;
end;

function PLUS_DM(const High, Low: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  P, M, T: TQDoubleArray;
begin
  QTCheckPeriod(Period, 2, 'PLUS_DM');
  WilderDM(High, Low, High, Period, P, M, T); // Close unused for DM values
  Result := P;
end;

function MINUS_DM(const High, Low: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  P, M, T: TQDoubleArray;
begin
  QTCheckPeriod(Period, 2, 'MINUS_DM');
  WilderDM(High, Low, High, Period, P, M, T);
  Result := M;
end;

function PLUS_DI(const High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  P, M, T: TQDoubleArray;
  i: Integer;
begin
  QTCheckPeriod(Period, 2, 'PLUS_DI');
  WilderDM(High, Low, Close, Period, P, M, T);
  Result := QTNaNSeries(Length(High));
  for i := Period to (Length(High) - 1) do
    if T[i] <> 0 then Result[i] := 100 * P[i] / T[i] else Result[i] := 0;
end;

function MINUS_DI(const High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  P, M, T: TQDoubleArray;
  i: Integer;
begin
  QTCheckPeriod(Period, 2, 'MINUS_DI');
  WilderDM(High, Low, Close, Period, P, M, T);
  Result := QTNaNSeries(Length(High));
  for i := Period to (Length(High) - 1) do
    if T[i] <> 0 then Result[i] := 100 * M[i] / T[i] else Result[i] := 0;
end;

function DX(const High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  P, M, T: TQDoubleArray;
  i: Integer;
  Sum: Double;
begin
  QTCheckPeriod(Period, 2, 'DX');
  WilderDM(High, Low, Close, Period, P, M, T);
  Result := QTNaNSeries(Length(High));
  for i := Period to (Length(High) - 1) do
  begin
    Sum := P[i] + M[i];
    if Sum <> 0 then Result[i] := 100 * Abs(P[i] - M[i]) / Sum else Result[i] := 0;
  end;
end;

function ADX(const High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  D: TQDoubleArray;
  n, i, First: Integer;
  Prev: Double;
begin
  QTCheckPeriod(Period, 2, 'ADX');
  D := DX(High, Low, Close, Period);
  n := Length(High);
  Result := QTNaNSeries(n);
  First := 2 * Period - 1;
  if n <= First then Exit;
  Prev := 0;
  for i := Period to First do
    Prev := Prev + D[i];
  Prev := Prev / Period;
  Result[First] := Prev;
  for i := First + 1 to n - 1 do
  begin
    Prev := (Prev * (Period - 1) + D[i]) / Period;
    Result[i] := Prev;
  end;
end;

function ADXR(const High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  A: TQDoubleArray;
  i: Integer;
begin
  QTCheckPeriod(Period, 2, 'ADXR');
  A := ADX(High, Low, Close, Period);
  Result := QTNaNSeries(Length(A));
  for i := 0 to (Length(A) - 1) do
    if (i >= Period - 1) and (not IsNaN(A[i])) and (not IsNaN(A[i - Period + 1])) then
      Result[i] := (A[i] + A[i - Period + 1]) / 2;
end;

{ ---------- Other momentum indicators ---------- }

function CCI(const High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  n, i, j: Integer;
  TP: TQDoubleArray;
  Avg, Dev: Double;
begin
  QTCheckPeriod(Period, 2, 'CCI');
  QTCheckLength(Length(High), Length(Low), 'CCI');
  QTCheckLength(Length(High), Length(Close), 'CCI');
  n := Length(High);
  Result := QTNaNSeries(n);
  SetLength(TP, n);
  for i := 0 to n - 1 do
    TP[i] := (High[i] + Low[i] + Close[i]) / 3;
  for i := Period - 1 to n - 1 do
  begin
    Avg := 0;
    for j := i - Period + 1 to i do Avg := Avg + TP[j];
    Avg := Avg / Period;
    Dev := 0;
    for j := i - Period + 1 to i do Dev := Dev + Abs(TP[j] - Avg);
    Dev := Dev / Period;
    if Dev <> 0 then Result[i] := (TP[i] - Avg) / (0.015 * Dev) else Result[i] := 0;
  end;
end;

// Mode: 0 MOM, 1 ROC, 2 ROCP, 3 ROCR, 4 ROCR100
function RocFamily(const Data: TQDoubleArray; Period, Mode: Integer): TQDoubleArray;
var
  S, i: Integer;
  Prev: Double;
begin
  Result := QTNaNSeries(Length(Data));
  S := QTFirstValid(Data);
  if S < 0 then Exit;
  for i := S + Period to (Length(Data) - 1) do
  begin
    Prev := Data[i - Period];
    case Mode of
      0: Result[i] := Data[i] - Prev;
      1: if Prev <> 0 then Result[i] := (Data[i] / Prev - 1) * 100 else Result[i] := 0;
      2: if Prev <> 0 then Result[i] := (Data[i] - Prev) / Prev else Result[i] := 0;
      3: if Prev <> 0 then Result[i] := Data[i] / Prev else Result[i] := 0;
    else
      if Prev <> 0 then Result[i] := Data[i] / Prev * 100 else Result[i] := 0;
    end;
  end;
end;

function MOM(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  QTCheckPeriod(Period, 1, 'MOM');
  Result := RocFamily(Data, Period, 0);
end;

function ROC(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  QTCheckPeriod(Period, 1, 'ROC');
  Result := RocFamily(Data, Period, 1);
end;

function ROCP(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  QTCheckPeriod(Period, 1, 'ROCP');
  Result := RocFamily(Data, Period, 2);
end;

function ROCR(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  QTCheckPeriod(Period, 1, 'ROCR');
  Result := RocFamily(Data, Period, 3);
end;

function ROCR100(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
begin
  QTCheckPeriod(Period, 1, 'ROCR100');
  Result := RocFamily(Data, Period, 4);
end;

function WILLR(const High, Low, Close: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  i, j: Integer;
  HH, LL, Diff: Double;
begin
  QTCheckPeriod(Period, 2, 'WILLR');
  QTCheckLength(Length(High), Length(Low), 'WILLR');
  QTCheckLength(Length(High), Length(Close), 'WILLR');
  Result := QTNaNSeries(Length(High));
  for i := Period - 1 to (Length(High) - 1) do
  begin
    HH := High[i];
    LL := Low[i];
    for j := i - Period + 1 to i do
    begin
      if High[j] > HH then HH := High[j];
      if Low[j] < LL then LL := Low[j];
    end;
    Diff := HH - LL;
    if Diff <> 0 then Result[i] := -100 * (HH - Close[i]) / Diff else Result[i] := 0;
  end;
end;

function PriceOsc(const Data: TQDoubleArray; Fast, Slow: Integer; MAType: TQMAType;
  Percent: Boolean): TQDoubleArray;
var
  F, S: TQDoubleArray;
  i, T: Integer;
begin
  QTCheckPeriod(Fast, 2, 'PriceOscillator');
  QTCheckPeriod(Slow, 2, 'PriceOscillator');
  if Fast > Slow then
  begin
    T := Fast; Fast := Slow; Slow := T;
  end;
  F := MA(Data, Fast, MAType);
  S := MA(Data, Slow, MAType);
  Result := QTNaNSeries(Length(Data));
  for i := 0 to (Length(Data) - 1) do
    if (not IsNaN(F[i])) and (not IsNaN(S[i])) then
      if Percent then
      begin
        if S[i] <> 0 then Result[i] := (F[i] - S[i]) / S[i] * 100 else Result[i] := 0;
      end
      else
        Result[i] := F[i] - S[i];
end;

function APO(const Data: TQDoubleArray; FastPeriod: Integer; SlowPeriod: Integer;
  MAType: TQMAType): TQDoubleArray;
begin
  Result := PriceOsc(Data, FastPeriod, SlowPeriod, MAType, False);
end;

function PPO(const Data: TQDoubleArray; FastPeriod: Integer; SlowPeriod: Integer;
  MAType: TQMAType): TQDoubleArray;
begin
  Result := PriceOsc(Data, FastPeriod, SlowPeriod, MAType, True);
end;

function AROON(const High, Low: TQDoubleArray; Period: Integer): TQAroon;
var
  n, i, j, HiIdx, LoIdx: Integer;
begin
  QTCheckPeriod(Period, 2, 'AROON');
  QTCheckLength(Length(High), Length(Low), 'AROON');
  n := Length(High);
  Result.Down := QTNaNSeries(n);
  Result.Up := QTNaNSeries(n);
  for i := Period to n - 1 do
  begin
    HiIdx := i - Period;
    LoIdx := i - Period;
    for j := i - Period to i do
    begin
      if High[j] >= High[HiIdx] then HiIdx := j; // ties: most recent
      if Low[j] <= Low[LoIdx] then LoIdx := j;
    end;
    Result.Up[i] := 100.0 * (Period - (i - HiIdx)) / Period;
    Result.Down[i] := 100.0 * (Period - (i - LoIdx)) / Period;
  end;
end;

function AROONOSC(const High, Low: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  A: TQAroon;
  i: Integer;
begin
  A := AROON(High, Low, Period);
  Result := QTNaNSeries(Length(High));
  for i := 0 to (Length(High) - 1) do
    if not IsNaN(A.Up[i]) then
      Result[i] := A.Up[i] - A.Down[i];
end;

function BOP(const Open, High, Low, Close: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
  HL: Double;
begin
  QTCheckLength(Length(Open), Length(High), 'BOP');
  QTCheckLength(Length(Open), Length(Low), 'BOP');
  QTCheckLength(Length(Open), Length(Close), 'BOP');
  SetLength(Result, Length(Open));
  for i := 0 to (Length(Open) - 1) do
  begin
    HL := High[i] - Low[i];
    if HL > 0 then Result[i] := (Close[i] - Open[i]) / HL else Result[i] := 0;
  end;
end;

function MFI(const High, Low, Close, Volume: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  n, i, j: Integer;
  TP: TQDoubleArray;
  Pos, Neg, MF, Tot: Double;
begin
  QTCheckPeriod(Period, 2, 'MFI');
  QTCheckLength(Length(High), Length(Low), 'MFI');
  QTCheckLength(Length(High), Length(Close), 'MFI');
  QTCheckLength(Length(High), Length(Volume), 'MFI');
  n := Length(High);
  Result := QTNaNSeries(n);
  SetLength(TP, n);
  for i := 0 to n - 1 do
    TP[i] := (High[i] + Low[i] + Close[i]) / 3;
  for i := Period to n - 1 do
  begin
    Pos := 0;
    Neg := 0;
    for j := i - Period + 1 to i do
    begin
      MF := TP[j] * Volume[j];
      if TP[j] > TP[j - 1] then Pos := Pos + MF
      else if TP[j] < TP[j - 1] then Neg := Neg + MF;
    end;
    Tot := Pos + Neg;
    if Tot < 1 then Result[i] := 0 else Result[i] := 100 * Pos / Tot;
  end;
end;

function TRIX(const Data: TQDoubleArray; Period: Integer): TQDoubleArray;
var
  E: TQDoubleArray;
  i: Integer;
begin
  QTCheckPeriod(Period, 1, 'TRIX');
  E := EMA(EMA(EMA(Data, Period), Period), Period);
  Result := QTNaNSeries(Length(Data));
  for i := 1 to (Length(E) - 1) do
    if (not IsNaN(E[i])) and (not IsNaN(E[i - 1])) then
      if E[i - 1] <> 0 then Result[i] := 100 * (E[i] - E[i - 1]) / E[i - 1]
      else Result[i] := 0;
end;

function ULTOSC(const High, Low, Close: TQDoubleArray; Period1: Integer;
  Period2: Integer; Period3: Integer): TQDoubleArray;
var
  P: array[0..2] of Integer;
  n, i, j, k, T: Integer;
  BP, TR: TQDoubleArray;
  SB, ST, Lo, Hi, A: array[0..2] of Double;
  Out_: Double;
begin
  QTCheckPeriod(Period1, 1, 'ULTOSC');
  QTCheckPeriod(Period2, 1, 'ULTOSC');
  QTCheckPeriod(Period3, 1, 'ULTOSC');
  QTCheckLength(Length(High), Length(Low), 'ULTOSC');
  QTCheckLength(Length(High), Length(Close), 'ULTOSC');
  P[0] := Period1; P[1] := Period2; P[2] := Period3;
  for i := 0 to 1 do // sort ascending
    for j := i + 1 to 2 do
      if P[j] < P[i] then
      begin
        T := P[i]; P[i] := P[j]; P[j] := T;
      end;
  n := Length(High);
  Result := QTNaNSeries(n);
  SetLength(BP, n);
  SetLength(TR, n);
  for i := 1 to n - 1 do
  begin
    Lo[0] := Min(Low[i], Close[i - 1]);
    Hi[0] := Max(High[i], Close[i - 1]);
    BP[i] := Close[i] - Lo[0];
    TR[i] := Hi[0] - Lo[0];
  end;
  for i := P[2] to n - 1 do
  begin
    for k := 0 to 2 do
    begin
      SB[k] := 0;
      ST[k] := 0;
      for j := i - P[k] + 1 to i do
      begin
        SB[k] := SB[k] + BP[j];
        ST[k] := ST[k] + TR[j];
      end;
      if ST[k] <> 0 then A[k] := SB[k] / ST[k] else A[k] := 0;
    end;
    Out_ := 100 * (4 * A[0] + 2 * A[1] + A[2]) / 7;
    Result[i] := Out_;
  end;
end;

function AO(const High, Low: TQDoubleArray; FastPeriod: Integer;
  SlowPeriod: Integer): TQDoubleArray;
var
  Med, F, S: TQDoubleArray;
  i: Integer;
begin
  QTCheckLength(Length(High), Length(Low), 'AO');
  SetLength(Med, Length(High));
  for i := 0 to (Length(High) - 1) do
    Med[i] := (High[i] + Low[i]) / 2;
  F := SMA(Med, FastPeriod);
  S := SMA(Med, SlowPeriod);
  Result := QTNaNSeries(Length(High));
  for i := 0 to (Length(High) - 1) do
    if not IsNaN(S[i]) then
      Result[i] := F[i] - S[i];
end;

end.
