
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.junit.BeforeClass;
import org.junit.Test;


public class ParserTest {

static ArrayList<String> files = new ArrayList<String>(), failFiles = new ArrayList<String>();
	
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		File currentDirectory = new File(".");
		for (String fn : currentDirectory.list()){
			if (fn.endsWith(".failP.txt")){
				failFiles.add(fn);
			}
			else if (fn.endsWith(".txt") && !(fn.endsWith(".failL.txt"))){
				files.add(fn);
			}
		}
	}

	@Test
	public void testQicvgLexer() throws IOException{
		for (String f : files){
			qicvgLexer lex = new qicvgLexer(new ANTLRFileStream(f,"UTF8"));
			CommonTokenStream tokens = new CommonTokenStream(lex);
			qicvgParser parser = new qicvgParser(tokens);
			try {
				parser.prog();
			} catch (RecognitionException e) {
				fail("Errore inaspettato nel parsing di "+f);
			}
			assertTrue("Errore inaspettato nel parsing di "+f, parser.getExceptions().size()==0 );
			//TODO ripristinare rilevamento eccezioni
			//assertTrue("Errore inaspettato nel lexing di "+f, lex.getExceptions().size()==0 );
		}
	}
	
	//@Test(expected = RecognitionException.class)
	
	public void testQicvgLexerFail() throws IOException{
		for (String f : failFiles){
			qicvgLexer lex = new qicvgLexer(new ANTLRFileStream(f,"UTF8"));
			CommonTokenStream tokens = new CommonTokenStream(lex);
			qicvgParser parser = new qicvgParser(tokens);
			try {
				parser.prog();
				fail("Riconoscimento invalido delle produzioni in "+f);
			} catch (RecognitionException e) {
			} finally{
				//assertTrue("Errore inaspettato nel lexing in "+f, lex.getExceptions().size()==0 );
			}
		}
	}


}
