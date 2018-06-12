The Perseus Catalog (http://catalog.perseus.org) has been in continuous development over the last 13 years. The very first experimental catalog was designed in 2005 (http://www.dlib.org/dlib/october05/crane/10crane.html) as a “FRBRized” attempt to provide access to the Perseus Digital Library online Greek and Latin collections. 
The major data model behind the catalog design since its inception has been the  International Federation of Library Associations and Institutions FRBR model, or Functional Requirements for Bibliographic Records (https://www.ifla.org/publications/functional-requirements-for-bibliographic-records). 

All data created for the Perseus Catalog has made use of the MODS and MADS metadata standards from the Library of Congress. The other major data standard in use is Canonical Text Services (CTS) Protocol (http://cite-architecture.github.io/cts_spec/), a network service to identify and retrieve text fragments using canonical references expressed by CTS-URNs, and the related CITE Architecture (http://cite-architecture.github.io/cts/).  

Active data creation and infrastructure design has continued iteratively since 2005, with the intended goal of providing catalog access to at least one version of every surviving major Greek and Latin author from antiquity to about 600 CE.  A fuller history and purpose of the Perseus Catalog can be found both at the documentation website (http://sites.tufts.edu/perseuscatalog/documentation/history-and-purpose/) and in a recent presentation given at Mashcat 2016 (http://www.mashcat.info/wp-content/uploads/2016/01/Alison-Babeu-Building-and-Rebuilding-the-Perseus-Catalog.pptx)

The current implementation went online in 2013 and makes use of Blacklight.  Previous experimental implementations had made use of eXistdb (2005) and the eXtensible Catalog (2011-2013). This new design iteration will more heavily focus on converting the Perseus Catalog data to linked data and focus on interface development at a later stage. 

The Perseus Catalog now serves two purposes:

  * It provides readers with an easy way to find editions of classical texts on the Internet;
  * It acts as a bibliographic knowledge base for applications.

In this project we endeavor to do three things:

  * Correct, simplify, and unify bibliographic records;
  * Create a simple web application to support basic searching and browsing;
  * Create a FRBRoo-based knowledge base.
  
In a second phase we plan to develop an API to the knowledge base.
