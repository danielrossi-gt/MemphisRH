unit untPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Objects, FMX.Layouts, System.ImageList, FMX.ImgList, FMX.StdCtrls,
  FMX.Controls.Presentation, System.Actions, FMX.ActnList, FMX.Edit, OraCall,
  Data.DB, DBAccess, Ora;

type
  TForm1 = class(TForm)
    ScrollBox: TVertScrollBox;
    recTopo: TRectangle;
    recMenu: TRectangle;
    tabPrincipal: TTabControl;
    Label1: TLabel;
    Image1: TImage;
    btnPonto: TImage;
    btnAlterarSenha: TImage;
    btnAvaliacoes: TImage;
    btnDadosPessoais: TImage;
    btnDemonstrativo: TImage;
    tabPonto: TTabItem;
    tabDemonstrativo: TTabItem;
    tabDadosPessoais: TTabItem;
    tabAvaliacoes: TTabItem;
    tabAlterarSenha: TTabItem;
    ActionList: TActionList;
    actPonto: TChangeTabAction;
    actDemonstrativo: TChangeTabAction;
    actDadosPessoais: TChangeTabAction;
    actAvaliacoes: TChangeTabAction;
    actAlterarSenha: TChangeTabAction;
    Label2: TLabel;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Label7: TLabel;
    Rectangle3: TRectangle;
    Label3: TLabel;
    Rectangle4: TRectangle;
    Label8: TLabel;
    Rectangle5: TRectangle;
    Label9: TLabel;
    layLogin: TLayout;
    Label4: TLabel;
    edtCPF: TEdit;
    Label5: TLabel;
    edtSenha: TEdit;
    btnLogin: TRectangle;
    lblLogin: TLabel;
    Session: TOraSession;
    layDadosPessoais: TLayout;
    Label6: TLabel;
    lblDataAdmissao: TLabel;
    Label11: TLabel;
    lblCargo: TLabel;
    Label13: TLabel;
    lblNome: TLabel;
    procedure btnPontoClick(Sender: TObject);
    procedure btnDemonstrativoClick(Sender: TObject);
    procedure btnDadosPessoaisClick(Sender: TObject);
    procedure btnAvaliacoesClick(Sender: TObject);
    procedure btnAlterarSenhaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
  private
    { Private declarations }
    iCodigoBase : integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

uses
  System.Math, untBase64;

procedure TForm1.btnAlterarSenhaClick(Sender: TObject);
begin
  actAlterarSenha.ExecuteTarget(Self);
end;

procedure TForm1.btnAvaliacoesClick(Sender: TObject);
begin
  actAvaliacoes.ExecuteTarget(Self);
end;

procedure TForm1.btnDadosPessoaisClick(Sender: TObject);
begin
  actDadosPessoais.ExecuteTarget(Self);
end;

procedure TForm1.btnDemonstrativoClick(Sender: TObject);
begin
  actDemonstrativo.ExecuteTarget(Self);
end;

procedure TForm1.btnPontoClick(Sender: TObject);
begin
  actPonto.ExecuteTarget(Self);
end;

procedure TForm1.FormShow(Sender: TObject);
var
  ScreenSize : TSize;
  iWidth : integer;
  slLogin : TStringList;
begin

  iCodigoBase := 0;
  tabPrincipal.TabPosition := TTabPosition.None;
  tabPrincipal.ActiveTab := tabDadosPessoais;
  layDadosPessoais.Visible := False;
  recMenu.Visible := False;

  ScreenSize := Screen.Size;
  iWidth := floor(ScreenSize.Width / 5);
  btnPonto.Width := iWidth;
  btnDemonstrativo.Width := iWidth;
  btnDadosPessoais.Width := iWidth;
  btnAvaliacoes.Width := iWidth;
  btnAlterarSenha.Width := iWidth;

  if FileExists(GetHomePath + '/login.cfg') then
  begin

    slLogin := TStringList.Create;
    slLogin.LoadFromFile(GetHomePath + '/login.cfg');

    edtCPF.Text := slLogin[0];
    edtSenha.Text := slLogin[1];
    btnLoginClick(Self);

  end;

  slLogin.Free;

end;

procedure TForm1.btnLoginClick(Sender: TObject);
var
  qryAux : TOraQuery;
  i : integer;
  slLogin : TStringList;
begin

  i := 0;

  try
    Session.Options.Direct := True;
    Session.LoginPrompt := False;
    Session.Server := 'cloud.memphis.com.br:1521:XE';
    Session.Username := 'MPH_CLOUD';
    Session.Password := 'sah';
    Session.Connect;
  except
    ShowMessage('Ocorreu um problema ao conectar o banco de dados.');
    Abort;
  end;

  try

    lblLogin.Text := 'Acessando...';
    btnLogin.HitTest := False;
    Application.ProcessMessages;

    qryAux := TOraQuery.Create(Self);
    qryAux.Session := Session;

    with qryAux do
    begin

      Close;
      SQL.Text :=
        ' SELECT CODIGO_BASE, ' +
        '      	 NOME, ' +
        '        DESC_CARGO, ' +
        '        TO_CHAR(DT_ADMISSAO, ''DD/MM/YYYY'') DT_ADMISSAO ' +
        '   FROM FUNCIONARIOS_WEB ' +
        '  WHERE CPF = :pCPF ' +
        '    AND SENHA = :pSenha ';

      ParamByName('pCPF').AsString := Trim(edtCPF.Text);
      ParamByName('pSenha').AsString := base64encode(Trim(edtSenha.Text));

      Open;

      while not(qryAux.Active) do
        i := i + 1;

      if qryAux.IsEmpty then
      begin
        ShowMessage('CPF ou Senha Inválida!');
        if FileExists(GetHomePath + '/login.cfg') then
          DeleteFile(GetHomePath + '/login.cfg');
      end
      else
      begin

        iCodigoBase := FieldByName('CODIGO_BASE').AsInteger;
        slLogin := TStringList.Create;
        slLogin.Add(Trim(edtCPF.Text));
        slLogin.Add(Trim(edtSenha.Text));
        slLogin.SaveToFile(GetHomePath + '/login.cfg');
        slLogin.Free;

        lblNome.Text := FieldByName('NOME').AsString;
        lblCargo.Text := FieldByName('DESC_CARGO').AsString;
        lblDataAdmissao.Text := FieldByName('DT_ADMISSAO').AsString;

      end;

    end;

  finally
    btnLogin.HitTest := True;
    lblLogin.Text := 'Login';
  end;

  layLogin.Visible := False;
  layDadosPessoais.Visible := True;
  recMenu.Visible := True;
  //ShowMessage(IntToStr(iCodigoBase));

end;

end.
