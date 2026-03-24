---
title: 'rspacer: an RSpace API wrapper to facilitate reproducible research data management in R'
tags:
 - R
 - Electronic Lab Notebook (ELN)
 - reproducible research
 - computational workflows
 - Research Data Management (RDM)
 - FAIR data
authors:
  - name: 
      given-names: Hanneke
      surname: Leegwater
    orcid: 0000-0001-6003-1544
    affiliation: 1
  - name: 
      given-names: Sylvia E.
      surname: Le Dévédec
    orcid: 0000-0002-0615-9616
    affiliation: 1
  - name: 
      given-names: Gerhard A.
      surname: Burger
    orcid: 0000-0003-1062-5576
    affiliation: 1

affiliations:
 - name: Leiden Academic Centre for Drug Research, Leiden University, The Netherlands
   index: 1
   ror: 027bh9e22

date: 19 March 2026
bibliography: paper.bib

---

# Summary
With research becoming more data-intensive and with increasing requirements for FAIR and open data, there is a great need for robust data management strategies. 
Electronic lab notebooks (ELNs) play an increasing role in such strategies, but researcher adoption can lag behind when ELNs cannot be  integrated seamlessly into daily workflows. 
Here we present *rspacer*, an R package that facilitates uploading data, metadata, and notes to the RSpace ELN through its REST API. 
We demonstrate applications for reusing metadata stored in the RSpace ELN, uploading Quarto reports as lab journal entries, and for converting tabular file formats into RSpace documents. 
Together, these features streamline computational workflows and support more consistent and reliable data entry, thereby facilitating  ELN adoption and leading to improved research data management.

# Statement of need
Electronic Lab Notebooks (ELNs) are increasingly used to support research data management (RDM) and to meet increased institutional and funder requirements for FAIR [@Wilkinson2016FAIR] and open data [@Perrier2017]. 
However, ELN adoption by researchers can lag behind expectations, commonly due to usability issues and poor integration into existing analysis workflows [@Kanza2017].
RSpace provides a REST API (<https://community.researchspace.com/public/apiDocs>) to interact with RSpace programmatically, but using the API directly can be cumbersome, especially for researchers without extensive programming experience. 
Although a Python API wrapper has been developed by the RSpace team (<https://pypi.org/project/rspace-client/>), many life science researchers rely primarily on R for data analysis and visualization.
*rspacer* addresses this gap by providing an R package that wraps a subset of the RSpace API, providing functions for common tasks such as browsing folder structures, retrieving RSpace documents, and downloading and uploading file attachments. 
In addition, *rspacer* includes convenience functions to convert workflow outputs, such as HTML Quarto reports or  tabular CSV/TSV/XLSX file, into structured RSpace documents. 
These features allow researchers to more naturally integrate the RSpace ELN into R-based computational workflows including, for example, R shiny [@shiny].

# State of the field
There are many field-specific or general ELNs and data standards. Many scientific communities have agreed on, or are working towards reporting standards and frameworks for research output. These standards include guidelines for metadata on sample collection, storage conditions, and measurement details [@Athar2018;@Barrett2012;@Deutsch2023;@Kopczynski2024;@PerezRiverol2024;@wwPDB2019;@Yurekten2024] supported by domain-specific repositories. For less defined data types, flexible alternatives such as Zenodo and BioStudies allow sharing with fewer requirements [@OpenAIRE2013;@Sarkans2017]. Omics metadata often follows an Investigation-Study-Assay structure[@RoccaSerra2010], with technology-specific extensions such as metabolite evidence tables [@Yurekten2024] or hybridization probe sequences [@Athar2018]. Clinical metadata often uses Fast Healthcare Interoperability Resources [@hl7_fhir_homepage]. During data upload, repositories may incorporate metadata validation protocols [@wwPDB2019;@Yurekten2024], or require separate formats for metadata [@Courtot2022], often relying on controlled vocabularies and ontologies.

Meeting these requirements requires meticulous data annotation before, during, and after data collection. A significant advance in this area has been the introduction of ELNs to replace handwritten notes with digital versions [@Lamprecht2021;@Machina2013]. ELNs range from basic online notebooks that track changes, such as OneNote or Evernote, to advanced platforms with additional functionalities, such as structured folder hierarchies, interlinked assays, templates, controlled vocabularies or integration with a laboratory information management system (LIMS) for sample storage location or compound safety information [@Higgins2022;@Kanza2017;@Kwok2018]. Integration of ELNs into data acquisition workflows also facilitate automated collection of essential metadata, such as microscope or sequencer settings [@Schmied2023], data storage location, software versions, and data processing steps. Specifically for the ELN RSpace, the focus of our software, a python API wrapper already exists (https://github.com/rspace-os/rspace-client-python), but an R version was missing, which is why we developed this.

# Software design
*rspacer* is an R package and uses the httr2 package [@Kbjiwfet/lX7U9jLx] to wrap a subset of the RSpace API documented at <https://community.researchspace.com/public/apiDocs>. 
Its main functionality is divided into three categories, roughly corresponding to different API endpoints: browsing/searching the RSpace file and folder structure, interacting with RSpace documents, and interacting with [RSpace Gallery](https://web.archive.org/web/20250701084519/https://documentation.researchspace.com/article/sl6mo1i9do-the-gallery) files, used, for example, to add attachments to RSpace documents (\autoref{fig:functionality}A).

This allows users to locate their own data and data shared with them (\autoref{fig:functionality}B), and reuse these in their workflow (\autoref{fig:functionality}C). 
Resulting workflow reports (HTML) or tabular data files (CSV/TSV/XLSX) can then be uploaded as structured RSpace documents (\autoref{fig:functionality}D) following pre-established RSpace templates.

![Functionality of the *rspacer* package. (A) Functions in the *rspacer* package include interactions with folders, documents and files through the RSpace API. (B) A user can retrieve information on folder structures using the *rspacer* browse and find functionality. (C) An example workflow where *rspacer* can be used to retrieve metadata from the RSpace ELN into R. (D) Screenshots of an example workflow where *rspacer* uses Quarto HTML reports or tabular assay data (CSV/TSV/XLSX) as input to create new assays in RSpace.\label{fig:functionality}](./figures/rspacer_functionality.svg){width="100%"}

A more detailed overview of *rspacer*’s functionality and potential applications is provided in a longer companion article available at <https://lacdr.github.io/rspacer-manuscript/> and the package documentation (including tutorials) linked below.

# Code availability
We have provided *rspacer* as an R package, available on CRAN at <https://CRAN.R-project.org/package=rspacer> [@2840].
The source code is maintained openly on GitHub at <https://github.com/LACDR/rspacer>, and tutorials and reference documentation are available at <https://lacdr.github.io/rspacer/>.

Example ISA (Investigation-Study-Assay [@Kbjiwfet/gt8fS2Fr])-inspired Quarto templates (used in our institute) are available in a
separate R package available at <https://github.com/LACDR/LACDR.ISA>.

# Research impact statement
The *rspacer* package is used internally at the Leiden Academic Centre of Drug Research (LACDR) and we have developed workshop materials available at https://github.com/LACDR/rspacer-workshop. In addition, 3 scientists (not part of the co-authors/LACDR) are watching the package on GitHub, of which 1 reported a bug using GitHub issues. Lab journals are usually not posted publicly, but we have included a proof-of-concept of the use of LACDR.ISA in one of our recent manuscript code repositories [@Leegwater2026].

# AI usage disclosure
Generative AI was not used directly for software development of the functions in this R package, but we did use chatGPT for assisting in developing tests, especially to convert JSON objects to R lists and back to JSON. We have also read multiple Stack Overflow posts during debugging ([https://stackoverflow.com](https://stackoverflow.com)), and have extensively used user manuals from our R dependencies. All AI-generated code was proofread, run, and double-checked by the authors. We have used the Microsoft Word spellingchecker, chatGPT, and a native English-speaking human (Jacob) for proofreading the article vignettes, tutorials, and this manuscript, based on text that we wrote ourselves.

# References
