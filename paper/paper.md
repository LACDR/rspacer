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

date: 18 November 2025
bibliography: paper.bib

---

# Summary

With research becoming more data-intensive and with increasing requirements for FAIR and open data, there is a great need for robust data management strategies. 
Electronic lab notebooks (ELNs) play an increasing role in such strategies, but researcher adoption can lag behind when ELNs cannot be  integrated seamlessly into daily workflows. 
Here we present *rspacer*, an R package that facilitates uploading data, metadata, and notes to the RSpace ELN through its REST API. 
We demonstrate applications for reusing metadata stored in the RSpace ELN, uploading Quarto reports as lab journal entries, and for converting tabular file formats into RSpace documents. 
Together, these features streamline computational workflows and support more consistent and reliable data entry, thereby facilitating  ELN adoption and leading to improved research data management.

# Statement of need

Electronic Lab Notebooks (ELNs) are increasingly used to support research data management (RDM) and to meet increased institutional and funder requirements for FAIR [@Kbjiwfet/582m1iNq] and open data [@2861]. 
However, ELN adoption by researchers can lag behind expectations, commonly due to usability issues and poor integration into existing analysis workflows [@Kbjiwfet/94CwkKGK].
RSpace provides a REST API (<https://community.researchspace.com/public/apiDocs>) to interact with RSpace programmatically, but using the API directly can be cumbersome, especially for researchers without extensive programming experience. 
Although a Python API wrapper has been developed by the RSpace team (<https://pypi.org/project/rspace-client/>), many life science researchers rely primarily on R for data analysis and visualization.
*rspacer* addresses this gap by providing an R package that wraps a subset of the RSpace API, providing functions for common tasks such as browsing folder structures, retrieving RSpace documents, and downloading and uploading file attachments. 
In addition, *rspacer* includes convenience functions to convert workflow outputs, such as HTML Quarto reports or  tabular CSV/TSV/XLSX file, into structured RSpace documents. 
These features allow researchers to more naturally integrate the RSpace ELN into R-based computational workflows including, for example, R shiny [@shiny].

# Implementation

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

# References
