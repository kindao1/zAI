unit DNN_OD_BeautifulBreast_Frm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Objects, FMX.ScrollBox, FMX.Memo, FMX.Layouts, FMX.ExtCtrls,

  System.IOUtils,

  CoreClasses, zAI, zAI_Common, zDrawEngineInterface_SlowFMX, zDrawEngine, MemoryRaster, MemoryStream64,
  PascalStrings, UnicodeMixedLib, Geometry2DUnit, Geometry3DUnit, Cadencer, FFMPEG, FFMPEG_Reader;

type
  TForm1 = class(TForm, ICadencerProgressInterface)
    Memo1: TMemo;
    PaintBox1: TPaintBox;
    Timer1: TTimer;
    HistogramEqualizeCheckBox: TCheckBox;
    AntialiasCheckBox: TCheckBox;
    SepiaCheckBox: TCheckBox;
    SharpenCheckBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
  private
    procedure CadencerProgress(const deltaTime, newTime: Double);
  public
    drawIntf: TDrawEngineInterface_FMX;
    mpeg_r: TFFMPEG_Reader;
    frame: TDETexture;
    cadencer_eng: TCadencer;
    ai: TAI;
    mmod_hnd: TMMOD_Handle;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}


procedure TForm1.FormCreate(Sender: TObject);
begin
  // ��ȡzAI������
  ReadAIConfig;

  // ��һ��������Key����������֤ZAI��Key
  // ���ӷ�������֤Key������������ʱһ���Ե���֤��ֻ�ᵱ��������ʱ�Ż���֤��������֤����ͨ����zAI����ܾ�����
  // �ڳ��������У���������TAI�����ᷢ��Զ����֤
  // ��֤��Ҫһ��userKey��ͨ��userkey�����ZAI������ʱ���ɵ����Key��userkey����ͨ��web���룬Ҳ������ϵ���߷���
  // ��֤key���ǿ����Ӽ����޷����ƽ�
  zAI.Prepare_AI_Engine();

  // ʹ��zDrawEngine���ⲿ��ͼʱ(������Ϸ������paintbox)������Ҫһ����ͼ�ӿ�
  // TDrawEngineInterface_FMX������FMX�Ļ�ͼcore�ӿ�
  // �����ָ����ͼ�ӿڣ�zDrawEngine��Ĭ��ʹ��������դ��ͼ(�Ƚ���)
  drawIntf := TDrawEngineInterface_FMX.Create;

  // mp4��Ƶ֡��ʽ
  mpeg_r := TFFMPEG_Reader.Create(umlCombineFileName(TPath.GetLibraryPath, 'lady.mp4'));

  // ��ǰ���Ƶ���Ƶ֡
  frame := TDrawEngine.NewTexture;

  // cadencer����
  cadencer_eng := TCadencer.Create;
  cadencer_eng.ProgressInterface := Self;

  // ai����
  ai := TAI.OpenEngine();

  // ����dnn-od�ļ����
  mmod_hnd := ai.MMOD_DNN_Open_Stream(umlCombineFileName(TPath.GetLibraryPath, 'BeautifulBreast.svm_dnn_od'));
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  cadencer_eng.Progress;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
  procedure Raster_DetectAndDraw(mr: TMemoryRaster);
  begin
    ai.DrawMMOD(mmod_hnd, mr, DEColor(1, 0, 0, 1));

    // ������ʾ�˶���Ƶ��������ڴ����Ĳ��ַ���

    // Sepia�Ƿǳ�Ư����ɫ��ϵ�����������������
    if SepiaCheckBox.IsChecked then
        Sepia32(mr, 12);

    // ʹ��ɫ��ֱ��ͼ�޸�yv12��ʧ��ɫ��
    // ��ͼ��������������е��Ӹо�
    if HistogramEqualizeCheckBox.IsChecked then
        HistogramEqualize(mr);

    // �����
    if AntialiasCheckBox.IsChecked then
        Antialias32(mr, 1);

    // ��
    if SharpenCheckBox.IsChecked then
        Sharpen(mr, False);
  end;

var
  d: TDrawEngine;
begin
  drawIntf.SetSurface(Canvas, Sender);
  d := DrawPool(Sender, drawIntf);
  d.ViewOptions := [];
  d.FPSFontColor := DEColor(0.5, 0.5, 1, 1);

  d.FillBox(d.ScreenRect, DEColor(0, 0, 0));

  while not mpeg_r.ReadFrame(frame, True) do
    begin
      mpeg_r.Seek(0);
      d.LastNewTime := 0;
    end;
  Raster_DetectAndDraw(frame);
  frame.ReleaseFMXResource;
  d.FitDrawTexture(frame, frame.BoundsRectV2, d.ScreenRect, 1.0);

  d.BeginCaptureShadow(Vec2(1, 1), 0.9);
  d.DrawText(d.LastDrawInfo + #13#10 + PFormat('frame size:%d*%d', [frame.Width, frame.Height]), 16, d.ScreenRect, DEColor(0, 0.5, 0), False);
  d.EndCaptureShadow;

  // ִ�л�ͼָ��
  d.Flush;
end;

procedure TForm1.CadencerProgress(const deltaTime, newTime: Double);
begin
  EnginePool.Progress(deltaTime);
  Invalidate;
end;

end.