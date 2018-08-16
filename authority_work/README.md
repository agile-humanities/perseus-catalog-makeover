# Overview
This directory contains tools and files for converting [Alison's
Google
Spreadsheet](https://docs.google.com/spreadsheets/d/1RHN6KBulDGbpKATLU6PtwU4o5xVsaBB6xbQRtKjMyWE/edit#gid=0)
into MADS and RDF.

# How to use the tools
This is a quick-and-dirty method that assumes you have Oxygen 18 or better.

## Convert the Google Sheets to XML
  * Download Authors-Abbreviations-Editions as an Excel xlsx file.
  * Use Excel to convert from xlsx to xls format (Oxygen 18 cannot import xlsx out of the box)
  * Use Oxygen to import the MS Excel file
      * Import the Latin Authors and the Greek Authors sheets
      * Save them as, for example, LatinAuthors.xml and GreekAuthors.xml

## Use XQuery to generate the MADS records
Use GreekAAE.xq to convert the Greek sheet and LatinAAE.xq to convert the Latin sheet.
  * Open both source XML file and XQ files
  * Configure a transformation scenario
  * Apply the transformation
