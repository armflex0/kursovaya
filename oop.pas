unit main;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  petalclass;

const
  P_COUNT = 70;

type

  { TForm1 }

  TForm1 = class(TForm)
    Img: TImage;
    Timer1: TTimer;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    P: TPetals;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  P.DrawNext;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: char);
begin
  Timer1.Enabled := False;
  Close;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  P := TPetals.Create(img,P_COUNT);
  Timer1.Enabled := True;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  P.Clear;
  P.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

end.
===========================================================
unit petalclass;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, ExtCtrls, Contnrs;

type
  { TCustomPetal }

  TCustomPetal = class
  protected
    R, phi, PetalI: double;
    X, Y, K, CX, CY: integer;
    Scale, RColor: integer;
    Image: TImage;
  public
    constructor Create(_Image: TImage); virtual;
    procedure Draw(_Erase: boolean = False);
    procedure Erase;
  end;

  { TPetal }

  TPetal = class(TCustomPetal)
  public
    constructor Create(_Image: TImage); override;
  end;

  { TOverlappedPetal }

  TOverlappedPetal = class(TCustomPetal)
  public
    constructor Create(_Image: TImage); override;
  end;

  { TPetals }

  TPetals = class(TObjectList)
  private
    fMaxPetals: smallint;
    fImage: TImage;
  public
    property MaxPetals: smallint read fMaxPetals write fMaxPetals;
    constructor Create(_Image: TImage; _Size: integer);
    procedure DrawNext;
  end;

  TRandomPetal = class of TCustomPetal;

implementation

{ TPetals }

constructor TPetals.Create(_Image: TImage; _Size: integer);
begin
  inherited Create;
  MaxPetals := _Size;
  fImage := _Image;
end;

procedure TPetals.DrawNext;
var
  LRandomPetal: TRandomPetal;
begin
  if self.Count = MaxPetals then
  begin
    TCustomPetal(First).Erase;
    Remove(First);
  end;
  if Random(2) = 1 then
    LRandomPetal := TPetal
  else
    LRandomPetal := TOverlappedPetal;
  Add(LRandomPetal.Create(fImage));
end;

{ TCustomPetal }

constructor TCustomPetal.Create(_Image: TImage);
begin
  inherited Create;
  Image:=_Image;
  CX := Random(Image.Canvas.Width);
  CY := Random(Image.Canvas.Height);
  RColor := 1 + Random($FFFFF0);
  Scale := 2 + Random(12);
end;

procedure TCustomPetal.Draw(_Erase: boolean = False);
var
  OldColor: TColor;
begin
  phi := 0;
  OldColor := RColor;
  if _Erase then
    RColor := clBlack;
  while phi < K * pi do
    begin
      R := 10 * sin(PetalI * phi);
      X := CX + Trunc(Scale * R * cos(phi));
      Y := CY - Trunc(Scale * R * sin(phi));

      if (not _Erase) or (Image.Canvas.Pixels[X, Y] = OldColor) then
        Image.Canvas.Pixels[X, Y] := RColor;
      phi += pi / 1800;
    end;
end;

procedure TCustomPetal.Erase;
begin
  Draw(True);
end;

{ TOverlappedPetal }

constructor TOverlappedPetal.Create(_Image: TImage);
begin
  inherited Create(_Image);
  K := 12;
  while PetalI = Round(PetalI) do
    PetalI := (1 + Random(6)) / (1 + Random(6));
  Draw;
end;

{ TPetal }

constructor TPetal.Create(_Image: TImage);
begin
  inherited Create(_Image);
  K := 2;
  PetalI := 1 + Random(8);
  Draw;
end;

end.

