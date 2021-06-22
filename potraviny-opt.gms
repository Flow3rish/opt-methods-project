
$funclibin stolib stodclib
function icdfnorm /stolib.icdfnormal/;

SETS
i 'potraviny'
j 'nutrienty'
s 'scenare' /s1*s5/;


DISPLAY s;

$call csv2gdx potraviny.csv id=nutr index=1 values=2..5 useHeader=y trace=0 output=potraviny.gdx
$ifE errorLevel<>0 $abort Problems reading potraviny.csv!

$gdxIn potraviny.gdx
$load i = dim1
$load j = dim2

PARAMETER nutr(i,j) 'potraviny nutrienty';
$load nutr
$gdxIn
DISPLAY i, j, nutr;

$call csv2gdx potraviny.csv id=v index=1 values=7 useHeader=y trace=0 output=ceny-velkoobchod.gdx
$ifE errorLevel<>0 $abort Problems reading potraviny.csv!

$gdxIn ceny-velkoobchod.gdx
PARAMETER v(i) 'ceny velkooobchod';
$load v
$gdxIn
DISPLAY i, v;


$call csv2gdx potraviny.csv id=m index=1 values=8 useHeader=y trace=0 output=ceny-maloobchod.gdx
$ifE errorLevel<>0 $abort Problems reading potraviny.csv!

$gdxIn ceny-maloobchod.gdx
PARAMETER m(i) 'ceny malooobchod';
$load m
$gdxIn
DISPLAY i, m;

$call csv2gdx potraviny.csv id=sug index=1 values=6 useHeader=y trace=0 output=sugar.gdx
$ifE errorLevel<>0 $abort Problems reading potraviny.csv!

$gdxIn sugar.gdx
PARAMETER sug(i) 'ceny velkooobchod';
$load sug
$gdxIn
DISPLAY i, sug;

PARAMETERS
kvantil 'kvantil' /0.95/
max_sugar 'pevne maximum konzumovaneho cukru' /36/
max_kcal  'pevne maximum konzumovanych kalorii' /3500/
p(s) 'pravdepodobnost scenare s'
/s1 0.061112977,
 s2 0.242105585,
 s3 0.393562877,
 s4 0.242105585,
 s5 0.056112977/

;
TABLE nutr_req(j, s) 'nutrition pozadovane hodnoty scenaru'

            s1      s2      s3    s4     s5   
kcal        2106    2380    2653  2926   3200
protein     137     154	   172   190	    207
carbs       237     267	   298   329	    359
fat         68      77      86    95     104  
;

POSITIVE VARIABLES
vx(i) 'mnozstvi nakoupeno ve velkoobchode'
mx(i, s) 'mnozstvi dokooupeno v maloobchode'


FREE VARIABLE z 'hodnota OF';

EQUATIONS
OF                   'ucelova funkce'
NUTRIENTS_CON    'minimalni nutrienty'
SUGAR_CON        'omezeni cukru'
MAX_SOY_PROTEIN     'omezeni suplementace sojovym proteinem'
;

OF..                        sum((i, s), vx(i)*v(i) + p(s)*mx(i, s)*m(i))                         =e=     z;
NUTRIENTS_CON(j, s)..       sum(i, vx(i)*nutr(i, j) + mx(i, s)*nutr(i, j))                       =e=     nutr_req(j, s);
SUGAR_CON(s)..              sum(i, vx(i)*sug(i) + mx(i, s)*sug(i))                               =l=     max_sugar;
MAX_SOY_PROTEIN(s)..        vx('sojovy protein') + mx('sojovy protein', s)                       =l=     50/100;

MODEL potraviny /all/;
SOLVE potraviny USING LP minimizing z;
