{ -----------------------------------------------------------------------------
  QuantTech4D - Technical analysis library for Delphi and Free Pascal
  Author    : Shaahin Ashayeri
  GitHub    : https://github.com/DelphiMan68
  Copyright : (c) 2026, Shaahin Ashayeri
  License   : BSD-3-Clause (see LICENSE). Algorithms are ported from TA-Lib,
              which is also BSD-3-Clause (see NOTICE).
  ----------------------------------------------------------------------------- }

{ QuantTech4D - compiler directives shared by every unit.
  Works with Delphi (XE+) and Free Pascal 3.x (Delphi mode). }

{$IFDEF FPC}
  {$MODE DELPHI}
  {$H+}
  {$MODESWITCH ADVANCEDRECORDS}
{$ENDIF}

{$R-}  // range checking off (hot loops)
{$Q-}  // overflow checking off
