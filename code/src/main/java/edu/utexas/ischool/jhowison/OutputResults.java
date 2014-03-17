package edu.utexas.ischool.jhowison;
/**********************************************************
Classpath must include these .jars (everything in $JENAROOT/lib/):

$JENAROOT/lib/commons-codec-1.5.jar:$JENAROOT/lib/httpclient-4.1.2.jar:$JENAROOT/lib/httpcore-4.1.3.jar:$JENAROOT/lib/icu4j-3.4.4.jar:$JENAROOT/lib/jena-arq-2.9.0-incubating.jar:$JENAROOT/lib/jena-core-2.7.0-incubating.jar:$JENAROOT/lib/jena-iri-0.9.0-incubating.jar:$JENAROOT/lib/log4j-1.2.16.jar:$JENAROOT/lib/slf4j-api-1.6.4.jar:$JENAROOT/lib/slf4j-log4j12-1.6.4.jar:$JENAROOT/lib/xercesImpl-2.10.0.jar:$JENAROOT/lib/xml-apis-1.4.01.jar:.

***********************************************************/

import java.io.*;
import java.util.*;

import com.hp.hpl.jena.*;
import com.hp.hpl.jena.util.*;
import com.hp.hpl.jena.rdf.model.*;
import com.hp.hpl.jena.query.*;

import com.hp.hpl.jena.sparql.*;
import com.hp.hpl.jena.sparql.engine.*;



public class OutputResults {
		
	public static void main(String[] args) {
		
		String myPathToOutput = args[0];
		
		TTLRepository myRepository = new TTLRepository();
		
		ResultSet articlesWithMentionsByStrata = myRepository.getArticlesWithCodeAppliedByStrata(
		  "http://james.howison.name/ontologies/software-citation-coding#in-text_mention"
		);
		
		writeResultsToOutputFile(articlesWithMentionsByStrata, myPathToOutput, "articles_with_mentions_by_strata.csv");
	}
	
	private static void writeResultsToOutputFile(ResultSet results, String path, String filename) {
		String fullFileName = path + "/" + filename;
		
		try {
			File myFile = new File(fullFileName);
		
			if ( ! myFile.exists() ) {
				myFile.createNewFile();
			}
			FileOutputStream oFile = new FileOutputStream(myFile, false); // don't append
			ResultSetFormatter.outputAsCSV(oFile, results);
			oFile.close();
		}
		catch(IOException ex){
        	System.out.println( ex.toString() );
        	System.out.println("Could not find file: " + fullFileName);
    	} 
	}
}