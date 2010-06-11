import org.antlr.runtime.tree.CommonTreeAdaptor;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.Token;
import org.antlr.runtime.TokenStream;

public class QicvgTreeAdaptor extends CommonTreeAdaptor {
	@Override
	public Object create(Token payload) {
		return new QicvgTree(payload);
	}

	/*
	 * @Override public Object errorNode(TokenStream input, Token start, Token
	 * stop, RecognitionException e) { return new QicvgTreeErrorNode(input,
	 * start, stop, e); }
	 */
}
