import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.CommonTreeNodeStream;
import org.antlr.stringtemplate.StringTemplateGroup;

public class Main {

	public static void main(String[] args) throws IOException,
			org.antlr.runtime.RecognitionException {
		Main mainclass = new Main();

		for (String path : args) {

			File sourceFile = new File(path);

			String destDir = sourceFile.getParent();
			String destFileName = changeExtension(sourceFile.getName(), ".svg");
			File destFile = new File(destDir, destFileName);

			FileWriter out = new FileWriter(destFile);

			out.write(mainclass.translate(path));
			out.close();
		}
	}

	private static String changeExtension(String originalName,
			String newExtension) {
		int lastDot = originalName.lastIndexOf(".");
		if (lastDot != -1) {
			return originalName.substring(0, lastDot) + newExtension;
		} else {
			return originalName + newExtension;
		}
	}

	public String translate(String path) throws IOException,
			org.antlr.runtime.RecognitionException {
		// LOAD TEMPLATES
		String groupFileName = "qicvgwalker.stg";
		InputStream groupStream = getClass().getResourceAsStream(groupFileName);
		InputStreamReader groupReader = new InputStreamReader(groupStream);
		StringTemplateGroup templates = new StringTemplateGroup(groupReader);
		groupReader.close();

		// PARSE INPUT AND BUILD AST
		ANTLRFileStream input = new ANTLRFileStream(path, "UTF8");
		qicvgLexer lexer = new qicvgLexer(input);

		CommonTokenStream tokens = new CommonTokenStream(lexer);
		qicvgParser parser = new qicvgParser(tokens);
		parser.setTreeAdaptor(new QicvgTreeAdaptor());

		qicvgParser.prog_return ret = parser.prog();
		QicvgTree tree = (QicvgTree) ret.getTree();
		if (ret.tree != null) { // needed when the input is empty
			// System.out.println("AST generato:");
			// System.out.println(tree.toStringTree());

			QicvgTreeNodeStream aststream = new QicvgTreeNodeStream(tree);
			aststream.setTokenStream(tokens);
			QicvgWalker walker = new QicvgWalker(aststream,templates);

			return walker.walk(100);
		}
		throw new org.antlr.runtime.RecognitionException();

	}

}
