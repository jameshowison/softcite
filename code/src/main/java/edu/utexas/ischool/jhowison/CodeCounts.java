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



public class CodeCounts {
	
	public static void main(String[] args) {
		
		// use the FileManager to load the .ttl file as the model
//		Model model = FileManager.get().loadModel("/Users/howison/Dropbox/Shared Software Citation Folder/ttl-coding/JamesCoding/JamesCoding.ttl");
		Model model = FileManager.get().loadModel("/Users/howison/Dropbox/Shared Software Citation Folder/ttl-coding/CatherineCoding/CatherineCoding.ttl");
		
		if (model == null) {
			throw new IllegalArgumentException(
			"ttl file not found");
			}


		/**************************************************				
		 QUERY 1 - CODE COUNT:
		 Create a new query that counts the number of software mentions in the .ttl file. 
		 Note that this query uses the number of "in-text_mentions" codes as a proxy for number of overall codes. 
		**************************************************/
		
		String queryString1 = 

			"PREFIX ca: <http://floss.syr.edu/ontologies/2008/4/contentAnalysis.owl#>" + " " +
			"PREFIX citec: <http://james.howison.name/ontologies/software-citation-coding#>" + " " +
			"SELECT (count(*) AS ?inTextMentionCodesApplied)" + " " +
			"WHERE  {" +
				"?selection ca:appliesCode citec:in-text_mention ." + " " +
			"}";

		Query query1 = QueryFactory.create(queryString1);
		
		// Execute the query and obtain results
		QueryExecution qe1 = QueryExecutionFactory.create(query1, model);
		ResultSet results1 = qe1.execSelect();
		
		// Output query results	
		ResultSetFormatter.out(System.out, results1, query1);
		
		// Important - free up resources used running the query
		qe1.close();


		/**************************************************				
		 QUERY 2 - SOFTWARE NAMES:
		 Create a new query that retrieves a unique list of software names found during the course of coding
		**************************************************/

		String queryString2 = 

			"PREFIX citec: <http://james.howison.name/ontologies/software-citation-coding#>" + " " +
			"PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>" + " " +
			"SELECT DISTINCT ?listOfUniqueSoftwareNames" + " " +
			"WHERE  {" +
				"?selection a citec:software_name ." + " " +
				"?selection rdfs:label ?listOfUniqueSoftwareNames ." +
			"}";

		Query query2 = QueryFactory.create(queryString2);
		
		// Execute the query and obtain results
		QueryExecution qe2 = QueryExecutionFactory.create(query2, model);
		ResultSet results2 = qe2.execSelect();
		
		// Output query results	
		ResultSetFormatter.out(System.out, results2, query2);
		
		// Important - free up resources used running the query
		qe2.close();
		// END QUERY 2 - CODE COUNT


	}

}
