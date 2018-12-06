unit untBase64;

interface

uses
  System.SysUtils, IdCoder, IdCoder3to4, IdCoderMIME;

function base64Decode(const Text : String): String;
function base64encode(const Text : String): String;

implementation

  function base64Decode(const Text : String): String;
  var
    Decoder : TIdDecoderMime;
  begin
    Decoder := TIdDecoderMime.Create(nil);
    try
      Result := Decoder.DecodeString(Text);
    finally
      FreeAndNil(Decoder)
    end
  end;

  function base64encode(const Text : String): String;
  var
    Encoder : TIdEncoderMime;
  begin
    Encoder := TIdEncoderMime.Create(nil);
    try
      Result := Encoder.EncodeString(Text);
    finally
      FreeAndNil(Encoder);
    end
  end;

end.
