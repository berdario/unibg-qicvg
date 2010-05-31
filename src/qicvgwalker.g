tree grammar qicvgwalker;

options {
    tokenVocab=qicvg ; // reuse token types
    ASTLabelType=CommonTree; // $label will have type CommonTree
    output=template;
    rewrite=true;
}

@header{
  import java.util.HashMap;
}

@members{
  HashMap<String,HashMap<String,Number>> vars = new HashMap<String,HashMap<String,Number>>(); 

  HashMap<String,Number> initVar(String id){
       if (vars.get(id) != null) {
         //TODO throw eccezione
       }
       HashMap<String, Number> var = new HashMap<String, Number>();
       vars.put(id,var);
       return var;
  }
  
  public static String getStarPath(int x,int y,String r,String n){
    
    return "pathritornato";
  }
  
  public static String getPolygonPath(int x,int y,String r,String n){
    int nv = new Integer(n);
    int radius = new Integer(r);
    double internalarc=0;
    if (nv == 3){
      internalarc=120*Math.PI/180;
      //y+=radius;
      //radius*=2;
    } else if (nv > 3){
      internalarc=(360/nv)*Math.PI/180;
    }
    double currentx = x;
    double currenty = y-radius;
    double side = 2*radius*Math.sin(Math.PI/nv);
    String path = "M "+Math.round(currentx)+" "+Math.round(currenty)+" ";
    double currentarc=-internalarc/2;
    while(currentarc > -2*Math.PI){
      currentx-=Math.cos(currentarc)*side;
      currenty-=Math.sin(currentarc)*side;
      path+="L "+Math.round(currentx)+" "+Math.round(currenty)+" ";
      currentarc-=internalarc;
    }
    path+="Z";
    return path;
  }
}

prog 	:	(^(ROW def comment?) | ^(ROW comment))*;

comment: COMMENT -> template(c={$COMMENT.text}) "\<!--<c>--\>" ;

def:
  	^('line' ID ^(INITPOSITION p1=point) ^(FINALPOSITION p2=point) style?) 
  	 -> line(id={$ID.text},x1={$p1.c1},y1={$p1.c2},x2={$p2.c1},y2={$p2.c2},style={$style.text})
	|	^('path' ID ^(POSITION point) style? pathelements+=pathel*) 
	   -> path(id={$ID.text},point={$point.text},pathelements={$pathelements},style={$style.text})
	|	^('square' ID ^(POSITION point) ^(SIDELEN coord) style?) 
	   -> square(id={$ID.text},x={$point.c1},y={$point.c2},size={$coord.text},style={$style.text})
	|	^('circle' ID ^(POSITION point) ^(RADIUS coord) style?) 
	   {
	     HashMap<String, Number> var = initVar($ID.text);
	     var.put("cx",$point.c1);
	     var.put("cy",$point.c2);
	     var.put("r",$coord.val);
	   }
	   -> circle(id={$ID.text},cx={$point.c1},cy={$point.c2},r={$coord.val},style={$style.text})
	|	^(REGULARSHAPE ID ^(POSITION point) ^(HORIZLEN h=coord) ^(VERTLEN v=coord) style?) 
	   -> {$REGULARSHAPE.text.equals("rect")}? rect(id={$ID.text},x={$point.c1},y={$point.c2},width={$h.text},height={$v.text},style={$style.text}) 
	   -> ellipse(id={$ID.text},cx={$point.c1},cy={$point.c2},rx={$h.text},ry={$v.text},style={$style.text})
	|	^('star' ID ^(POSITION point) ^(RADIUS r=coord) ^(VERTEXES n=coord) style?) {String path=getStarPath($point.c1,$point.c2,$r.text,$n.text);} 
	   -> star(id={$ID.text},path={path},style={$style.text}) 
	| ^('polreg' ID ^(POSITION point) ^(RADIUS r=coord) ^(VERTEXES n=coord) style?) {String path=getPolygonPath($point.c1,$point.c2,$r.text,$n.text);}
	   -> polreg(id={$ID.text},path={path},style={$style.text})
	|	^('container' ID ^(POSITION point) (containerrow)*)
	| ^(('style'|'nfstyle') ID styledef) -> 
	;
	
containerrow	:	^(ROW innerdef comment?)| ^(ROW comment);

innerdef:
    def	
  | ^(ID ID ^(INITPOSITION point) ^(FINALPOSITION point));
	
style	:	styledef | ID;

styledef 	:	^(STYLE (^(FILLCOLOR fc=color))? (^(BORDERCOLOR bc=color))? (^(BORDERWIDTH INT))?) -> styledef(color={$fc.text},bordercolor={$bc.text},width={$INT.text}) ;
	
point returns [int c1, int c2]	:	coord1=coord coord2=coord { try{$c1=$coord1.val.intValue(); $c2=$coord2.val.intValue();}catch(NumberFormatException e){}} 
-> template(c1={$coord1.val.intValue()},c2={$coord2.val.intValue()}) "<c1> <c2> "
;

pathel	:	^(MOVETO ^(POSITION point)) -> template(p={$point.text}) "M <p> "
	|	^(LINETO ^(POSITION point)) -> template(p={$point.text}) "L <p> "
	|	CLOSE -> template() "Z"
	|	^(HORIZONTALLINE coord) -> template(c={$coord.text}) "H <c> "
	|	^(VERTICALLINE coord) -> template(c={$coord.text}) "V <c> "
	|	^(BEZIER ^(CONTROLPOINT p1=point) ^(CONTROLPOINT p2=point) ^(CONTROLPOINT p3=point) ) -> template(p1={$p1.text},p2={$p2.text},p3={$p3.text}) "C <p1> <p2> <p3> " 
	|	^(SHORTHANDBEZIER ^(CONTROLPOINT p1=point) ^(CONTROLPOINT p2=point) ) -> template(p1={$p1.text},p2={$p2.text}) "S <p1> <p2> "
	|	^(SHORTHANDQUADRATICBEZIER ^(CONTROLPOINT points+=point) (^(CONTROLPOINT points+=point))* ) -> template(points={$points}) "T <points>"
	|	^(QUADRATICBEZIER ^(CONTROLPOINT points+=point) (^(CONTROLPOINT points+=point))+ ) -> template(points={$points}) "T <points>"
	;

color	:	COLORNAME|HEXNUMBER;



math returns [Double val] :	^('+' m1=math m2=math) {$val=$m1.val+$m2.val;}
  |^('-' m1=math m2=math) {$val=$m1.val-$m2.val;}
	|	term {$val=$term.val;};

term returns [Double val]:	^('*' t1=term t2=term) {$val=$t1.val*$t2.val;}
  | ^('/' t1=term t2=term) {$val=$t1.val/$t2.val;}
	|	atom {$val=$atom.val;};

coord returns [Double val]	:	math {$val=$math.val;};

atom returns [Double val] :
  	signedint 
  	{
      $val = Double.parseDouble($signedint.text);
  	}
  | ^(MATH math)
    {
      $val = $math.val;
    }
  | ^(ID IDATTRIB) 
    {
      $val = 0.0;
      try{
         $val = vars.get($ID.text).get($IDATTRIB.text).doubleValue();
      } catch(Exception e){
        //e.printStackTrace();
      }
    }
  ;
    
signedint : (sign='+'|sign='-')?INT -> template(sign={$sign},int={$INT}) "<if(sign)><sign><endif><int>";


