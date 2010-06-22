
public class Expr extends QicvgTree {
	public Double accept(QicvgWalker w){
		return w.visit(this);
	}
	
	public Expr(QicvgTree t) {
		super(t);
	}
}
