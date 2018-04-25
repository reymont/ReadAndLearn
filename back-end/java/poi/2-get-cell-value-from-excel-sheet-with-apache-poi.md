java - Get Cell Value from Excel Sheet with Apache Poi - Stack Overflow https://stackoverflow.com/questions/5578535/get-cell-value-from-excel-sheet-with-apache-poi


You have to use the FormulaEvaluator, as shown here. This will return a value that is either the value present in the cell or the result of the formula if the cell contains such a formula :

FileInputStream fis = new FileInputStream("/somepath/test.xls");
Workbook wb = new HSSFWorkbook(fis); //or new XSSFWorkbook("/somepath/test.xls")
Sheet sheet = wb.getSheetAt(0);
FormulaEvaluator evaluator = wb.getCreationHelper().createFormulaEvaluator();

// suppose your formula is in B3
CellReference cellReference = new CellReference("B3"); 
Row row = sheet.getRow(cellReference.getRow());
Cell cell = row.getCell(cellReference.getCol()); 

if (cell!=null) {
    switch (evaluator.evaluateFormulaCell(cell)) {
        case Cell.CELL_TYPE_BOOLEAN:
            System.out.println(cell.getBooleanCellValue());
            break;
        case Cell.CELL_TYPE_NUMERIC:
            System.out.println(cell.getNumericCellValue());
            break;
        case Cell.CELL_TYPE_STRING:
            System.out.println(cell.getStringCellValue());
            break;
        case Cell.CELL_TYPE_BLANK:
            break;
        case Cell.CELL_TYPE_ERROR:
            System.out.println(cell.getErrorCellValue());
            break;

        // CELL_TYPE_FORMULA will never occur
        case Cell.CELL_TYPE_FORMULA: 
            break;
    }
}
if you need the exact contant (ie the formla if the cell contains a formula), then this is shown here.

Edit : Added a few example to help you.

first you get the cell (just an example)

Row row = sheet.getRow(rowIndex+2);    
Cell cell = row.getCell(1);   
If you just want to set the value into the cell using the formula (without knowing the result) :

 String formula ="ABS((1-E"+(rowIndex + 2)+"/D"+(rowIndex + 2)+")*100)";    
 cell.setCellFormula(formula);    
 cell.setCellStyle(this.valueRightAlignStyleLightBlueBackground);
if you want to change the message if there is an error in the cell, you have to change the formula to do so, something like

IF(ISERR(ABS((1-E3/D3)*100));"N/A"; ABS((1-E3/D3)*100))
(this formula check if the evaluation return an error and then display the string "N/A", or the evaluation if this is not an error).

if you want to get the value corresponding to the formula, then you have to use the evaluator.

Hope this help,
Guillaume