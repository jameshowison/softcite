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
import com.hp.hpl.jena.reasoner.*;

import com.hp.hpl.jena.sparql.*;
import com.hp.hpl.jena.sparql.engine.*;



public class TestMatches {
	
	public static void main(String[] args) {
		
		// use the FileManager to load the .ttl file as the model
//		Model model = FileManager.get().loadModel("/Users/howison/Dropbox/Shared Software Citation Folder/ttl-coding/JamesCoding/JamesCoding.ttl");
		TTLRepository myRep = new TTLRepository();
		Model rawModel = myRep.getModel();
		Reasoner reasoner = ReasonerRegistry.getOWLReasoner();
		// Attach a very basic reasoner
		InfModel model = ModelFactory.createInfModel(reasoner, rawModel);
		
		if (model == null) {
			throw new IllegalArgumentException(
			"ttl file not found");
			}

		double matches = numberOfMatches(model);
		System.out.println(matches);
		
		double agreements = numberOfAgreements("citec:software_used", model);
		System.out.println(agreements);
		
		double percentAgree = percentAgreement("citec:software_used", model);
		System.out.println("Agreed percentage: " + percentAgree);
		
		/**************************************************				
		 QUERY 1 - CODE COUNT:
		 Create a new query that counts the number of software mentions in the .ttl file. 
		 Note that this query uses the number of "in-text_mentions" codes as a proxy for number of overall codes. 
		**************************************************/
		
		// String queryString1 = 
		// 
		// "PREFIX xsd:   <http://www.w3.org/2001/XMLSchema#> " +
		// "PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> " +
		// "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> " +
		// "PREFIX owl:     <http://www.w3.org/2002/07/owl#> " +
		// 
		// "PREFIX ca: <http://floss.syr.edu/ontologies/2008/4/contentAnalysis.owl#>" +
		// "PREFIX doap: <http://usefulinc.com/ns/doap#>" +
		// 
		// "PREFIX bioj: <http://james.howison.name/ontologies/bio-journal-sample#>" + 
		// "PREFIX citec: <http://james.howison.name/ontologies/software-citation-coding#>" +
		// 
		// "SELECT ?itemURIJ" + 
		// " WHERE {  " + 

	// Query for analysis 1.  How many matches?
	
		// "  ?itemURIJ ca:matches ?itemURIC ." +
		// "  ?itemURIJ ca:isTargetOf " + 
		// 	"    			[ ca:hasCoder \"jhowison\" ;  " + 
		// 	"      			  ca:appliesCode citec:in_text_mention ;  " + 
		// 	"    			 ] ;  " +
		// 	"  . " + 
		// 	"  ?itemURIC ca:isTargetOf  " + 
		// 	"				[ ca:hasCoder \"cgrady\" ;  " + 
		// 	"			      ca:appliesCode citec:in_text_mention ;  " + 
		// 	"			    ] ; " + 
		// 	"  . " + 
		// "}";
		
		// Query for analysis 2.  For each matching URI, for each code how many did catherine get, how many did james get. 
		
	// 	// get list of match URIs ResultSet iterator probably.
	// 	String matchingURI = "bioj:bothC1";
	// 	
	// 	// list of codes, start with citec:software_used
	// //	String code = "citec:in_text_mention";
	// 	String code = "citec:software_used";
	// 	
	// 	
	// 	//# which coders applied this code to this URI
	// 	String queryString1 = 
	// 
	// 	"PREFIX xsd:   <http://www.w3.org/2001/XMLSchema#> " +
	// 	"PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> " +
	// 	"PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> " +
	// 	"PREFIX owl:     <http://www.w3.org/2002/07/owl#> " +
	// 
	// 	"PREFIX ca: <http://floss.syr.edu/ontologies/2008/4/contentAnalysis.owl#>" +
	// 	"PREFIX doap: <http://usefulinc.com/ns/doap#>" +
	// 
	// 	"PREFIX bioj: <http://james.howison.name/ontologies/bio-journal-sample#>" + 
	// 	"PREFIX citec: <http://james.howison.name/ontologies/software-citation-coding#>" +
	// 
	// 	"SELECT ?itemURIJ " + 
	// 	" WHERE { " +
	// 	"  ?itemURIJ ca:matches ?itemURIC ." +
	// 	"  FILTER ( ?itemURIC != ca:none ) " +
	// 	// "  ?itemURIJ ca:isTargetOf " + 
	// 	// 	"    			[ ca:hasCoder \"jhowison\" ;  " + 
	// 	// 	"      			  ca:appliesCode " + code + " ;  " + 
	// 	// 	"    			 ] ;  " +
	// 	// 	"  . " + 
	// 	// 	"  ?itemURIC ca:isTargetOf  " + 
	// 	// 	"				[ ca:hasCoder \"cgrady\" ;  " + 
	// 	// 	"			      ca:appliesCode " + code + " ;  " + 
	// 	// 	"			    ] ; " + 
	// 	// 	"  . " + 
	// 	"}";
	// 	
	// 	//System.out.println(queryString1);
	// 	
	// 	
	// 
	// 	Query query1 = QueryFactory.create(queryString1);
	// 	
	// 	// Execute the query and obtain results
	// 	QueryExecution qe1 = QueryExecutionFactory.create(query1, model);
	// 	ResultSet results1 = qe1.execSelect();
	// 	
	// 	// Output query results	
	// 	ResultSetFormatter.out(System.out, results1, query1);
	// 	
	// 	// Important - free up resources used running the query
	// 	qe1.close();

	}
	
	public static double percentAgreement(String code, Model model) {
		return numberOfAgreements(code, model) / numberOfMatches(model);
	}
	
	// Query 1.  How many selections did we agree on?
	// used as list of units eligible for coding with other codes
	public static double numberOfMatches(Model model) {
		String queryString1 = 

		"PREFIX xsd:   <http://www.w3.org/2001/XMLSchema#> " +
		"PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> " +
		"PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> " +
		"PREFIX owl:     <http://www.w3.org/2002/07/owl#> " +

		"PREFIX ca: <http://floss.syr.edu/ontologies/2008/4/contentAnalysis.owl#>" +
		"PREFIX doap: <http://usefulinc.com/ns/doap#>" +

		"PREFIX bioj: <http://james.howison.name/ontologies/bio-journal-sample#>" + 
		"PREFIX citec: <http://james.howison.name/ontologies/software-citation-coding#>" +

		"SELECT ( COUNT(?itemURIJ) as ?count ) " + 
		// "SELECT ?itemURIJ " + 
		" WHERE { " +
		"  ?itemURIJ ca:matches ?itemURIC ." +
		"  ?itemURIJ ca:isTargetOf " + 
			"    			[ ca:hasCoder \"jhowison\" ;  " + 
			"      			  ca:appliesCode citec:in_text_mention ;  " + 
			"    			 ] ;  " +
			"  . " + 
			"  ?itemURIC ca:isTargetOf  " + 
			"				[ ca:hasCoder \"cgrady\" ;  " + 
			"      			  ca:appliesCode citec:in_text_mention ;  " + 
			"			    ] ; " + 
			"  . " + 
		"}";
		
		Query query1 = QueryFactory.create(queryString1);
		
		// Execute the query and obtain results
		QueryExecution qe1 = QueryExecutionFactory.create(query1, model);
		ResultSet results1 = qe1.execSelect();
		// Output query results	
	//	ResultSetFormatter.out(System.out, results1, query1);
		QuerySolution result = results1.next();
		Literal count = result.getLiteral("count");
		
		
		// Important - free up resources used running the query
		qe1.close();
		
		return count.getDouble();
		
	}

	// Something is an agreement if both OR neither coded a match with
	// this code.
	
	// Left it here.  Need to convert query below to one that also counts cases where neight of the coders applied that freaking code.
	public static double numberOfAgreements(String code, Model model) {
			String queryString1 = 

			"PREFIX xsd:   <http://www.w3.org/2001/XMLSchema#> " +
			"PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> " +
			"PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> " +
			"PREFIX owl:     <http://www.w3.org/2002/07/owl#> " +

			"PREFIX ca: <http://floss.syr.edu/ontologies/2008/4/contentAnalysis.owl#>" +
			"PREFIX doap: <http://usefulinc.com/ns/doap#>" +

			"PREFIX bioj: <http://james.howison.name/ontologies/bio-journal-sample#>" + 
			"PREFIX citec: <http://james.howison.name/ontologies/software-citation-coding#>" +

			"SELECT ( COUNT(?itemURIJ) as ?count ) " + 
			// "SELECT ?itemURIJ " + 
			" WHERE { " +
			"  ?itemURIJ ca:matches ?itemURIC ." +
			"  ?itemURIJ ca:isTargetOf " + 
				"    			[ ca:hasCoder \"jhowison\" ;  " + 
				"      			  ca:appliesCode " + code + " ;  " + 
				"    			 ] ;  " +
				"  . " + 
				"  ?itemURIC ca:isTargetOf  " + 
				"				[ ca:hasCoder \"cgrady\" ;  " + 
				"      			  ca:appliesCode " + code + " ;  " + 
				"			    ] ; " + 
				"  . " + 
			"}";

			Query query1 = QueryFactory.create(queryString1);

			// Execute the query and obtain results
			QueryExecution qe1 = QueryExecutionFactory.create(query1, model);
			ResultSet results1 = qe1.execSelect();
			// Output query results	
			//	ResultSetFormatter.out(System.out, results1, query1);
			QuerySolution result = results1.next();
			Literal count = result.getLiteral("count");
		
			// Important - free up resources used running the query
			qe1.close();
		
			return count.getDouble();
	}
}
