import static org.junit.Assert.*;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import org.junit.BeforeClass;
import org.junit.Test;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CommonTokenStream;

public class LexerTest {
	
	static ArrayList<String> files = new ArrayList<String>(), failFiles = new ArrayList<String>();
	
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		File currentDirectory = new File(".");
		for (String fn : currentDirectory.list()){
			if (fn.endsWith(".failL.txt")){
				failFiles.add(fn);
			}
			else if (fn.endsWith(".txt")){
				files.add(fn);
			}
		}
	}
	
	@Test
	public void testQicvgLexer() throws IOException{
		for (String f : files){
			qicvgLexer lex = new qicvgLexer(new ANTLRFileStream(f,"UTF8"));
			CommonTokenStream tokens = new CommonTokenStream(lex);
			tokens.getTokens();
			//TODO ripristinare rilevamento eccezioni
			//assertTrue("Errore inaspettato nel lexing di "+f, lex.getExceptions().size()==0 );
		}
		for (String f : failFiles){
			qicvgLexer lex = new qicvgLexer(new ANTLRFileStream(f,"UTF8"));
			CommonTokenStream tokens = new CommonTokenStream(lex);
			tokens.getTokens();
			//TODO ripristinare rilevamento eccezioni
			//assertTrue("Riconoscimento invalido dei token in "+f, lex.getExceptions().size()>0 );
		}
	}

}
