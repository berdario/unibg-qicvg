tree grammar unroller;

options {
  output = AST;
  tokenVocab = qicvg;
  ASTLabelType = QicvgTree;
}

@header {
  import java.util.HashMap;
  import java.util.ArrayList;
  import java.util.Arrays;
  import static java.lang.Math.cos;
  import static java.lang.Math.sin;
}

@members{
  HashMap<String,ArrayList<QicvgTree>> containers;
  HashMap<String,HashMap<String,Number>> containerPositions = new HashMap<String,HashMap<String,Number>>();
  int depth;
  //Stack<Integer> currentDepth = new Stack<Integer>();
  ArrayList<Integer> currentDepth = new ArrayList<Integer>();
  boolean hasFinishedUnrolling=true;
  
  ArrayList<QicvgTree> unroll(String containerid, String refid, QicvgTree x, QicvgTree y, double scaleFactor, double angle, HashMap<String,QicvgTree> previousTree){
    HashMap<String,QicvgTree> previous = previousTree; 
    ArrayList<QicvgTree> r = new ArrayList<QicvgTree>();
    String innerid;
    QicvgTree newtree;
    for (QicvgTree t : containers.get(containerid)){
        if (t.getToken().getText().equals(containerid)){
          innerid = ((QicvgTree)t.getFirstChildWithType(ID)).getToken().getText();
          if (innerid.equals(refid)){
            if ( currentDepth.get(0)<depth ){
              currentDepth.add(0,currentDepth.get(0)+1);
              r.addAll(unroll(containerid, refid, x, y, scaleFactor, angle, previous));
            } else {
              currentDepth.remove(0);
            }
          } else if(currentDepth.get(0)<depth) {
            currentDepth.add(0,currentDepth.get(0)+1);
            
            QicvgTree newx = (QicvgTree) ((QicvgTree) t.getChild(1)).getChild(0);
            QicvgTree newy = (QicvgTree) ((QicvgTree) t.getChild(1)).getChild(1);
            double newscale = new Double(((QicvgTree)((QicvgTree) t.getChild(2)).getChild(0)).getToken().getText());
            double newangle = new Double(((QicvgTree)((QicvgTree) t.getChild(3)).getChild(0)).getToken().getText());
            
            r.addAll(unroll(containerid, innerid, newx, newy, newscale, newangle, previous));
          }
        } else{
            newtree = new QicvgTree(t);
            String id = ((QicvgTree) newtree.getChild(0)).getToken().getText();
            if (previous.get(id)!=null){
              newtree = new QicvgTree(previous.get(id)); 
            }
            newtree = transform(newtree, x, y, angle, scaleFactor);
            previous.put(id,newtree);
            
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
  
  QicvgTree startunroller(String containerid, String refid, QicvgTree x, QicvgTree y, double scaleFactor, double angle){
    QicvgTree r = new QicvgTree();
    r.sanityCheckParentAndChildIndexes();
    r.addChildren( unroll(containerid, refid, x, y, scaleFactor, angle, new HashMap<String,QicvgTree>()));
    //r.freshenParentAndChildIndexes();
    //r.freshenParentAndChildIndexes();
    r.sanityCheckParentAndChildIndexes();
    return r;
  }
  
  QicvgTree transform(QicvgTree tree, QicvgTree x, QicvgTree y, double angle, double scale){
      QicvgTree nd;
      for (int i=1; i<tree.getChildCount(); i++){
        nd = (QicvgTree) tree.getChild(i);
        int type = nd.getType();
        if (type == POSITION || type == INITPOSITION || type == FINALPOSITION){
            QicvgTree firstExpr = (QicvgTree) nd.getChild(0);
            QicvgTree secondExpr = (QicvgTree) nd.getChild(1);
            //translate
            firstExpr = add(firstExpr, x);
            secondExpr = add(secondExpr, y);
            //rotate
            ArrayList<QicvgTree> result = rotate(x, y, firstExpr, secondExpr, angle);
            firstExpr = result.get(0);
            secondExpr = result.get(1);
            //scale
            nd.setChild(0, scale(firstExpr,scale));
            nd.setChild(1, scale(secondExpr,scale));
        } else if (type == SIDELEN || type == RADIUS ||
            type == HORIZLEN || type == VERTLEN){
          QicvgTree firstExpr = (QicvgTree) nd.getChild(0);
          QicvgTree secondExpr = (QicvgTree) nd.getChild(1);
          //scale
          nd.setChild(0, scale(firstExpr,scale));
          nd.setChild(1, scale(secondExpr,scale));
        }
      }
      return tree;
  }
  
  QicvgTree add(QicvgTree a, QicvgTree b){
      return applyOperation(new CommonToken('+',"+"), a, b);
  }
  
  QicvgTree sub(QicvgTree a, QicvgTree b){
      return applyOperation(new CommonToken('-',"-"), a, b);
  }
  
  QicvgTree mult(QicvgTree a, QicvgTree b){
      return applyOperation(new CommonToken('*',"*"), new QicvgTree(a), new QicvgTree(b));
  }
  
  QicvgTree applyOperation(Token operation, QicvgTree a, QicvgTree b){
      QicvgTree result = new QicvgTree(new CommonToken(MATH,"MATH")); 
      QicvgTree op = new QicvgTree(operation);
      op.addChild(a);
      op.addChild(b);
      result.addChild(op);
      return result;
  }
  
  ArrayList<QicvgTree> rotate(QicvgTree x1, QicvgTree y1, QicvgTree x2, QicvgTree y2, double angle){
    ArrayList<QicvgTree> result = new ArrayList<QicvgTree>();
    result.add( sub(sub(add(add(scale(x2, cos(angle)), scale(y2, sin(angle))), x1), scale(x1, cos(angle))), scale(y1, sin(angle))));
    result.add( sub(add(add(sub(scale(y2, cos(angle)), scale(x2, sin(angle))), y1), scale(x1, sin(angle))), scale(y1, cos(angle))));
    return result;
  }
  
  QicvgTree scale(QicvgTree node, double scaleFactor){
      return mult(node,new QicvgTree(new CommonToken(INT,Integer.toString((new Double(scaleFactor)).intValue())))); //TODO evitare di convertire in integer
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
  | ^('container' ( ID ^(POSITION c1=INT c2=INT)
     {
        if (containerPositions.get($ID.text) != null){
            System.out.println("id trovato: "+$ID.text); //TODO
        }
        HashMap<String,Number> pos = new HashMap<String,Number>();
        pos.put("x",new Integer($c1.text));
        pos.put("y",new Integer($c2.text)); 
        containerPositions.put($ID.text,pos);
     }
     ) containerblock ) -> containerblock
  | ^('style' ID styledef) -> ^('style')
  | ^('nfstyle' ID styledef) -> ^('nfstyle')
  ;
  
containerblock
     :  (containerdefs+=containerrow)*  ;
  
containerrow :  innerdef | comment;

innerdef
@after{
  System.err.println("blept");
  try{ //System.err.println(((QicvgTree)$innerdef.tree).toStringTree()); 
  } catch (NullPointerException e){
    //DIOCANE
  }
  
}:
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
    
    {System.err.println(((QicvgTree)((QicvgTree)$point.tree).getChild(0)).toStringTree());
    System.err.println(((QicvgTree)((QicvgTree)$point.tree).getChild(1)).toStringTree());
    }
    -> {startunroller($containerid.text,$thisid.text,(QicvgTree)((QicvgTree)$point.tree).getChild(0),(QicvgTree)((QicvgTree)$point.tree).getChild(1),new Double($scale.text),new Double($angle.text))}
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



