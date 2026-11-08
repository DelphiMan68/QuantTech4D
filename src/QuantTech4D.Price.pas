{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ Price transforms and Heikin-Ashi candles. }
unit QuantTech4D.Price;

{$I QuantTech4D.inc}

interface

uses
  SysUtils, Math, QuantTech4D.Types, QuantTech4D.Core;

/// Average price: (O + H + L + C) / 4.
function AVGPRICE(const Open, High, Low, Close: TQDoubleArray): TQDoubleArray;
/// Median price: (H + L) / 2.
function MEDPRICE(const High, Low: TQDoubleArray): TQDoubleArray;
/// Typical price: (H + L + C) / 3.
function TYPPRICE(const High, Low, Close: TQDoubleArray): TQDoubleArray;
/// Weighted close price: (H + L + 2C) / 4.
function WCLPRICE(const High, Low, Close: TQDoubleArray): TQDoubleArray;
/// Heikin-Ashi candles (Volume is copied unchanged).
function HeikinAshi(const Data: TQOHLCV): TQOHLCV;

implementation

function AVGPRICE(const Open, High, Low, Close: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
begin
  QTCheckLength(Length(Open), Length(High), 'AVGPRICE');
  QTCheckLength(Length(Open), Length(Low), 'AVGPRICE');
  QTCheckLength(Length(Open), Length(Close), 'AVGPRICE');
  SetLength(Result, Length(Open));
  for i := 0 to (Length(Open) - 1) do
    Result[i] := (Open[i] + High[i] + Low[i] + Close[i]) / 4;
end;

function MEDPRICE(const High, Low: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
begin
  QTCheckLength(Length(High), Length(Low), 'MEDPRICE');
  SetLength(Result, Length(High));
  for i := 0 to (Length(High) - 1) do
    Result[i] := (High[i] + Low[i]) / 2;
end;

function TYPPRICE(const High, Low, Close: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
begin
  QTCheckLength(Length(High), Length(Low), 'TYPPRICE');
  QTCheckLength(Length(High), Length(Close), 'TYPPRICE');
  SetLength(Result, Length(High));
  for i := 0 to (Length(High) - 1) do
    Result[i] := (High[i] + Low[i] + Close[i]) / 3;
end;

function WCLPRICE(const High, Low, Close: TQDoubleArray): TQDoubleArray;
var
  i: Integer;
begin
  QTCheckLength(Length(High), Length(Low), 'WCLPRICE');
  QTCheckLength(Length(High), Length(Close), 'WCLPRICE');
  SetLength(Result, Length(High));
  for i := 0 to (Length(High) - 1) do
    Result[i] := (High[i] + Low[i] + 2 * Close[i]) / 4;
end;

function HeikinAshi(const Data: TQOHLCV): TQOHLCV;
var
  i, n: Integer;
begin
  n := Data.Count;
  Result.Resize(n);
  for i := 0 to n - 1 do
  begin
    Result.Close[i] := (Data.Open[i] + Data.High[i] + Data.Low[i] + Data.Close[i]) / 4;
    if i = 0 then
      Result.Open[i] := (Data.Open[0] + Data.Close[0]) / 2
    else
      Result.Open[i] := (Result.Open[i - 1] + Result.Close[i - 1]) / 2;
    Result.High[i] := Max(Data.High[i], Max(Result.Open[i], Result.Close[i]));
    Result.Low[i] := Min(Data.Low[i], Min(Result.Open[i], Result.Close[i]));
    Result.Volume[i] := Data.Volume[i];
  end;
end;

end.
