tree grammar qicvgwalker;

options {
    tokenVocab=qicvg ; // reuse token types
    ASTLabelType=CommonTree; // $label will have type CommonTree
    output=template;
    rewrite=true;
}

@members{
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

prog 	:	(def comment*)*;

comment: ^(COMMENTTEXT COMMENT) -> template(c={$COMMENT.text}) "\<!--<c>--\>" ;

def:
  	^('line' ID ^(INITPOSITION p1=point) ^(FINALPOSITION p2=point) style?) 
  	 -> line(id={$ID.text},x1={$p1.c1},y1={$p1.c2},x2={$p2.c1},y2={$p2.c2},style={$style.text})
	|	^('path' ID ^(POSITION point) style? pathelements+=pathel*) 
	   -> path(id={$ID.text},point={$point.text},pathelements={$pathelements},style={$style.text})
	|	^('square' ID ^(POSITION point) ^(SIDELEN coord) style?) 
	   -> square(id={$ID.text},x={$point.c1},y={$point.c2},size={$coord.text},style={$style.text})
	|	^('circle' ID ^(POSITION point) ^(RADIUS coord) style?) 
	   -> circle(id={$ID.text},cx={$point.c1},cy={$point.c2},r={$coord.text},style={$style.text})
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
	
containerrow	:	innerdef comment*;

innerdef:
    def	
  | ^(ID ID ^(INITPOSITION point) ^(FINALPOSITION point));
	
style	:	styledef | ID;

styledef 	:	^(STYLE (^(FILLCOLOR fc=color))? (^(BORDERCOLOR bc=color))? (^(BORDERWIDTH INT))?) -> styledef(color={$fc.text},bordercolor={$bc.text},width={$INT.text}) ;
	
point returns [int c1, int c2]	:	coord1=coord coord2=coord {try{$c1=new Integer($coord1.text); $c2=new Integer($coord2.text);}catch(NumberFormatException e){}} 
-> template(c1={$coord1.text},c2={$coord2.text}) "<c1> <c2> "
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



math  :	^(('+'|'-') math math)
	|	term;

term	:	^(('*'|'/') term term)
	|	atom;

coord	:	math;

atom  :	(sign='+'|sign='-')?INT -> template(sign={$sign},int={$INT}) "<if(sign)><sign><endif><int>"
  | ^(MATH math) -> template() "0"
  | ^(ID IDATTRIB) -> template() "0";



