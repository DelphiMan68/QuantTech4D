{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ QuantTech4D - technical analysis library for Delphi and Free Pascal.
  A Pascal port of the algorithms found in TA-Lib (BSD-3-Clause).
  See README.md for attribution and license notes. }
unit QuantTech4D.Types;

{$I QuantTech4D.inc}

interface

uses
  SysUtils;

type
  /// Base exception class for every error raised by QuantTech4D.
  EQuantTechError = class(Exception);

  /// Dynamic array of doubles. All indicator inputs/outputs use this type.
  TQDoubleArray = array of Double;

  /// Dynamic array of integers (used by candlestick patterns and index outputs).
  TQIntArray = array of Integer;

  /// Moving average types. Ordinals match TA-Lib's TA_MAType enumeration.
  TQMAType = (maSMA, maEMA, maWMA, maDEMA, maTEMA, maTRIMA, maKAMA, maMAMA, maT3);

  /// A series of OHLCV bars stored as parallel arrays (index 0 = oldest bar).
  TQOHLCV = record
    Open, High, Low, Close, Volume: TQDoubleArray;
    /// Number of bars (length of the Close array).
    function Count: Integer;
    /// Resizes all five arrays to N elements.
    procedure Resize(N: Integer);
  end;

  /// Output of Bollinger Bands.
  TQBBands = record
    Upper, Middle, Lower: TQDoubleArray;
  end;

  /// Output of MACD.
  TQMACD = record
    MACD, Signal, Hist: TQDoubleArray;
  end;

  /// Output of the Stochastic family (K and D lines).
  TQStoch = record
    K, D: TQDoubleArray;
  end;

  /// Output of Aroon.
  TQAroon = record
    Down, Up: TQDoubleArray;
  end;

  /// Output of rolling min/max.
  TQMinMax = record
    Lowest, Highest: TQDoubleArray;
  end;

implementation

function TQOHLCV.Count: Integer;
begin
  Result := Length(Close);
end;

procedure TQOHLCV.Resize(N: Integer);
begin
  SetLength(Open, N);
  SetLength(High, N);
  SetLength(Low, N);
  SetLength(Close, N);
  SetLength(Volume, N);
end;

end.
