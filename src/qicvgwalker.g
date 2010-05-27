tree grammar qicvgwalker;

options {
    tokenVocab=qicvg ; // reuse token types
    ASTLabelType=CommonTree; // $label will have type CommonTree
    output=template;
    rewrite=true;
}

prog 	:	(def|defs)*;

defs	:	^(('style'|'nfstyle') ID styledef) -> ;

def	:	^('line' ID ^(INITPOSITION p1=point) ^(FINALPOSITION p2=point) style?) -> line(id={$ID.text},x1={$p1.c1},y1={$p1.c2},x2={$p2.c1},y2={$p2.c2},style={$style.text})
	|	^('path' ID ^(POSITION point) style? pathel*) -> path(id={$ID.text},style={$style.text})
	|	^('square' ID ^(POSITION point) ^(SIDELEN coord) style?) -> square(id={$ID.text},x={$point.c1},y={$point.c2},size={$coord.text},style={$style.text})
	|	^('circle' ID ^(POSITION point) ^(RADIUS coord) style?) -> circle(id={$ID.text},cx={$point.c1},cy={$point.c2},r={$coord.text},style={$style.text})
	|	^(REGULARSHAPE ID ^(POSITION point) ^(HORIZLEN coord) ^(VERTLEN coord) style?)
	|	^(COMPLEXSHAPE ID ^(POSITION point) ^(RADIUS coord) ^(VERTEXES coord) style?)
	|	^('container' ID ^(POSITION point) (containerrow)*)
	;
	
containerrow	:	def
		|defs
		|innerdef;

innerdef:	^(ID ID ^(INITPOSITION point) ^(FINALPOSITION point));
	
style	:	styledef | ID;

styledef 	:	^(STYLE (^(FILLCOLOR fc=color))? (^(BORDERCOLOR bc=color))? (^(BORDERWIDTH INT))?) -> styledef(color={$fc.text},bordercolor={$bc.text},width={$INT.text}) ;
	
point returns [int c1, int c2]	:	coord1=coord coord2=coord {try{$c1=new Integer($coord1.text); $c2=new Integer($coord2.text);}catch(NumberFormatException e){}} ;

pathel	:	^(MOVETO ^(POSITION point))
	|	^(LINETO ^(POSITION point))
	|	CLOSE
	|	^(HORIZONTALLINE coord)
	|	^(VERTICALLINE coord)
	|	^(BEZIER ^(CONTROLPOINT point) ^(CONTROLPOINT point) ^(CONTROLPOINT point) )
	|	^(SHORTHANDBEZIER ^(CONTROLPOINT point) ^(CONTROLPOINT point) )
	|	^(SHORTHANDQUADRATICBEZIER ^(CONTROLPOINT point) (^(CONTROLPOINT point))* )
	|	^(QUADRATICBEZIER ^(CONTROLPOINT point) (^(CONTROLPOINT point))+ )
	;

color	:	COLORNAME|HEXNUMBER;



math	:	^(('+'|'-') math math)
	|	term;

term	:	^(('*'|'/') term term)
	|	atom;

coord	:	math;

atom	:	('+'|'-')?INT| ^(MATH math) | ^(ID IDATTRIB) ;



