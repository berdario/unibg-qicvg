package qicvg;

public class IdReference extends QicvgTree {
	public Style accept(QicvgWalker w){
		return w.visit(this);
	}
	
	public IdReference(QicvgTree t) {
		super(t);
	}
}
