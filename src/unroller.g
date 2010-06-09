tree grammar unroller;

options {
  output = AST;
  tokenVocab = qicvg;
  ASTLabelType = CommonTree;
}

@header {
  import java.util.HashMap;
  import java.util.ArrayList;
}

@members{
  HashMap<String,ArrayList<CommonTree>> containers;
  int depth;
  
  CommonTree unroll(String containerid, String refid, double x, double y, double scale, double angle){
    CommonTree r = new CommonTree();
    for (CommonTree t : containers.get(containerid)){
        r.addChild(t);
    }
    return r;
  }
}

prog [int recursionDepth, HashMap<String,ArrayList<CommonTree>> containers]
 @init{
    this.containers=containers;
    depth = recursionDepth;
 }
 : (rows+=row)* ;

row   : def | comment; 

comment: ^(COMMENT COMMENTTEXT);

def :
    ^('line' ID ^(INITPOSITION p1=point) ^(FINALPOSITION p2=point) style?) 
  | ^('path' ID ^(POSITION point) style? pathelements+=pathel*) 
  | ^('square' ID ^(POSITION point) ^(SIDELEN expr) style?) 
  | ^('circle' ID ^(POSITION point) ^(RADIUS expr) style?) 
  | ^('rect' ID ^(POSITION point) ^(HORIZLEN h=expr) ^(VERTLEN v=expr) style?) 
  | ^('ellipse' ID ^(POSITION point) ^(HORIZLEN h=expr) ^(VERTLEN v=expr) style?) 
  | ^('star' ID ^(POSITION point) ^(RADIUS r=expr) ^(VERTEXES n=expr) style?)  
  | ^('polreg' ID ^(POSITION point) ^(RADIUS r=expr) ^(VERTEXES n=expr) style?)
  | ^('container' ( ID ^(POSITION point) ) containerblock )
  | ^(('style'|'nfstyle') ID styledef)
  ;
  
containerblock
     :  (containerdefs+=containerrow)*  ;
  
containerrow :  innerdef | comment;

innerdef:
    def 
  | ^(containerid=ID thisid=ID ^(POSITION point) ^(SCALE scale=FLOAT) ^(ANGLE angle=FLOAT))
    //possibile un approccio depthfirst o breadthfirst... scelgo un depthfirst:
    //nel caso di frattali semplici (con una sola componente ricorsiva), l'unroll avviene con una sola passata
    //il depthfirst permette di sfruttare l'id di questo oggetto, mentre con un breadthfirst sarebbe superfluo
    //in realtà potrei scriverlo anche come un depthfirst che non richiede id per l'oggetto
    //ripensandoci facendo in questo modo sarei sicuro che l'unroll avvenga in una sola passata, e non dovrei tirarmi dietro un id inutile in più
    //però pensandoci ancora, se unrollo solo un contenitore per volta rischio di avere problemi in caso di 2 contenitori con riferimenti vicendevoli
    //e ripensandoci ancora, l'ipotesi iniziale di unrollare solo un dato oggetto per volta, distinguendolo dall'id, mi permette di capire più facilmente la profondità del ciclo, grazie alla ricorsione sulla funzione
    //cosa che invece non è così facilmente fattibile iniziando a fare chiamate ricorsive per gestire oggetti diversi...
    //ora che ci penso forse potrei comunque lasciar cadere gli id inutili, generandoli implicitamente all'interno di questa regola... o meglio ancora durante il primo parsing, durante il quale ne conosco anche il numero
    -> {unroll($containerid.text,$thisid.text,0,0,new Double($scale.text),new Double($angle.text))}
  ;
  
style : styledef | ID;

styledef  
    : ^(STYLE (^(FILLCOLOR fc=color))? (^(BORDERCOLOR bc=color))? (^(BORDERWIDTH INT))?);
    
  
point : expr expr;


pathel  : ^(MOVETO ^(POSITION point))
  | ^(LINETO ^(POSITION point))
  | CLOSE
  | ^(HORIZONTALLINE expr)
  | ^(VERTICALLINE expr)
  | ^(BEZIER ^(CONTROLPOINT p1=point) ^(CONTROLPOINT p2=point) ^(CONTROLPOINT p3=point) ) 
  | ^(SHORTHANDBEZIER ^(CONTROLPOINT p1=point) ^(CONTROLPOINT p2=point) )
  | ^(SHORTHANDQUADRATICBEZIER ^(CONTROLPOINT points+=point) (^(CONTROLPOINT points+=point))* )
  | ^(QUADRATICBEZIER ^(CONTROLPOINT points+=point) (^(CONTROLPOINT points+=point))+ )
  ;

color : COLORNAME|HEXNUMBER;

expr : ^('+' e1=expr e2=expr) 
  |^('-' e1=expr e2=expr) 
  | term
  ;

term :  ^('*' t1=term t2=term)
  | ^('/' t1=term t2=term)
  | atom
  ;

atom :
    signedint 
  | ^(MATH expr)
  | ^(ID IDATTRIB) 
  ;
    
signedint : ('+'|'-')?INT;



