program MatrixAndVectorExpression;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  SysUtils,
  CoreClasses,
  PascalStrings,
  DoStatusIO,
  LearnTypes,
  Learn,
  TextParsing,
  zExpression;

// ����3*3��variant����ʹ��c�﷨����ʽ
procedure MatrixExp;
var
  m: TExpressionValueMatrix;
begin
  DoStatus('');
  m := EvaluateExpressionMatrix(3, 3,
    '"hello"+"-baby"/*��ע���ַ�������*/,true,false,' +
    '1+1,2+2,3+3,' +
    '4*4,4*5,4*6', tsC);
  DoStatus(m);
end;

// ����variant�������飬ʹ��pascal�﷨����ʽ
procedure MatrixVec;
var
  v: TExpressionValueVector;
begin
  DoStatus('');
  v := EvaluateExpressionVector('0.1*(0.1+max(0.15,0.11)){��ע����},1,2,3,4,5,6,7,8,9', tsPascal);
  DoStatus(v);
end;

// ����3*4��TLMatrix���󣬸������Ĭ��ʹ��pascal�﷨����ʽ
procedure LearnMatrixExp;
var
  m: TLMatrix;
begin
  DoStatus('');
  m := ExpressionToLMatrix(3, 4,
    '1*1,1*2,1*3,' +
    '2*1,2*2,2*3,' +
    '3*1,3*2,3*3,' +
    '4*4,4*5,4*6');
  DoStatus(m);
end;

// ����TLVec�������飬�������飬Ĭ��ʹ��pascal�﷨����ʽ
procedure LearnVecExp;
var
  v: TLVec;
begin
  DoStatus('');
  v := ExpressionToLVec('1,2,3,4,5,6,7,8,9');
  DoStatus(v);
end;

begin
  MatrixExp;
  MatrixVec;
  LearnMatrixExp;
  LearnVecExp;
  DoStatus('preee exter key to exit.');
  readln;
end.