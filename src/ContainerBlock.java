
public class ContainerBlock extends QicvgTree {
	public Object accept(QicvgWalker w){
		return w.visit(this);
	}
	
	public ContainerBlock(QicvgTree t) {
		super(t);
	}

	public ContainerBlock() {
		super();
	}
}
