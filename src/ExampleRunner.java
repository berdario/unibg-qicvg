import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.IOException;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.CommonTreeAdaptor;
import org.antlr.runtime.tree.CommonTreeNodeStream;


public class ExampleRunner {

	/**
	 * @param args
	 * @throws IOException 
	 * @throws RecognitionException 
	 */
	public static void main(String[] args) throws IOException, RecognitionException {
		qicvgLexer lex = new qicvgLexer(new ANTLRFileStream("/home/dario/Documenti/linguaggi/qicvg/test/test1.txt","UTF8"));
		CommonTokenStream tokens = new CommonTokenStream(lex);
		qicvgParser parser = new qicvgParser(tokens);
		
		parser.setTreeAdaptor(new CommonTreeAdaptor());
		qicvgParser.prog_return ret = parser.prog();
		CommonTree tree = (CommonTree) ret.getTree();
		if (ret.tree != null) { // needed when the input is empty
			System.out.println(tree.toStringTree());

			qicvgwalker walker = new qicvgwalker(new CommonTreeNodeStream(tree));
			walker.prog();
		}

	}

}
