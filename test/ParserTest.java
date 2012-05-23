
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CommonTokenStream;
import org.junit.BeforeClass;
import org.antlr.runtime.RecognitionException;
import org.junit.Test;

import qicvg.qicvgLexer;
import qicvg.qicvgParser;


public class ParserTest {

static ArrayList<String> files = new ArrayList<String>(), failFiles = new ArrayList<String>();
	
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		String testdir = "test" + File.separator;
		File currentDirectory = new File(testdir);
		for (String fn : currentDirectory.list()){
			if (fn.endsWith(".failP.txt")){
				failFiles.add(testdir + fn);
			}
			else if (fn.endsWith(".txt") && !(fn.endsWith(".failL.txt"))){
				files.add(testdir + fn);
			}
		}
	}

	@Test
	public void testQicvgParser() throws IOException{
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
	
	public void testQicvgParserFail() throws IOException{
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
