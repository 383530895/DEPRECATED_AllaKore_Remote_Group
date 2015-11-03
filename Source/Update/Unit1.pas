unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdComponent, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, IdBaseComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  Vcl.Imaging.pngimage, iwSystem,System.Zip ,Shellapi,System.IniFiles;

type
  TForm1 = class(TForm)
    IdHTTP1: TIdHTTP;
    ProgressBar1: TProgressBar;
    Timer1: TTimer;
    lista: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Button1: TButton;
    Label1: TLabel;
    TopBackground_Image: TImage;
    Title2_Label: TLabel;
    Title1_Label: TLabel;
    Logo_Image: TImage;
    lbl_File: TLabel;
    lbl_CurrentVersion: TLabel;
    lbl_NewVersion: TLabel;
    procedure IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure IdHTTP1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure IdHTTP1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure DownLoad;
    procedure ExtrairArquivo(const AArquivo: string);
    procedure VerificaProgramaAberto(Programa : PwideChar);
    function EnDecryptString(StrValue : String; Key: Word) : String;
    function GetIni(Path, Key, KeyValue : string; encrypted: Boolean): string;
    Var
     Aplicativo, URL : string;

     Const
        cGeneral            = 'General';
        cVersion            = 'Version';
        cUrlUpdates         = 'UrlUpdates';
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
form1.Close;
end;

procedure TForm1.DownLoad;
var
arquivo,caminho : string;
MyFile : TFileStream;
  Ext: string;
begin
caminho:= URL; //local onde estará o arquivo versaoatual.txt
arquivo:= 'versaoatual.txt'; //nome do arquivo a ser baixado (versaoatual.txt)
MyFile := TFileStream.Create('versaoatual.txt', fmCreate); // cria o versaoatual.txt
try
  idHTTP1.Get(URL + 'versaoatual.txt', MyFile); //baixando versaoatual.txt
finally
MyFile.Free;
{CARREGA VERSAOATUAL E VERSAO.TXT NOS MEMOS}
memo2.Lines.LoadFromFile('versaoatual.txt'); // carregar o versaoatual.txt no memo2
memo3.Lines.LoadFromFile('versao.txt'); // carrega o versa.txt no memo3
{-----------------------------------------------------------------------------}

{verifica a versao}
if memo2.Lines [0] = memo3.Lines[0] then
begin
button1.Enabled := true;
label1.Caption := 'atualização concluida!';
// SE A VERSÃO FOR DIFERENET BAIXA O UPDATE COM O NOME DO ARQUIVO QUE DEVE SER BAIXADO
END ELSE BEGIN
caminho := URL; // local onde vai estar o update.txt
arquivo := 'update.txt'; // nome do arquivo que vai ser baixado
MyFile := TFileStream.Create('update.txt', fmCreate); // cria o update.txt
try
  IdHTTP1.Get(caminho + 'update.txt',MyFile); //baixando o update.txt
  finally
  MyFile.Free;
  lista.Lines.LoadFromFile('update.txt'); // carrega o update.txt no memo1
end;
{ AGORA BAIXAR O ARQUIVO ESCRITO NO UPDATE.TXT}
label1.Caption := 'Baixando: ' + Lista.Lines[0]; // informa que esta sendo feito download
caminho := URL; // local onde estara o arquivo escrito no update.txt
arquivo := lista.Lines [0]; // nome do arquivo que esta escrito no memo1
MyFile := TFileStream.Create(lista.Lines[0], fmCreate); // cria o arquivo escrito no memo1
try
  IdHTTP1.Get(caminho {caminho} + lista.Lines[0], MyFile);//baixando o arquivo
finally
MyFile.Free;
end;

memo2.Lines.SaveToFile('versao.txt'); // salva o memo 2 como versao e com a nova numeração da atualzação
Label1.Caption := 'Atualização Concluida!';
end;
end;
///////////////////////////////////////
button1.Enabled := true;
Timer1.Enabled := False;
timer1.Free;
Ext :=  ExtractFileExt(Arquivo);
   /// Com zip Master
 {Zip.Dll_Load := true;
  if(LowerCase(Ext) = '.zip')then
  begin
     with Zip do
        begin
          FSpecArgs.Clear;
          FSpecArgs.Add('*.*');
          ZipFileName := Arquivo;
          // Onde será descompactado
          ExtrBaseDir := gsAppPath;
         // Metodo de descompactação
          Extract;
         showmessage('Arquivo Descompactado com Sucesso !!!');
      end;
  end; }

  /// Sem zip Master
  if(LowerCase(Ext) = '.zip')then
  begin
  ExtrairArquivo(arquivo);
  Aplicativo := gsAppPath + 'AllaKore_Remote_Client.exe';
  sleep(2000);
  ShellExecute(handle,'open',PChar(Aplicativo), '','',SW_SHOWNORMAL);
  DeleteFile(arquivo);
  end;


  sleep(5000);
  Application.Terminate;
end;

procedure TForm1.ExtrairArquivo(const AArquivo: string);
var
  oZip : TZipFile;
begin
  oZip := TZipFile.Create;
  try
    oZip.Open(AArquivo,zmRead);
    oZip.ExtractAll();
    oZip.Close;
  finally
    FreeAndNil(oZip);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  URL := GetIni(gsAppPath + 'Allakore_remote_client.ini', cGeneral, cUrlUpdates, False);
end;

procedure TForm1.IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
ProgressBar1.Position := AWorkCount;
end;

procedure TForm1.IdHTTP1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
ProgressBar1.Position := 0;
Application.ProcessMessages;
ProgressBar1.Max := AWorkCountMax;
Label1.Caption := 'Verificando atualizações...'
end;

procedure TForm1.IdHTTP1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
ProgressBar1.Position := ProgressBar1.Max;
Label1.Caption := 'Atualização concluida!';
end;

procedure TForm1.Timer1Timer(Sender: TObject);
Var
 Aplicativo : string;
begin
Aplicativo := GetIni(gsAppPath + 'Allakore_remote_client.ini', cGeneral, cVersion, False);
Timer1.Enabled := False;
VerificaProgramaAberto(PwideChar(Aplicativo));
DownLoad;
end;

procedure TForm1.VerificaProgramaAberto(Programa: PwideChar);
 var
 H: THandle;
 Sis : String;
 begin
 H := FindWindow(nil, Programa );
   if H > 0 then
     begin
       ShowMessage('Programa AllaKore - Remote está aberto! ' +#13+'Precisa ser fechado!!');
       PostMessage(H, WM_CLOSE, 0, 0);
       sleep(1000);
     end;

 end;


function TForm1.GetIni(Path, Key, KeyValue : string; encrypted: Boolean): string;
var ArqIni : TIniFile;
    ValueINI : string;
begin
  ArqIni := TIniFile.Create(Path);

  ValueINI := ArqIni.ReadString(Key, KeyValue, ValueINI);
  if ValueINI = '' then
     ValueINI := '0'
  else
  IF encrypted THEN
     ValueINI := EnDecryptString(ValueINI,250);

  Result := ValueINI;
  ArqIni.Free;
end;


function TForm1.EnDecryptString(StrValue : String; Key: Word) : String;
var I: Integer; OutValue : String;
begin
  OutValue := '';
  for I := 1 to Length(StrValue) do
      OutValue := OutValue + char(Not(ord(StrValue[I])-Key));

  Result := OutValue;
end;

end.
