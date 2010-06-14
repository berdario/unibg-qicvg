tree grammar unroller;

options {
  output = AST;
  tokenVocab = qicvg;
  ASTLabelType = QicvgTree;
}

@header {
  import java.util.HashMap;
  import java.util.ArrayList;
}

@members{
  HashMap<String,ArrayList<QicvgTree>> containers;
  int depth;
  //Stack<Integer> currentDepth = new Stack<Integer>();
  ArrayList<Integer> currentDepth = new ArrayList<Integer>();
  boolean hasFinishedUnrolling=true;
  
  ArrayList<QicvgTree> unroll(String containerid, String refid, double x, double y, double scale, double angle){
    ArrayList<QicvgTree> r = new ArrayList<QicvgTree>();
    String innerid;
    QicvgTree newtree;
    for (QicvgTree t : containers.get(containerid)){
        if (t.getToken().getText().equals(containerid)){
          innerid = ((QicvgTree)t.getFirstChildWithType(ID)).getToken().getText();
          if (innerid.equals(refid)){
            if ( currentDepth.get(0)<depth ){
              currentDepth.add(0,currentDepth.get(0)+1);
              r.addAll(unroll(containerid, refid, x, y, scale, angle));
            } else {
              currentDepth.remove(0);
            }
          } else if(currentDepth.get(0)<depth) {
            currentDepth.add(0,currentDepth.get(0)+1);
            r.addAll(unroll(containerid, innerid, x, y, scale, angle));
          }
        } else{
            newtree = new QicvgTree(t);
            //newtree.setChild(0,new QicvgTree(new CommonToken(ID,((QicvgTree) newtree.getChild(0)).getToken().getText().substring(0,6)+((char)(Math.random()*26+'a')))));
            try{
              newtree.setParent(null);
              newtree.setChildIndex(-1);
              //System.err.println(newtree.toStringTree());
              newtree.freshenParentAndChildIndexes();
              newtree.sanityCheckParentAndChildIndexes();
            } catch(IllegalStateException e){
              System.err.println(e);
            }
            r.add(newtree);
        }
    }
    /*r.freshenParentAndChildIndexes();
    r.freshenParentAndChildIndexes();
    r.setUnknownTokenBoundaries();
    r.sanityCheckParentAndChildIndexes();*/
    return r;
  }
  
  QicvgTree startunroller(String containerid, String refid, double x, double y, double scale, double angle){
    QicvgTree r = new QicvgTree();
    r.sanityCheckParentAndChildIndexes();
    r.addChildren( unroll(containerid, refid, x, y, scale, angle));
    //r.freshenParentAndChildIndexes();
    //r.freshenParentAndChildIndexes();
    r.sanityCheckParentAndChildIndexes();
    return r;
  }
  
}



prog [int recursionDepth, HashMap<String,ArrayList<QicvgTree>> containers]
 @init{
    this.containers=containers;
    depth = recursionDepth;
    currentDepth.add(0);
 }
 : (rows+=row)* ;

row   : def | comment; 

comment: ^(COMMENT COMMENTTEXT) -> ^(COMMENT);

def 
  @after{
  $def.tree.freshenParentAndChildIndexes();
  $def.tree.sanityCheckParentAndChildIndexes();}
:
    ^('line' ID ^(INITPOSITION p1=point) ^(FINALPOSITION p2=point) style?) -> ^('line')
  | ^('path' ID ^(POSITION point) style? pathelements+=pathel*) -> ^('path')
  | ^('square' ID ^(POSITION point) ^(SIDELEN expr) style?)  -> ^('square')
  | ^('circle' ID ^(POSITION point) ^(RADIUS expr) style?)  -> ^('circle')
  | ^('rect' ID ^(POSITION point) ^(HORIZLEN h=expr) ^(VERTLEN v=expr) style?) -> ^('rect') 
  | ^('ellipse' ID ^(POSITION point) ^(HORIZLEN h=expr) ^(VERTLEN v=expr) style?) -> ^('ellipse')
  | ^('star' ID ^(POSITION point) ^(RADIUS r=expr) ^(VERTEXES n=expr) style?) -> ^('star')
  | ^('polreg' ID ^(POSITION point) ^(RADIUS r=expr) ^(VERTEXES n=expr) style?) -> ^('polreg')
  | ^('container' ( ID ^(POSITION point) ) containerblock ) -> containerblock
  | ^('style' ID styledef) -> ^('style')
  | ^('nfstyle' ID styledef) -> ^('nfstyle')
  ;
  
containerblock
     :  (containerdefs+=containerrow)*  ;
  
containerrow :  innerdef | comment;

innerdef:
    def  -> 
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
    
    
    -> {startunroller($containerid.text,$thisid.text,$point.c1,$point.c2,new Double($scale.text),new Double($angle.text))}
  ;
  
style : styledef | ID;

styledef  
    : ^(STYLE (^(FILLCOLOR fc=color))? (^(BORDERCOLOR bc=color))? (^(BORDERWIDTH INT))?);
    
  
point returns [int c1, int c2]  : expr1=expr expr2=expr { try{$c1=$expr1.val.intValue(); $c2=$expr2.val.intValue();}catch(NumberFormatException e){}};


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

expr returns [Double val] : ^('+' e1=expr e2=expr) {$val=$e1.val+$e2.val;}
  |^('-' e1=expr e2=expr) {$val=$e1.val-$e2.val;}
  | term {$val=$term.val;};

term returns [Double val]:  ^('*' t1=term t2=term) {$val=$t1.val*$t2.val;}
  | ^('/' t1=term t2=term) {$val=$t1.val/$t2.val;}
  | atom {$val=$atom.val;};

atom returns [Double val] :
    signedint 
    {
      $val = $signedint.val;
    }
  | ^(MATH expr)
    {
      $val = $expr.val;
    }
  | ^(ID IDATTRIB) 
    {
      $val = 0.0;
      //TODO, inserire scope, etc.
    }
  ;
    
signedint returns [Double val]: (sign='+'|sign='-')?INT 
  {
    $val=new Double($INT.text);
    if ($sign != null && $sign.text.equals("-")){
      $val=-$val;
    }
  };



