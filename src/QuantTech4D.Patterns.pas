{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ Candlestick pattern recognition (TA-Lib CDL* family).
  Result values: 100 = bullish, -100 = bearish, 0 = no pattern (or warm-up).
  Thresholds use the TA-Lib "candle settings" model and can be changed through
  QTCandleSettings (call QTResetCandleSettings to restore defaults). }
unit QuantTech4D.Patterns;

{$I QuantTech4D.inc}

interface

uses
  SysUtils, Math, QuantTech4D.Types, QuantTech4D.Core;

type
  TQCandleRange = (crRealBody, crHighLow, crShadows);

  TQCandleSetting = record
    RangeType: TQCandleRange;
    AvgPeriod: Integer;
    Factor: Double;
  end;

  TQCandleSettings = record
    BodyLong, BodyVeryLong, BodyShort, BodyDoji: TQCandleSetting;
    ShadowLong, ShadowVeryLong, ShadowShort, ShadowVeryShort: TQCandleSetting;
    PriceNear, PriceFar, PriceEqual: TQCandleSetting;
  end;

var
  /// Global candle thresholds (same defaults as TA-Lib).
  QTCandleSettings: TQCandleSettings;

procedure QTResetCandleSettings;

function CDLDOJI(const D: TQOHLCV): TQIntArray;
function CDLDRAGONFLYDOJI(const D: TQOHLCV): TQIntArray;
function CDLGRAVESTONEDOJI(const D: TQOHLCV): TQIntArray;
function CDLLONGLEGGEDDOJI(const D: TQOHLCV): TQIntArray;
function CDLHAMMER(const D: TQOHLCV): TQIntArray;
function CDLHANGINGMAN(const D: TQOHLCV): TQIntArray;
function CDLINVERTEDHAMMER(const D: TQOHLCV): TQIntArray;
function CDLSHOOTINGSTAR(const D: TQOHLCV): TQIntArray;
function CDLENGULFING(const D: TQOHLCV): TQIntArray;
function CDLHARAMI(const D: TQOHLCV): TQIntArray;
function CDLHARAMICROSS(const D: TQOHLCV): TQIntArray;
function CDLMARUBOZU(const D: TQOHLCV): TQIntArray;
function CDLSPINNINGTOP(const D: TQOHLCV): TQIntArray;
function CDLMORNINGSTAR(const D: TQOHLCV; Penetration: Double = 0.3): TQIntArray;
function CDLEVENINGSTAR(const D: TQOHLCV; Penetration: Double = 0.3): TQIntArray;
function CDLDARKCLOUDCOVER(const D: TQOHLCV; Penetration: Double = 0.5): TQIntArray;
function CDLPIERCING(const D: TQOHLCV): TQIntArray;
function CDL3WHITESOLDIERS(const D: TQOHLCV): TQIntArray;
function CDL3BLACKCROWS(const D: TQOHLCV): TQIntArray;
function CDLBELTHOLD(const D: TQOHLCV): TQIntArray;
function CDLCLOSINGMARUBOZU(const D: TQOHLCV): TQIntArray;
function CDLHIGHWAVE(const D: TQOHLCV): TQIntArray;
function CDLLONGLINE(const D: TQOHLCV): TQIntArray;
function CDLSHORTLINE(const D: TQOHLCV): TQIntArray;
function CDLRICKSHAWMAN(const D: TQOHLCV): TQIntArray;
function CDLTAKURI(const D: TQOHLCV): TQIntArray;
function CDLDOJISTAR(const D: TQOHLCV): TQIntArray;
function CDLMORNINGDOJISTAR(const D: TQOHLCV; Penetration: Double = 0.3): TQIntArray;
function CDLEVENINGDOJISTAR(const D: TQOHLCV; Penetration: Double = 0.3): TQIntArray;
function CDLTRISTAR(const D: TQOHLCV): TQIntArray;
function CDL3INSIDE(const D: TQOHLCV): TQIntArray;
function CDL3OUTSIDE(const D: TQOHLCV): TQIntArray;
function CDL2CROWS(const D: TQOHLCV): TQIntArray;
function CDLCOUNTERATTACK(const D: TQOHLCV): TQIntArray;
function CDLHOMINGPIGEON(const D: TQOHLCV): TQIntArray;
function CDLMATCHINGLOW(const D: TQOHLCV): TQIntArray;
function CDLSEPARATINGLINES(const D: TQOHLCV): TQIntArray;
function CDLTHRUSTING(const D: TQOHLCV): TQIntArray;
function CDLINNECK(const D: TQOHLCV): TQIntArray;
function CDLONNECK(const D: TQOHLCV): TQIntArray;
function CDLKICKING(const D: TQOHLCV): TQIntArray;
function CDLKICKINGBYLENGTH(const D: TQOHLCV): TQIntArray;
function CDLIDENTICAL3CROWS(const D: TQOHLCV): TQIntArray;
function CDLSTICKSANDWICH(const D: TQOHLCV): TQIntArray;
function CDLUPSIDEGAP2CROWS(const D: TQOHLCV): TQIntArray;
function CDLABANDONEDBABY(const D: TQOHLCV; Penetration: Double = 0.3): TQIntArray;
function CDL3LINESTRIKE(const D: TQOHLCV): TQIntArray;
function CDL3STARSINSOUTH(const D: TQOHLCV): TQIntArray;
function CDLADVANCEBLOCK(const D: TQOHLCV): TQIntArray;
function CDLBREAKAWAY(const D: TQOHLCV): TQIntArray;
function CDLCONCEALBABYSWALL(const D: TQOHLCV): TQIntArray;
function CDLGAPSIDESIDEWHITE(const D: TQOHLCV): TQIntArray;
function CDLLADDERBOTTOM(const D: TQOHLCV): TQIntArray;
function CDLMATHOLD(const D: TQOHLCV; Penetration: Double = 0.5): TQIntArray;
function CDLRISEFALL3METHODS(const D: TQOHLCV): TQIntArray;
function CDLSTALLEDPATTERN(const D: TQOHLCV): TQIntArray;
function CDLTASUKIGAP(const D: TQOHLCV): TQIntArray;
function CDLUNIQUE3RIVER(const D: TQOHLCV): TQIntArray;
function CDLXSIDEGAP3METHODS(const D: TQOHLCV): TQIntArray;
function CDLHIKKAKE(const D: TQOHLCV): TQIntArray;
function CDLHIKKAKEMOD(const D: TQOHLCV): TQIntArray;

implementation

type
  TPatternFn = function(const D: TQOHLCV; i: Integer; Param: Double): Integer;

function MakeSetting(RT: TQCandleRange; AP: Integer; F: Double): TQCandleSetting;
begin
  Result.RangeType := RT;
  Result.AvgPeriod := AP;
  Result.Factor := F;
end;

procedure QTResetCandleSettings;
begin
  with QTCandleSettings do
  begin
    BodyLong := MakeSetting(crRealBody, 10, 1.0);
    BodyVeryLong := MakeSetting(crRealBody, 10, 3.0);
    BodyShort := MakeSetting(crRealBody, 10, 1.0);
    BodyDoji := MakeSetting(crHighLow, 10, 0.1);
    ShadowLong := MakeSetting(crRealBody, 0, 1.0);
    ShadowVeryLong := MakeSetting(crRealBody, 0, 2.0);
    ShadowShort := MakeSetting(crShadows, 10, 1.0);
    ShadowVeryShort := MakeSetting(crHighLow, 10, 0.1);
    PriceNear := MakeSetting(crHighLow, 5, 0.2);
    PriceFar := MakeSetting(crHighLow, 5, 0.6);
    PriceEqual := MakeSetting(crHighLow, 5, 0.05);
  end;
end;

{ ---- candle geometry helpers ---- }

function RealBody(const D: TQOHLCV; i: Integer): Double;
begin
  Result := Abs(D.Close[i] - D.Open[i]);
end;

function UpperShadow(const D: TQOHLCV; i: Integer): Double;
begin
  Result := D.High[i] - Max(D.Close[i], D.Open[i]);
end;

function LowerShadow(const D: TQOHLCV; i: Integer): Double;
begin
  Result := Min(D.Close[i], D.Open[i]) - D.Low[i];
end;

function CandleColor(const D: TQOHLCV; i: Integer): Integer;
begin
  if D.Close[i] >= D.Open[i] then Result := 1 else Result := -1;
end;

function BodyTop(const D: TQOHLCV; i: Integer): Double;
begin
  Result := Max(D.Close[i], D.Open[i]);
end;

function BodyBottom(const D: TQOHLCV; i: Integer): Double;
begin
  Result := Min(D.Close[i], D.Open[i]);
end;

function RangeOf(const D: TQOHLCV; RT: TQCandleRange; i: Integer): Double;
begin
  case RT of
    crRealBody: Result := RealBody(D, i);
    crHighLow:  Result := D.High[i] - D.Low[i];
  else
    Result := UpperShadow(D, i) + LowerShadow(D, i);
  end;
end;

/// Average candle range for bar i, based on the AvgPeriod bars before it.
function Avg(const D: TQOHLCV; const S: TQCandleSetting; i: Integer): Double;
var
  j: Integer;
  Sum: Double;
begin
  if S.AvgPeriod <> 0 then
  begin
    Sum := 0;
    for j := i - S.AvgPeriod to i - 1 do
      Sum := Sum + RangeOf(D, S.RangeType, j);
    Result := Sum / S.AvgPeriod;
  end
  else
    Result := RangeOf(D, S.RangeType, i);
  if S.RangeType = crShadows then
    Result := Result / 2;
  Result := S.Factor * Result;
end;

function Scan(const D: TQOHLCV; Lookback: Integer; Fn: TPatternFn;
  Param: Double): TQIntArray;
var
  n, i: Integer;
begin
  QTCheckLength(Length(D.Open), Length(D.High), 'Candlestick');
  QTCheckLength(Length(D.Open), Length(D.Low), 'Candlestick');
  QTCheckLength(Length(D.Open), Length(D.Close), 'Candlestick');
  n := D.Count;
  SetLength(Result, n);
  for i := 0 to n - 1 do
    Result[i] := 0;
  for i := Lookback to n - 1 do
    Result[i] := Fn(D, i, Param);
end;

{ ---- pattern evaluators ---- }

function EvDoji(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  if RealBody(D, i) <= Avg(D, QTCandleSettings.BodyDoji, i) then Result := 100 else Result := 0;
end;

function EvDragonfly(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  if (RealBody(D, i) <= Avg(D, QTCandleSettings.BodyDoji, i)) and
     (UpperShadow(D, i) < Avg(D, QTCandleSettings.ShadowVeryShort, i)) and
     (LowerShadow(D, i) > Avg(D, QTCandleSettings.ShadowVeryShort, i)) then
    Result := 100 else Result := 0;
end;

function EvGravestone(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  if (RealBody(D, i) <= Avg(D, QTCandleSettings.BodyDoji, i)) and
     (LowerShadow(D, i) < Avg(D, QTCandleSettings.ShadowVeryShort, i)) and
     (UpperShadow(D, i) > Avg(D, QTCandleSettings.ShadowVeryShort, i)) then
    Result := 100 else Result := 0;
end;

function EvLongLegged(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  if (RealBody(D, i) <= Avg(D, QTCandleSettings.BodyDoji, i)) and
     ((LowerShadow(D, i) > Avg(D, QTCandleSettings.ShadowLong, i)) or
      (UpperShadow(D, i) > Avg(D, QTCandleSettings.ShadowLong, i))) then
    Result := 100 else Result := 0;
end;

// P = 1: hammer (bullish), P = -1: hanging man (bearish)
function EvHammerLike(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  NearOK: Boolean;
begin
  Result := 0;
  if P > 0 then
    NearOK := BodyBottom(D, i) <= D.Low[i - 1] + Avg(D, QTCandleSettings.PriceNear, i - 1)
  else
    NearOK := BodyBottom(D, i) >= D.High[i - 1] - Avg(D, QTCandleSettings.PriceNear, i - 1);
  if (RealBody(D, i) < Avg(D, QTCandleSettings.BodyShort, i)) and
     (LowerShadow(D, i) > Avg(D, QTCandleSettings.ShadowLong, i)) and
     (UpperShadow(D, i) < Avg(D, QTCandleSettings.ShadowVeryShort, i)) and NearOK then
    Result := Round(P) * 100;
end;

// P = 1: inverted hammer (bullish), P = -1: shooting star (bearish)
function EvInvertedLike(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  GapOK: Boolean;
begin
  Result := 0;
  if P > 0 then
    GapOK := BodyTop(D, i) < BodyBottom(D, i - 1)
  else
    GapOK := BodyBottom(D, i) > BodyTop(D, i - 1);
  if (RealBody(D, i) < Avg(D, QTCandleSettings.BodyShort, i)) and
     (UpperShadow(D, i) > Avg(D, QTCandleSettings.ShadowLong, i)) and
     (LowerShadow(D, i) < Avg(D, QTCandleSettings.ShadowVeryShort, i)) and GapOK then
    Result := Round(P) * 100;
end;

function EvEngulfing(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (CandleColor(D, i) = 1) and (CandleColor(D, i - 1) = -1) and
     (((D.Close[i] >= D.Open[i - 1]) and (D.Open[i] < D.Close[i - 1])) or
      ((D.Close[i] > D.Open[i - 1]) and (D.Open[i] <= D.Close[i - 1]))) then
    Result := 100
  else if (CandleColor(D, i) = -1) and (CandleColor(D, i - 1) = 1) and
     (((D.Open[i] >= D.Close[i - 1]) and (D.Close[i] < D.Open[i - 1])) or
      ((D.Open[i] > D.Close[i - 1]) and (D.Close[i] <= D.Open[i - 1]))) then
    Result := -100;
end;

function EvHarami(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (RealBody(D, i - 1) > Avg(D, QTCandleSettings.BodyLong, i - 1)) and
     (RealBody(D, i) <= Avg(D, QTCandleSettings.BodyShort, i)) and
     (BodyTop(D, i) < BodyTop(D, i - 1)) and (BodyBottom(D, i) > BodyBottom(D, i - 1)) then
    Result := -CandleColor(D, i - 1) * 100;
end;

function EvHaramiCross(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (RealBody(D, i - 1) > Avg(D, QTCandleSettings.BodyLong, i - 1)) and
     (RealBody(D, i) <= Avg(D, QTCandleSettings.BodyDoji, i)) and
     (BodyTop(D, i) < BodyTop(D, i - 1)) and (BodyBottom(D, i) > BodyBottom(D, i - 1)) then
    Result := -CandleColor(D, i - 1) * 100;
end;

function EvMarubozu(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (RealBody(D, i) > Avg(D, QTCandleSettings.BodyLong, i)) and
     (UpperShadow(D, i) < Avg(D, QTCandleSettings.ShadowVeryShort, i)) and
     (LowerShadow(D, i) < Avg(D, QTCandleSettings.ShadowVeryShort, i)) then
    Result := CandleColor(D, i) * 100;
end;

function EvSpinningTop(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (RealBody(D, i) < Avg(D, QTCandleSettings.BodyShort, i)) and
     (UpperShadow(D, i) > RealBody(D, i)) and (LowerShadow(D, i) > RealBody(D, i)) then
    Result := CandleColor(D, i) * 100;
end;

function EvMorningStar(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (RealBody(D, i - 2) > Avg(D, QTCandleSettings.BodyLong, i - 2)) and
     (CandleColor(D, i - 2) = -1) and
     (RealBody(D, i - 1) <= Avg(D, QTCandleSettings.BodyShort, i - 1)) and
     (BodyTop(D, i - 1) < BodyBottom(D, i - 2)) and
     (RealBody(D, i) > Avg(D, QTCandleSettings.BodyShort, i)) and
     (CandleColor(D, i) = 1) and
     (D.Close[i] > D.Close[i - 2] + RealBody(D, i - 2) * P) then
    Result := 100;
end;

function EvEveningStar(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (RealBody(D, i - 2) > Avg(D, QTCandleSettings.BodyLong, i - 2)) and
     (CandleColor(D, i - 2) = 1) and
     (RealBody(D, i - 1) <= Avg(D, QTCandleSettings.BodyShort, i - 1)) and
     (BodyBottom(D, i - 1) > BodyTop(D, i - 2)) and
     (RealBody(D, i) > Avg(D, QTCandleSettings.BodyShort, i)) and
     (CandleColor(D, i) = -1) and
     (D.Close[i] < D.Close[i - 2] - RealBody(D, i - 2) * P) then
    Result := -100;
end;

function EvDarkCloud(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (CandleColor(D, i - 1) = 1) and
     (RealBody(D, i - 1) > Avg(D, QTCandleSettings.BodyLong, i - 1)) and
     (CandleColor(D, i) = -1) and (D.Open[i] > D.High[i - 1]) and
     (D.Close[i] > D.Open[i - 1]) and
     (D.Close[i] < D.Close[i - 1] - RealBody(D, i - 1) * P) then
    Result := -100;
end;

function EvPiercing(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (CandleColor(D, i - 1) = -1) and
     (RealBody(D, i - 1) > Avg(D, QTCandleSettings.BodyLong, i - 1)) and
     (CandleColor(D, i) = 1) and
     (RealBody(D, i) > Avg(D, QTCandleSettings.BodyLong, i)) and
     (D.Open[i] < D.Low[i - 1]) and (D.Close[i] < D.Open[i - 1]) and
     (D.Close[i] > D.Close[i - 1] + RealBody(D, i - 1) * 0.5) then
    Result := 100;
end;

function EvThreeSoldiers(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  k: Integer;
  OK: Boolean;
begin
  Result := 0;
  OK := True;
  for k := 0 to 2 do
    OK := OK and (CandleColor(D, i - k) = 1) and
      (UpperShadow(D, i - k) < Avg(D, QTCandleSettings.ShadowVeryShort, i - k));
  if OK and
     (D.Close[i] > D.Close[i - 1]) and (D.Close[i - 1] > D.Close[i - 2]) and
     (D.Open[i - 1] > D.Open[i - 2]) and
     (D.Open[i - 1] <= D.Close[i - 2] + Avg(D, QTCandleSettings.PriceNear, i - 2)) and
     (D.Open[i] > D.Open[i - 1]) and
     (D.Open[i] <= D.Close[i - 1] + Avg(D, QTCandleSettings.PriceNear, i - 1)) and
     (RealBody(D, i - 1) > RealBody(D, i - 2) - Avg(D, QTCandleSettings.PriceFar, i - 2)) and
     (RealBody(D, i) > RealBody(D, i - 1) - Avg(D, QTCandleSettings.PriceFar, i - 1)) and
     (RealBody(D, i) > Avg(D, QTCandleSettings.BodyShort, i)) then
    Result := 100;
end;

function EvThreeCrows(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  k: Integer;
  OK: Boolean;
begin
  Result := 0;
  OK := True;
  for k := 0 to 2 do
    OK := OK and (CandleColor(D, i - k) = -1) and
      (LowerShadow(D, i - k) < Avg(D, QTCandleSettings.ShadowVeryShort, i - k));
  if OK and
     (D.Close[i] < D.Close[i - 1]) and (D.Close[i - 1] < D.Close[i - 2]) and
     (D.Open[i - 1] < D.Open[i - 2]) and
     (D.Open[i - 1] >= D.Close[i - 2] - Avg(D, QTCandleSettings.PriceNear, i - 2)) and
     (D.Open[i] < D.Open[i - 1]) and
     (D.Open[i] >= D.Close[i - 1] - Avg(D, QTCandleSettings.PriceNear, i - 1)) and
     (RealBody(D, i - 1) > RealBody(D, i - 2) - Avg(D, QTCandleSettings.PriceFar, i - 2)) and
     (RealBody(D, i) > RealBody(D, i - 1) - Avg(D, QTCandleSettings.PriceFar, i - 1)) and
     (RealBody(D, i) > Avg(D, QTCandleSettings.BodyShort, i)) then
    Result := -100;
end;

{ ---- additional pattern evaluators ---- }

function GapUp(const D: TQOHLCV; i, j: Integer): Boolean;
begin
  Result := BodyBottom(D, i) > BodyTop(D, j);
end;

function GapDown(const D: TQOHLCV; i, j: Integer): Boolean;
begin
  Result := BodyTop(D, i) < BodyBottom(D, j);
end;

function IsEqualClose(const D: TQOHLCV; i, j: Integer): Boolean;
begin
  Result := Abs(D.Close[i] - D.Close[j]) <= Avg(D, QTCandleSettings.PriceEqual, j);
end;

function EvBeltHold(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (RealBody(D, i) > Avg(D, BodyLong, i)) and
       (((CandleColor(D, i) = 1) and (LowerShadow(D, i) < Avg(D, ShadowVeryShort, i))) or
        ((CandleColor(D, i) = -1) and (UpperShadow(D, i) < Avg(D, ShadowVeryShort, i)))) then
      Result := CandleColor(D, i) * 100;
end;

function EvClosingMarubozu(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (RealBody(D, i) > Avg(D, BodyLong, i)) and
       (((CandleColor(D, i) = 1) and (UpperShadow(D, i) < Avg(D, ShadowVeryShort, i))) or
        ((CandleColor(D, i) = -1) and (LowerShadow(D, i) < Avg(D, ShadowVeryShort, i)))) then
      Result := CandleColor(D, i) * 100;
end;

function EvHighWave(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (RealBody(D, i) < Avg(D, BodyShort, i)) and
       (UpperShadow(D, i) > Avg(D, ShadowVeryLong, i)) and
       (LowerShadow(D, i) > Avg(D, ShadowVeryLong, i)) then
      Result := CandleColor(D, i) * 100;
end;

function EvLongLine(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (RealBody(D, i) > Avg(D, BodyLong, i)) and
       (UpperShadow(D, i) < Avg(D, ShadowShort, i)) and
       (LowerShadow(D, i) < Avg(D, ShadowShort, i)) then
      Result := CandleColor(D, i) * 100;
end;

function EvShortLine(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (RealBody(D, i) < Avg(D, BodyShort, i)) and
       (UpperShadow(D, i) < Avg(D, ShadowShort, i)) and
       (LowerShadow(D, i) < Avg(D, ShadowShort, i)) then
      Result := CandleColor(D, i) * 100;
end;

function EvRickshaw(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  Rng, Nr: Double;
begin
  Result := 0;
  Rng := D.High[i] - D.Low[i];
  with QTCandleSettings do
  begin
    Nr := Avg(D, PriceNear, i);
    if (RealBody(D, i) <= Avg(D, BodyDoji, i)) and
       (LowerShadow(D, i) > Avg(D, ShadowLong, i)) and
       (UpperShadow(D, i) > Avg(D, ShadowLong, i)) and
       (BodyBottom(D, i) <= D.Low[i] + Rng / 2 + Nr) and
       (BodyTop(D, i) >= D.High[i] - Rng / 2 - Nr) then
      Result := 100;
  end;
end;

function EvTakuri(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (RealBody(D, i) <= Avg(D, BodyDoji, i)) and
       (UpperShadow(D, i) < Avg(D, ShadowVeryShort, i)) and
       (LowerShadow(D, i) > Avg(D, ShadowVeryLong, i)) then
      Result := 100;
end;

function EvDojiStar(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (RealBody(D, i - 1) > Avg(D, BodyLong, i - 1)) and
       (RealBody(D, i) <= Avg(D, BodyDoji, i)) and
       (((CandleColor(D, i - 1) = 1) and GapUp(D, i, i - 1)) or
        ((CandleColor(D, i - 1) = -1) and GapDown(D, i, i - 1))) then
      Result := -CandleColor(D, i - 1) * 100;
end;

function EvMorningDojiStar(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (RealBody(D, i - 2) > Avg(D, BodyLong, i - 2)) and (CandleColor(D, i - 2) = -1) and
       (RealBody(D, i - 1) <= Avg(D, BodyDoji, i - 1)) and GapDown(D, i - 1, i - 2) and
       (CandleColor(D, i) = 1) and (D.Close[i] > D.Close[i - 2] + RealBody(D, i - 2) * P) then
      Result := 100;
end;

function EvEveningDojiStar(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (RealBody(D, i - 2) > Avg(D, BodyLong, i - 2)) and (CandleColor(D, i - 2) = 1) and
       (RealBody(D, i - 1) <= Avg(D, BodyDoji, i - 1)) and GapUp(D, i - 1, i - 2) and
       (CandleColor(D, i) = -1) and (D.Close[i] < D.Close[i - 2] - RealBody(D, i - 2) * P) then
      Result := -100;
end;

function EvTriStar(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  Lim: Double;
begin
  Result := 0;
  Lim := Avg(D, QTCandleSettings.BodyDoji, i - 2);
  if (RealBody(D, i - 2) <= Lim) and (RealBody(D, i - 1) <= Lim) and (RealBody(D, i) <= Lim) then
  begin
    if GapUp(D, i - 1, i - 2) and (BodyTop(D, i) < BodyTop(D, i - 1)) then
      Result := -100
    else if GapDown(D, i - 1, i - 2) and (BodyBottom(D, i) > BodyBottom(D, i - 1)) then
      Result := 100;
  end;
end;

function EvThreeInside(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (RealBody(D, i - 2) > Avg(D, BodyLong, i - 2)) and
       (RealBody(D, i - 1) <= Avg(D, BodyShort, i - 1)) and
       (BodyTop(D, i - 1) < BodyTop(D, i - 2)) and (BodyBottom(D, i - 1) > BodyBottom(D, i - 2)) and
       (((CandleColor(D, i - 2) = 1) and (CandleColor(D, i) = -1) and (D.Close[i] < D.Open[i - 2])) or
        ((CandleColor(D, i - 2) = -1) and (CandleColor(D, i) = 1) and (D.Close[i] > D.Open[i - 2]))) then
      Result := -CandleColor(D, i - 2) * 100;
end;

function EvThreeOutside(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if ((CandleColor(D, i - 1) = 1) and (CandleColor(D, i - 2) = -1) and
      (D.Close[i - 1] > D.Open[i - 2]) and (D.Open[i - 1] < D.Close[i - 2]) and
      (D.Close[i] > D.Close[i - 1])) or
     ((CandleColor(D, i - 1) = -1) and (CandleColor(D, i - 2) = 1) and
      (D.Open[i - 1] > D.Close[i - 2]) and (D.Close[i - 1] < D.Open[i - 2]) and
      (D.Close[i] < D.Close[i - 1])) then
    Result := CandleColor(D, i - 1) * 100;
end;

function EvTwoCrows(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (CandleColor(D, i - 2) = 1) and
     (RealBody(D, i - 2) > Avg(D, QTCandleSettings.BodyLong, i - 2)) and
     (CandleColor(D, i - 1) = -1) and GapUp(D, i - 1, i - 2) and
     (CandleColor(D, i) = -1) and
     (D.Open[i] < D.Open[i - 1]) and (D.Open[i] > D.Close[i - 1]) and
     (D.Close[i] > D.Open[i - 2]) and (D.Close[i] < D.Close[i - 2]) then
    Result := -100;
end;

function EvCounterattack(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (CandleColor(D, i - 1) = -CandleColor(D, i)) and
       (RealBody(D, i - 1) > Avg(D, BodyLong, i - 1)) and
       (RealBody(D, i) > Avg(D, BodyLong, i)) and IsEqualClose(D, i, i - 1) then
      Result := CandleColor(D, i) * 100;
end;

function EvHomingPigeon(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (CandleColor(D, i - 1) = -1) and (CandleColor(D, i) = -1) and
       (RealBody(D, i - 1) > Avg(D, BodyLong, i - 1)) and
       (RealBody(D, i) <= Avg(D, BodyShort, i)) and
       (D.Close[i] > D.Close[i - 1]) and (D.Open[i] < D.Open[i - 1]) then
      Result := 100;
end;

function EvMatchingLow(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (CandleColor(D, i - 1) = -1) and (CandleColor(D, i) = -1) and IsEqualClose(D, i, i - 1) then
    Result := 100;
end;

function EvSeparatingLines(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (CandleColor(D, i - 1) = -CandleColor(D, i)) and
       (Abs(D.Open[i] - D.Open[i - 1]) <= Avg(D, PriceEqual, i - 1)) and
       (RealBody(D, i) > Avg(D, BodyLong, i)) and
       (((CandleColor(D, i) = 1) and (LowerShadow(D, i) < Avg(D, ShadowVeryShort, i))) or
        ((CandleColor(D, i) = -1) and (UpperShadow(D, i) < Avg(D, ShadowVeryShort, i)))) then
      Result := CandleColor(D, i) * 100;
end;

function EvThrusting(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (CandleColor(D, i - 1) = -1) and (RealBody(D, i - 1) > Avg(D, BodyLong, i - 1)) and
       (CandleColor(D, i) = 1) and (D.Open[i] < D.Low[i - 1]) and
       (D.Close[i] > D.Close[i - 1] + Avg(D, PriceEqual, i - 1)) and
       (D.Close[i] <= D.Close[i - 1] + RealBody(D, i - 1) * 0.5) then
      Result := -100;
end;

function EvInNeck(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (CandleColor(D, i - 1) = -1) and (RealBody(D, i - 1) > Avg(D, BodyLong, i - 1)) and
       (CandleColor(D, i) = 1) and (D.Open[i] < D.Low[i - 1]) and
       (D.Close[i] <= D.Close[i - 1] + Avg(D, PriceEqual, i - 1)) and
       (D.Close[i] >= D.Close[i - 1]) then
      Result := -100;
end;

function EvOnNeck(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  Eq: Double;
begin
  Result := 0;
  with QTCandleSettings do
  begin
    Eq := Avg(D, PriceEqual, i - 1);
    if (CandleColor(D, i - 1) = -1) and (RealBody(D, i - 1) > Avg(D, BodyLong, i - 1)) and
       (CandleColor(D, i) = 1) and (D.Open[i] < D.Low[i - 1]) and
       (D.Close[i] <= D.Low[i - 1] + Eq) and (D.Close[i] >= D.Low[i - 1] - Eq) then
      Result := -100;
  end;
end;

function KickingBase(const D: TQOHLCV; i: Integer; ByLength: Boolean): Integer;

  function IsMaru(k: Integer): Boolean;
  begin
    with QTCandleSettings do
      Result := (RealBody(D, k) > Avg(D, BodyLong, k)) and
        (UpperShadow(D, k) < Avg(D, ShadowVeryShort, k)) and
        (LowerShadow(D, k) < Avg(D, ShadowVeryShort, k));
  end;

begin
  Result := 0;
  if (CandleColor(D, i - 1) = -CandleColor(D, i)) and IsMaru(i - 1) and IsMaru(i) and
     (((CandleColor(D, i - 1) = -1) and (D.High[i - 1] < D.Low[i])) or
      ((CandleColor(D, i - 1) = 1) and (D.Low[i - 1] > D.High[i]))) then
  begin
    if not ByLength then
      Result := CandleColor(D, i) * 100
    else if (D.High[i] - D.Low[i]) > (D.High[i - 1] - D.Low[i - 1]) then
      Result := CandleColor(D, i) * 100
    else
      Result := CandleColor(D, i - 1) * 100;
  end;
end;

function EvKicking(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := KickingBase(D, i, False);
end;

function EvKickingByLength(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := KickingBase(D, i, True);
end;

function EvIdentical3Crows(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  k: Integer;
  OK: Boolean;
begin
  Result := 0;
  OK := True;
  with QTCandleSettings do
  begin
    for k := 0 to 2 do
      OK := OK and (CandleColor(D, i - k) = -1) and
        (LowerShadow(D, i - k) < Avg(D, ShadowVeryShort, i - k));
    if OK and (D.Close[i - 2] > D.Close[i - 1]) and (D.Close[i - 1] > D.Close[i]) and
       (Abs(D.Open[i - 1] - D.Close[i - 2]) <= Avg(D, PriceEqual, i - 2)) and
       (Abs(D.Open[i] - D.Close[i - 1]) <= Avg(D, PriceEqual, i - 1)) then
      Result := -100;
  end;
end;

function EvStickSandwich(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (CandleColor(D, i - 2) = -1) and (CandleColor(D, i - 1) = 1) and (CandleColor(D, i) = -1) and
     (D.Low[i - 1] > D.Close[i - 2]) and
     (Abs(D.Close[i] - D.Close[i - 2]) <= Avg(D, QTCandleSettings.PriceEqual, i - 2)) then
    Result := 100;
end;

function EvUpsideGap2Crows(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (CandleColor(D, i - 2) = 1) and (RealBody(D, i - 2) > Avg(D, BodyLong, i - 2)) and
       (CandleColor(D, i - 1) = -1) and (RealBody(D, i - 1) <= Avg(D, BodyShort, i - 1)) and
       GapUp(D, i - 1, i - 2) and (CandleColor(D, i) = -1) and
       (D.Open[i] > D.Open[i - 1]) and (D.Close[i] < D.Close[i - 1]) and
       (D.Close[i] > D.Close[i - 2]) then
      Result := -100;
end;

function EvAbandonedBaby(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (RealBody(D, i - 2) > Avg(D, BodyLong, i - 2)) and
       (RealBody(D, i - 1) <= Avg(D, BodyDoji, i - 1)) and
       (RealBody(D, i) > Avg(D, BodyShort, i)) then
    begin
      if (CandleColor(D, i - 2) = -1) and (CandleColor(D, i) = 1) and
         (D.Close[i] > D.Close[i - 2] + RealBody(D, i - 2) * P) and
         (D.High[i - 1] < D.Low[i - 2]) and (D.Low[i] > D.High[i - 1]) then
        Result := 100
      else if (CandleColor(D, i - 2) = 1) and (CandleColor(D, i) = -1) and
         (D.Close[i] < D.Close[i - 2] - RealBody(D, i - 2) * P) and
         (D.Low[i - 1] > D.High[i - 2]) and (D.High[i] < D.Low[i - 1]) then
        Result := -100;
    end;
end;

{ ---- last 15 pattern evaluators ---- }

function EvThreeLineStrike(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (CandleColor(D, i - 3) = CandleColor(D, i - 2)) and
       (CandleColor(D, i - 2) = CandleColor(D, i - 1)) and
       (CandleColor(D, i - 1) = -CandleColor(D, i)) and
       (D.Open[i - 2] >= BodyBottom(D, i - 3) - Avg(D, PriceNear, i - 3)) and
       (D.Open[i - 2] <= BodyTop(D, i - 3) + Avg(D, PriceNear, i - 3)) and
       (D.Open[i - 1] >= BodyBottom(D, i - 2) - Avg(D, PriceNear, i - 2)) and
       (D.Open[i - 1] <= BodyTop(D, i - 2) + Avg(D, PriceNear, i - 2)) and
       (((CandleColor(D, i - 1) = 1) and (D.Close[i - 1] > D.Close[i - 2]) and
         (D.Close[i - 2] > D.Close[i - 3]) and (D.Open[i] > D.Close[i - 1]) and
         (D.Close[i] < D.Open[i - 3])) or
        ((CandleColor(D, i - 1) = -1) and (D.Close[i - 1] < D.Close[i - 2]) and
         (D.Close[i - 2] < D.Close[i - 3]) and (D.Open[i] < D.Close[i - 1]) and
         (D.Close[i] > D.Open[i - 3]))) then
      Result := CandleColor(D, i - 1) * 100;
end;

function EvThreeStarsInSouth(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (CandleColor(D, i - 2) = -1) and (CandleColor(D, i - 1) = -1) and (CandleColor(D, i) = -1) and
       (RealBody(D, i - 2) > Avg(D, BodyLong, i - 2)) and
       (LowerShadow(D, i - 2) > Avg(D, ShadowVeryShort, i - 2)) and
       (RealBody(D, i - 1) < RealBody(D, i - 2)) and
       (D.Open[i - 1] > D.Close[i - 2]) and (D.Open[i - 1] <= D.High[i - 2]) and
       (D.Low[i - 1] < D.Close[i - 2]) and (D.Low[i - 1] >= D.Low[i - 2]) and
       (LowerShadow(D, i - 1) > Avg(D, ShadowVeryShort, i - 1)) and
       (RealBody(D, i) < Avg(D, BodyShort, i)) and
       (LowerShadow(D, i) < Avg(D, ShadowVeryShort, i)) and
       (UpperShadow(D, i) < Avg(D, ShadowVeryShort, i)) and
       (D.Low[i] > D.Low[i - 1]) and (D.High[i] < D.High[i - 1]) then
      Result := 100;
end;

function EvAdvanceBlock(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  k: Integer;
  OK: Boolean;
begin
  Result := 0;
  OK := True;
  for k := 0 to 2 do OK := OK and (CandleColor(D, i - k) = 1);
  with QTCandleSettings do
    if OK and (D.Close[i] > D.Close[i - 1]) and (D.Close[i - 1] > D.Close[i - 2]) and
       (D.Open[i - 1] > D.Open[i - 2]) and (D.Open[i - 1] <= D.Close[i - 2] + Avg(D, PriceNear, i - 2)) and
       (D.Open[i] > D.Open[i - 1]) and (D.Open[i] <= D.Close[i - 1] + Avg(D, PriceNear, i - 1)) and
       (RealBody(D, i - 2) > Avg(D, BodyLong, i - 2)) and
       (UpperShadow(D, i - 2) < Avg(D, ShadowShort, i - 2)) and
       (((RealBody(D, i - 1) < RealBody(D, i - 2) - Avg(D, PriceFar, i - 2)) and
         (RealBody(D, i) < RealBody(D, i - 1) + Avg(D, PriceNear, i - 1))) or
        (RealBody(D, i) < RealBody(D, i - 1) - Avg(D, PriceFar, i - 1)) or
        ((RealBody(D, i) < RealBody(D, i - 1)) and (RealBody(D, i - 1) < RealBody(D, i - 2)) and
         ((UpperShadow(D, i) > Avg(D, ShadowShort, i)) or
          (UpperShadow(D, i - 1) > Avg(D, ShadowShort, i - 1)))) or
        ((RealBody(D, i) < RealBody(D, i - 1)) and (UpperShadow(D, i) > Avg(D, ShadowLong, i)))) then
      Result := -100;
end;

function EvBreakaway(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if RealBody(D, i - 4) > Avg(D, BodyLong, i - 4) then
    begin
      if (CandleColor(D, i - 4) = -1) and (CandleColor(D, i - 3) = -1) and
         (CandleColor(D, i - 1) = -1) and (CandleColor(D, i) = 1) and
         GapDown(D, i - 3, i - 4) and
         (D.High[i - 2] < D.High[i - 3]) and (D.Low[i - 2] < D.Low[i - 3]) and
         (D.High[i - 1] < D.High[i - 2]) and (D.Low[i - 1] < D.Low[i - 2]) and
         (D.Close[i] > D.Open[i - 3]) and (D.Close[i] < D.Close[i - 4]) then
        Result := 100
      else if (CandleColor(D, i - 4) = 1) and (CandleColor(D, i - 3) = 1) and
         (CandleColor(D, i - 1) = 1) and (CandleColor(D, i) = -1) and
         GapUp(D, i - 3, i - 4) and
         (D.High[i - 2] > D.High[i - 3]) and (D.Low[i - 2] > D.Low[i - 3]) and
         (D.High[i - 1] > D.High[i - 2]) and (D.Low[i - 1] > D.Low[i - 2]) and
         (D.Close[i] < D.Open[i - 3]) and (D.Close[i] > D.Close[i - 4]) then
        Result := -100;
    end;
end;

function EvConcealBabySwallow(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  k: Integer;
  OK: Boolean;
begin
  Result := 0;
  OK := True;
  for k := 0 to 3 do OK := OK and (CandleColor(D, i - k) = -1);
  with QTCandleSettings do
    if OK and
       (LowerShadow(D, i - 3) < Avg(D, ShadowVeryShort, i - 3)) and
       (UpperShadow(D, i - 3) < Avg(D, ShadowVeryShort, i - 3)) and
       (LowerShadow(D, i - 2) < Avg(D, ShadowVeryShort, i - 2)) and
       (UpperShadow(D, i - 2) < Avg(D, ShadowVeryShort, i - 2)) and
       GapDown(D, i - 1, i - 2) and
       (UpperShadow(D, i - 1) > Avg(D, ShadowVeryShort, i - 1)) and
       (D.High[i - 1] > D.Close[i - 2]) and
       (D.High[i] > D.High[i - 1]) and (D.Low[i] < D.Low[i - 1]) then
      Result := 100;
end;

function EvGapSideSideWhite(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if ((GapUp(D, i - 1, i - 2) and GapUp(D, i, i - 2)) or
        (GapDown(D, i - 1, i - 2) and GapDown(D, i, i - 2))) and
       (CandleColor(D, i - 1) = 1) and (CandleColor(D, i) = 1) and
       (RealBody(D, i) >= RealBody(D, i - 1) - Avg(D, PriceNear, i - 1)) and
       (RealBody(D, i) <= RealBody(D, i - 1) + Avg(D, PriceNear, i - 1)) and
       (D.Open[i] >= D.Open[i - 1] - Avg(D, PriceEqual, i - 1)) and
       (D.Open[i] <= D.Open[i - 1] + Avg(D, PriceEqual, i - 1)) then
      if GapUp(D, i - 1, i - 2) then Result := 100 else Result := -100;
end;

function EvLadderBottom(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (CandleColor(D, i - 4) = -1) and (CandleColor(D, i - 3) = -1) and
       (CandleColor(D, i - 2) = -1) and
       (D.Open[i - 4] > D.Open[i - 3]) and (D.Open[i - 3] > D.Open[i - 2]) and
       (D.Close[i - 4] > D.Close[i - 3]) and (D.Close[i - 3] > D.Close[i - 2]) and
       (CandleColor(D, i - 1) = -1) and
       (UpperShadow(D, i - 1) > Avg(D, ShadowVeryShort, i - 1)) and
       (CandleColor(D, i) = 1) and (D.Open[i] > D.Open[i - 1]) and (D.Close[i] > D.High[i - 1]) then
      Result := 100;
end;

function EvMatHold(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  Floor_: Double;
begin
  Result := 0;
  with QTCandleSettings do
  begin
    Floor_ := D.Close[i - 4] - RealBody(D, i - 4) * P;
    if (RealBody(D, i - 4) > Avg(D, BodyLong, i - 4)) and
       (RealBody(D, i - 3) < Avg(D, BodyShort, i - 3)) and
       (RealBody(D, i - 2) < Avg(D, BodyShort, i - 2)) and
       (RealBody(D, i - 1) < Avg(D, BodyShort, i - 1)) and
       (CandleColor(D, i - 4) = 1) and (CandleColor(D, i - 3) = -1) and (CandleColor(D, i) = 1) and
       GapUp(D, i - 3, i - 4) and
       (BodyBottom(D, i - 2) < BodyTop(D, i - 3)) and
       (BodyBottom(D, i - 1) < BodyTop(D, i - 2)) and
       (BodyBottom(D, i - 2) > Floor_) and (BodyBottom(D, i - 1) > Floor_) and
       (D.Close[i - 2] < D.Close[i - 3]) and (D.Close[i - 1] < D.Close[i - 2]) and
       (D.Open[i] > D.Close[i - 1]) and
       (D.Close[i] > Max(D.High[i - 3], Max(D.High[i - 2], D.High[i - 1]))) then
      Result := 100;
  end;
end;

function EvRiseFall3Methods(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  C4: Integer;
begin
  Result := 0;
  C4 := CandleColor(D, i - 4);
  with QTCandleSettings do
    if (RealBody(D, i - 4) > Avg(D, BodyLong, i - 4)) and
       (RealBody(D, i - 3) < Avg(D, BodyShort, i - 3)) and
       (RealBody(D, i - 2) < Avg(D, BodyShort, i - 2)) and
       (RealBody(D, i - 1) < Avg(D, BodyShort, i - 1)) and
       (RealBody(D, i) > Avg(D, BodyLong, i)) and
       (C4 = -CandleColor(D, i - 3)) and (CandleColor(D, i - 3) = CandleColor(D, i - 2)) and
       (CandleColor(D, i - 2) = CandleColor(D, i - 1)) and (CandleColor(D, i - 1) = -CandleColor(D, i)) and
       (BodyBottom(D, i - 3) < D.High[i - 4]) and (BodyTop(D, i - 3) > D.Low[i - 4]) and
       (BodyBottom(D, i - 2) < D.High[i - 4]) and (BodyTop(D, i - 2) > D.Low[i - 4]) and
       (BodyBottom(D, i - 1) < D.High[i - 4]) and (BodyTop(D, i - 1) > D.Low[i - 4]) and
       (D.Close[i - 2] * C4 < D.Close[i - 3] * C4) and
       (D.Close[i - 1] * C4 < D.Close[i - 2] * C4) and
       (D.Open[i] * C4 > D.Close[i - 1] * C4) and
       (D.Close[i] * C4 > D.Close[i - 4] * C4) then
      Result := C4 * 100;
end;

function EvStalledPattern(const D: TQOHLCV; i: Integer; P: Double): Integer;
var
  k: Integer;
  OK: Boolean;
begin
  Result := 0;
  OK := True;
  for k := 0 to 2 do OK := OK and (CandleColor(D, i - k) = 1);
  with QTCandleSettings do
    if OK and (D.Close[i] > D.Close[i - 1]) and (D.Close[i - 1] > D.Close[i - 2]) and
       (RealBody(D, i - 2) > Avg(D, BodyLong, i - 2)) and
       (RealBody(D, i - 1) > Avg(D, BodyLong, i - 1)) and
       (UpperShadow(D, i - 1) < Avg(D, ShadowVeryShort, i - 1)) and
       (D.Open[i - 1] > D.Open[i - 2]) and (D.Open[i - 1] <= D.Close[i - 2] + Avg(D, PriceNear, i - 2)) and
       (RealBody(D, i) < Avg(D, BodyShort, i)) and
       (D.Open[i] >= D.Close[i - 1] - RealBody(D, i) - Avg(D, PriceNear, i - 1)) then
      Result := -100;
end;

function EvTasukiGap(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (GapUp(D, i - 1, i - 2) and (CandleColor(D, i - 1) = 1) and (CandleColor(D, i) = -1) and
        (D.Open[i] < D.Close[i - 1]) and (D.Open[i] > D.Open[i - 1]) and
        (D.Close[i] < D.Open[i - 1]) and (D.Close[i] > BodyTop(D, i - 2)) and
        (Abs(RealBody(D, i - 1) - RealBody(D, i)) < Avg(D, PriceNear, i - 1))) then
      Result := 100
    else if (GapDown(D, i - 1, i - 2) and (CandleColor(D, i - 1) = -1) and (CandleColor(D, i) = 1) and
        (D.Open[i] > D.Close[i - 1]) and (D.Open[i] < D.Open[i - 1]) and
        (D.Close[i] > D.Open[i - 1]) and (D.Close[i] < BodyBottom(D, i - 2)) and
        (Abs(RealBody(D, i - 1) - RealBody(D, i)) < Avg(D, PriceNear, i - 1))) then
      Result := -100;
end;

function EvUnique3River(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  with QTCandleSettings do
    if (RealBody(D, i - 2) > Avg(D, BodyLong, i - 2)) and (CandleColor(D, i - 2) = -1) and
       (CandleColor(D, i - 1) = -1) and (D.Close[i - 1] > D.Close[i - 2]) and
       (D.Open[i - 1] <= D.Open[i - 2]) and (D.Low[i - 1] < D.Low[i - 2]) and
       (RealBody(D, i) < Avg(D, BodyShort, i)) and (CandleColor(D, i) = 1) and
       (D.Open[i] > D.Low[i - 1]) then
      Result := 100;
end;

function EvXSideGap3Methods(const D: TQOHLCV; i: Integer; P: Double): Integer;
begin
  Result := 0;
  if (CandleColor(D, i - 2) = CandleColor(D, i - 1)) and (CandleColor(D, i - 1) = -CandleColor(D, i)) then
  begin
    if (CandleColor(D, i - 2) = 1) and GapUp(D, i - 1, i - 2) and
       (D.Open[i] < D.Close[i - 1]) and (D.Open[i] > D.Open[i - 1]) and
       (D.Close[i] < D.Close[i - 2]) and (D.Close[i] > D.Open[i - 2]) then
      Result := 100
    else if (CandleColor(D, i - 2) = -1) and GapDown(D, i - 1, i - 2) and
       (D.Open[i] > D.Close[i - 1]) and (D.Open[i] < D.Open[i - 1]) and
       (D.Close[i] > D.Close[i - 2]) and (D.Close[i] < D.Open[i - 2]) then
      Result := -100;
  end;
end;

{ ---- public API ---- }

function CDLDOJI(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.BodyDoji.AvgPeriod, EvDoji, 0);
end;

function CDLDRAGONFLYDOJI(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, Max(QTCandleSettings.BodyDoji.AvgPeriod,
    QTCandleSettings.ShadowVeryShort.AvgPeriod), EvDragonfly, 0);
end;

function CDLGRAVESTONEDOJI(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, Max(QTCandleSettings.BodyDoji.AvgPeriod,
    QTCandleSettings.ShadowVeryShort.AvgPeriod), EvGravestone, 0);
end;

function CDLLONGLEGGEDDOJI(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, Max(QTCandleSettings.BodyDoji.AvgPeriod,
    QTCandleSettings.ShadowLong.AvgPeriod), EvLongLegged, 0);
end;

function HammerLookback: Integer;
begin
  with QTCandleSettings do
    Result := Max(Max(BodyShort.AvgPeriod, ShadowLong.AvgPeriod),
      Max(ShadowVeryShort.AvgPeriod, PriceNear.AvgPeriod)) + 1;
end;

function CDLHAMMER(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, HammerLookback, EvHammerLike, 1);
end;

function CDLHANGINGMAN(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, HammerLookback, EvHammerLike, -1);
end;

function CDLINVERTEDHAMMER(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, HammerLookback, EvInvertedLike, 1);
end;

function CDLSHOOTINGSTAR(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, HammerLookback, EvInvertedLike, -1);
end;

function CDLENGULFING(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, 2, EvEngulfing, 0);
end;

function CDLHARAMI(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, Max(QTCandleSettings.BodyShort.AvgPeriod,
    QTCandleSettings.BodyLong.AvgPeriod) + 1, EvHarami, 0);
end;

function CDLHARAMICROSS(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, Max(QTCandleSettings.BodyDoji.AvgPeriod,
    QTCandleSettings.BodyLong.AvgPeriod) + 1, EvHaramiCross, 0);
end;

function CDLMARUBOZU(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, Max(QTCandleSettings.BodyLong.AvgPeriod,
    QTCandleSettings.ShadowVeryShort.AvgPeriod), EvMarubozu, 0);
end;

function CDLSPINNINGTOP(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.BodyShort.AvgPeriod, EvSpinningTop, 0);
end;

function StarLookback: Integer;
begin
  Result := Max(QTCandleSettings.BodyLong.AvgPeriod, QTCandleSettings.BodyShort.AvgPeriod) + 2;
end;

function CDLMORNINGSTAR(const D: TQOHLCV; Penetration: Double): TQIntArray;
begin
  Result := Scan(D, StarLookback, EvMorningStar, Penetration);
end;

function CDLEVENINGSTAR(const D: TQOHLCV; Penetration: Double): TQIntArray;
begin
  Result := Scan(D, StarLookback, EvEveningStar, Penetration);
end;

function CDLDARKCLOUDCOVER(const D: TQOHLCV; Penetration: Double): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.BodyLong.AvgPeriod + 1, EvDarkCloud, Penetration);
end;

function CDLPIERCING(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.BodyLong.AvgPeriod + 1, EvPiercing, 0);
end;

function SoldiersLookback: Integer;
begin
  with QTCandleSettings do
    Result := Max(Max(ShadowVeryShort.AvgPeriod, BodyShort.AvgPeriod),
      Max(PriceFar.AvgPeriod, PriceNear.AvgPeriod)) + 2;
end;

function CDL3WHITESOLDIERS(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, SoldiersLookback, EvThreeSoldiers, 0);
end;

function CDL3BLACKCROWS(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, SoldiersLookback, EvThreeCrows, 0);
end;

{ ---- additional public pattern functions ---- }

function MaxAvg(a, b: Integer): Integer;
begin
  Result := Max(a, b);
end;

function CDLBELTHOLD(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyLong.AvgPeriod, QTCandleSettings.ShadowVeryShort.AvgPeriod), EvBeltHold, 0);
end;

function CDLCLOSINGMARUBOZU(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyLong.AvgPeriod, QTCandleSettings.ShadowVeryShort.AvgPeriod), EvClosingMarubozu, 0);
end;

function CDLHIGHWAVE(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyShort.AvgPeriod, QTCandleSettings.ShadowVeryLong.AvgPeriod), EvHighWave, 0);
end;

function CDLLONGLINE(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyLong.AvgPeriod, QTCandleSettings.ShadowShort.AvgPeriod), EvLongLine, 0);
end;

function CDLSHORTLINE(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyShort.AvgPeriod, QTCandleSettings.ShadowShort.AvgPeriod), EvShortLine, 0);
end;

function CDLRICKSHAWMAN(const D: TQOHLCV): TQIntArray;
begin
  with QTCandleSettings do
    Result := Scan(D, MaxAvg(MaxAvg(BodyDoji.AvgPeriod, ShadowLong.AvgPeriod), PriceNear.AvgPeriod), EvRickshaw, 0);
end;

function CDLTAKURI(const D: TQOHLCV): TQIntArray;
begin
  with QTCandleSettings do
    Result := Scan(D, MaxAvg(MaxAvg(BodyDoji.AvgPeriod, ShadowVeryShort.AvgPeriod), ShadowVeryLong.AvgPeriod), EvTakuri, 0);
end;

function CDLDOJISTAR(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyDoji.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 1, EvDojiStar, 0);
end;

function CDLMORNINGDOJISTAR(const D: TQOHLCV; Penetration: Double): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyDoji.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 2, EvMorningDojiStar, Penetration);
end;

function CDLEVENINGDOJISTAR(const D: TQOHLCV; Penetration: Double): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyDoji.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 2, EvEveningDojiStar, Penetration);
end;

function CDLTRISTAR(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.BodyDoji.AvgPeriod + 2, EvTriStar, 0);
end;

function CDL3INSIDE(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyLong.AvgPeriod, QTCandleSettings.BodyShort.AvgPeriod) + 2, EvThreeInside, 0);
end;

function CDL3OUTSIDE(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, 3, EvThreeOutside, 0);
end;

function CDL2CROWS(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.BodyLong.AvgPeriod + 2, EvTwoCrows, 0);
end;

function CDLCOUNTERATTACK(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.PriceEqual.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 1, EvCounterattack, 0);
end;

function CDLHOMINGPIGEON(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyShort.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 1, EvHomingPigeon, 0);
end;

function CDLMATCHINGLOW(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.PriceEqual.AvgPeriod + 1, EvMatchingLow, 0);
end;

function CDLSEPARATINGLINES(const D: TQOHLCV): TQIntArray;
begin
  with QTCandleSettings do
    Result := Scan(D, MaxAvg(MaxAvg(ShadowVeryShort.AvgPeriod, BodyLong.AvgPeriod), PriceEqual.AvgPeriod) + 1, EvSeparatingLines, 0);
end;

function CDLTHRUSTING(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.PriceEqual.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 1, EvThrusting, 0);
end;

function CDLINNECK(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.PriceEqual.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 1, EvInNeck, 0);
end;

function CDLONNECK(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.PriceEqual.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 1, EvOnNeck, 0);
end;

function CDLKICKING(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.ShadowVeryShort.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 1, EvKicking, 0);
end;

function CDLKICKINGBYLENGTH(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.ShadowVeryShort.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 1, EvKickingByLength, 0);
end;

function CDLIDENTICAL3CROWS(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.ShadowVeryShort.AvgPeriod, QTCandleSettings.PriceEqual.AvgPeriod) + 2, EvIdentical3Crows, 0);
end;

function CDLSTICKSANDWICH(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.PriceEqual.AvgPeriod + 2, EvStickSandwich, 0);
end;

function CDLUPSIDEGAP2CROWS(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyShort.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 2, EvUpsideGap2Crows, 0);
end;

function CDLABANDONEDBABY(const D: TQOHLCV; Penetration: Double): TQIntArray;
begin
  with QTCandleSettings do
    Result := Scan(D, MaxAvg(MaxAvg(BodyDoji.AvgPeriod, BodyLong.AvgPeriod), BodyShort.AvgPeriod) + 2, EvAbandonedBaby, Penetration);
end;

{ ---- last 15 public pattern functions ---- }

function CDL3LINESTRIKE(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.PriceNear.AvgPeriod + 3, EvThreeLineStrike, 0);
end;

function CDL3STARSINSOUTH(const D: TQOHLCV): TQIntArray;
begin
  with QTCandleSettings do
    Result := Scan(D, MaxAvg(MaxAvg(ShadowVeryShort.AvgPeriod, BodyLong.AvgPeriod), BodyShort.AvgPeriod) + 2, EvThreeStarsInSouth, 0);
end;

function CDLADVANCEBLOCK(const D: TQOHLCV): TQIntArray;
begin
  with QTCandleSettings do
    Result := Scan(D, MaxAvg(MaxAvg(MaxAvg(ShadowShort.AvgPeriod, PriceFar.AvgPeriod), PriceNear.AvgPeriod), BodyLong.AvgPeriod) + 2, EvAdvanceBlock, 0);
end;

function CDLBREAKAWAY(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.BodyLong.AvgPeriod + 4, EvBreakaway, 0);
end;

function CDLCONCEALBABYSWALL(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.ShadowVeryShort.AvgPeriod + 3, EvConcealBabySwallow, 0);
end;

function CDLGAPSIDESIDEWHITE(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.PriceNear.AvgPeriod, QTCandleSettings.PriceEqual.AvgPeriod) + 2, EvGapSideSideWhite, 0);
end;

function CDLLADDERBOTTOM(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.ShadowVeryShort.AvgPeriod + 4, EvLadderBottom, 0);
end;

function CDLMATHOLD(const D: TQOHLCV; Penetration: Double): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyShort.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 4, EvMatHold, Penetration);
end;

function CDLRISEFALL3METHODS(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyShort.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 4, EvRiseFall3Methods, 0);
end;

function CDLSTALLEDPATTERN(const D: TQOHLCV): TQIntArray;
begin
  with QTCandleSettings do
    Result := Scan(D, MaxAvg(MaxAvg(MaxAvg(BodyLong.AvgPeriod, BodyShort.AvgPeriod), ShadowVeryShort.AvgPeriod), PriceNear.AvgPeriod) + 2, EvStalledPattern, 0);
end;

function CDLTASUKIGAP(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, QTCandleSettings.PriceNear.AvgPeriod + 2, EvTasukiGap, 0);
end;

function CDLUNIQUE3RIVER(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, MaxAvg(QTCandleSettings.BodyShort.AvgPeriod, QTCandleSettings.BodyLong.AvgPeriod) + 2, EvUnique3River, 0);
end;

function CDLXSIDEGAP3METHODS(const D: TQOHLCV): TQIntArray;
begin
  Result := Scan(D, 2, EvXSideGap3Methods, 0);
end;

function CDLHIKKAKE(const D: TQOHLCV): TQIntArray;
var
  n, i, PatIdx, PatRes: Integer;
begin
  QTCheckLength(Length(D.Open), Length(D.High), 'CDLHIKKAKE');
  QTCheckLength(Length(D.Open), Length(D.Low), 'CDLHIKKAKE');
  QTCheckLength(Length(D.Open), Length(D.Close), 'CDLHIKKAKE');
  n := D.Count;
  SetLength(Result, n);
  for i := 0 to n - 1 do Result[i] := 0;
  PatIdx := 0;
  PatRes := 0;
  for i := 2 to n - 1 do
  begin
    if (D.High[i - 1] < D.High[i - 2]) and (D.Low[i - 1] > D.Low[i - 2]) and
       (((D.High[i] < D.High[i - 1]) and (D.Low[i] < D.Low[i - 1])) or
        ((D.High[i] > D.High[i - 1]) and (D.Low[i] > D.Low[i - 1]))) then
    begin
      if D.High[i] < D.High[i - 1] then PatRes := 100 else PatRes := -100;
      PatIdx := i;
      if i >= 5 then Result[i] := PatRes;
    end
    else if (PatIdx > 0) and (i <= PatIdx + 3) and
       (((PatRes > 0) and (D.Close[i] > D.High[PatIdx - 1])) or
        ((PatRes < 0) and (D.Close[i] < D.Low[PatIdx - 1]))) then
    begin
      if i >= 5 then
        if PatRes > 0 then Result[i] := PatRes + 100 else Result[i] := PatRes - 100;
      PatIdx := 0;
    end;
  end;
end;

function CDLHIKKAKEMOD(const D: TQOHLCV): TQIntArray;
var
  n, i, PatIdx, PatRes, Lb: Integer;
begin
  QTCheckLength(Length(D.Open), Length(D.High), 'CDLHIKKAKEMOD');
  QTCheckLength(Length(D.Open), Length(D.Low), 'CDLHIKKAKEMOD');
  QTCheckLength(Length(D.Open), Length(D.Close), 'CDLHIKKAKEMOD');
  n := D.Count;
  SetLength(Result, n);
  for i := 0 to n - 1 do Result[i] := 0;
  Lb := Max(1, QTCandleSettings.PriceNear.AvgPeriod) + 5;
  PatIdx := 0;
  PatRes := 0;
  for i := Max(3, QTCandleSettings.PriceNear.AvgPeriod + 2) to n - 1 do
  begin
    if (D.High[i - 2] < D.High[i - 3]) and (D.Low[i - 2] > D.Low[i - 3]) and
       (((D.High[i - 1] < D.High[i - 2]) and (D.Low[i - 1] < D.Low[i - 2]) and
         (D.Close[i - 2] <= D.Low[i - 2] + Avg(D, QTCandleSettings.PriceNear, i - 2))) or
        ((D.High[i - 1] > D.High[i - 2]) and (D.Low[i - 1] > D.Low[i - 2]) and
         (D.Close[i - 2] >= D.High[i - 2] - Avg(D, QTCandleSettings.PriceNear, i - 2)))) then
    begin
      if D.High[i - 1] < D.High[i - 2] then PatRes := 100 else PatRes := -100;
      PatIdx := i - 1;
      if (PatRes > 0) and (D.Close[i] > D.High[i - 2]) then
      begin
        if i >= Lb then Result[i] := 200;
        PatIdx := 0;
      end
      else if (PatRes < 0) and (D.Close[i] < D.Low[i - 2]) then
      begin
        if i >= Lb then Result[i] := -200;
        PatIdx := 0;
      end
      else if i >= Lb then
        Result[i] := PatRes;
    end
    else if (PatIdx > 0) and (i <= PatIdx + 3) and
       (((PatRes > 0) and (D.Close[i] > D.High[PatIdx - 1])) or
        ((PatRes < 0) and (D.Close[i] < D.Low[PatIdx - 1]))) then
    begin
      if i >= Lb then
        if PatRes > 0 then Result[i] := 200 else Result[i] := -200;
      PatIdx := 0;
    end;
  end;
end;

initialization
  QTResetCandleSettings;

end.
