tree grammar qicvgwalker;

options {
    tokenVocab=qicvg ; // reuse token types
    ASTLabelType=CommonTree; // $label will have type CommonTree
    output=template;
    rewrite=true;
}

prog 	:	(def|defs)*;

defs	:	^(('style'|'nfstyle') ID styledef);

def	:	^('line' ID ^(INITPOSITION point) ^(FINALPOSITION point) style?)
	|	^('path' ID ^(POSITION point) style? pathel*) -> path(id={$ID.text},style={$style.text})
	|	^('square' ID ^(POSITION point) ^(SIDELEN coord) style?)
	|	^('circle' ID ^(POSITION point) ^(RADIUS coord) style?) 
	|	^(REGULARSHAPE ID ^(POSITION point) ^(HORIZLEN coord) ^(VERTLEN coord) style?)
	|	^(COMPLEXSHAPE ID ^(POSITION point) ^(RADIUS coord) ^(VERTEXES coord) style?)
	|	^('container' ID ^(POSITION point) (containerrow)*)
	;
	
containerrow	:	def
		|defs
		|innerdef;

innerdef:	^(ID ID ^(INITPOSITION point) ^(FINALPOSITION point));
	
style	:	styledef | ID;

styledef 	:	^(STYLE (^(FILLCOLOR fc=color))? (^(BORDERCOLOR bc=color))? (^(BORDERWIDTH INT))?) -> styledef(color={$fc.text},bordercolor={$bc.text},width={$INT.text}) 
          ;
	
point	:	coord coord;

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



math	:	^(('+'|'-') term math)
	|	term;

term	:	^(('*'|'/') atom term)
	|	atom;

coord	:	math;

atom	:	('+'|'-')?INT| ^(MATH math) | ^(ID IDATTRIB) ;



