{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ Data helpers: CSV loading, synthetic sample data, number formatting.
  Handy for examples and quick experiments. }
unit QuantTech4D.Data;

{$I QuantTech4D.inc}

interface

uses
  SysUtils, Classes, Math, QuantTech4D.Types;

/// Loads OHLCV bars from a CSV file.
/// Accepted layouts: [Date,]Open,High,Low,Close,Volume (a leading text/date
/// column is detected automatically when there are 6 or more columns).
/// Rows are expected oldest first.
function LoadOHLCVFromCSV(const FileName: string; HasHeader: Boolean = True;
  Delimiter: Char = ','): TQOHLCV;

/// Generates a reproducible random-walk OHLCV series for demos and tests.
function GenerateSampleOHLCV(Count: Integer; Seed: Integer = 42;
  StartPrice: Double = 100.0): TQOHLCV;

/// Formats a value with the given decimals; NaN becomes 'n/a'.
function QTFmt(X: Double; Decimals: Integer = 4): string;

implementation

function QTFmt(X: Double; Decimals: Integer): string;
begin
  if IsNaN(X) then
    Result := 'n/a'
  else
    Result := Format('%.*f', [Decimals, X]);
end;

function GenerateSampleOHLCV(Count: Integer; Seed: Integer; StartPrice: Double): TQOHLCV;
var
  i: Integer;
  Price, O, C, H, L: Double;
  OldSeed: Integer;
begin
  OldSeed := RandSeed;
  RandSeed := Seed;
  try
    Result.Resize(Count);
    Price := StartPrice;
    for i := 0 to Count - 1 do
    begin
      O := Price;
      C := O * (1 + (Random - 0.5) * 0.04);
      H := Max(O, C) * (1 + Random * 0.01);
      L := Min(O, C) * (1 - Random * 0.01);
      Result.Open[i] := O;
      Result.High[i] := H;
      Result.Low[i] := L;
      Result.Close[i] := C;
      Result.Volume[i] := 1000 + Random * 9000;
      Price := C;
    end;
  finally
    RandSeed := OldSeed;
  end;
end;

function LoadOHLCVFromCSV(const FileName: string; HasHeader: Boolean;
  Delimiter: Char): TQOHLCV;
var
  Lines: TStringList;
  Cells: TStringList;
  FS: TFormatSettings;
  i, N, Off: Integer;
  Line: string;

  function V(Idx: Integer): Double;
  begin
    Result := StrToFloat(Trim(Cells[Off + Idx]), FS);
  end;

begin
  {$IFDEF FPC}
  FS := DefaultFormatSettings;
  {$ELSE}
  FS := TFormatSettings.Create;
  {$ENDIF}
  FS.DecimalSeparator := '.';
  Lines := TStringList.Create;
  Cells := TStringList.Create;
  try
    Lines.LoadFromFile(FileName);
    Cells.StrictDelimiter := True;
    Cells.Delimiter := Delimiter;
    Result.Resize(0);
    N := 0;
    for i := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[i]);
      if (Line = '') or ((i = 0) and HasHeader) then
        Continue;
      Cells.DelimitedText := Line;
      if Cells.Count >= 6 then Off := Cells.Count - 5 else Off := 0;
      if Cells.Count < 5 then
        raise EQuantTechError.CreateFmt('CSV line %d has too few columns', [i + 1]);
      Inc(N);
      Result.Resize(N);
      Result.Open[N - 1] := V(0);
      Result.High[N - 1] := V(1);
      Result.Low[N - 1] := V(2);
      Result.Close[N - 1] := V(3);
      Result.Volume[N - 1] := V(4);
    end;
  finally
    Cells.Free;
    Lines.Free;
  end;
end;

end.
