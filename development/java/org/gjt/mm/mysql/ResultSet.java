/*
 * MM JDBC Drivers for MySQL
 *
 * $Id: ResultSet.java,v 1.2 1998/08/25 00:53:48 mmatthew Exp $
 *
 * Copyright (C) 1998 Mark Matthews <mmatthew@worldserver.com>
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 * 
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA  02111-1307, USA.
 *
 * See the COPYING file located in the top-level-directory of
 * the archive of this library for complete text of license.
 *
 * Some portions:
 *
 * Copyright (c) 1996 Bradley McLean / Jeffrey Medeiros
 * Modifications Copyright (c) 1996/1997 Martin Rode
 * Copyright (c) 1997 Peter T Mount
 */

/**
 * A ResultSet provides access to a table of data generated by executing a
 * Statement.  The table rows are retrieved in sequence.  Within a row its
 * column values can be accessed in any order.
 *
 * <P>A ResultSet maintains a cursor pointing to its current row of data.
 * Initially the cursor is positioned before the first row.  The 'next'
 * method moves the cursor to the next row.
 *
 * <P>The getXXX methods retrieve column values for the current row.  You can
 * retrieve values either using the index number of the column, or by using
 * the name of the column.  In general using the column index will be more
 * efficient.  Columns are numbered from 1.
 *
 * <P>For maximum portability, ResultSet columns within each row should be read
 * in left-to-right order and each column should be read only once.
 *
 *<P> For the getXXX methods, the JDBC driver attempts to convert the
 * underlying data to the specified Java type and returns a suitable Java
 * value.  See the JDBC specification for allowable mappings from SQL types
 * to Java types with the ResultSet getXXX methods.
 *
 * <P>Column names used as input to getXXX methods are case insenstive.  When
 * performing a getXXX using a column name, if several columns have the same
 * name, then the value of the first matching column will be returned.  The
 * column name option is designed to be used when column names are used in the
 * SQL Query.  For columns that are NOT explicitly named in the query, it is
 * best to use column numbers.  If column names were used there is no way for
 * the programmer to guarentee that they actually refer to the intended
 * columns.
 *
 * <P>A ResultSet is automatically closed by the Statement that generated it
 * when that Statement is closed, re-executed, or is used to retrieve the
 * next result from a sequence of multiple results.
 *
 * <P>The number, types and properties of a ResultSet's columns are provided by
 * the ResultSetMetaData object returned by the getMetaData method.
 *
 * @see ResultSetMetaData
 * @see java.sql.ResultSet
 * @author Mark Matthews <mmatthew@worldserver.com>
 * @version $Id$
 */

package org.gjt.mm.mysql;

import java.io.*;
import java.math.*;
import java.text.*;
import java.util.*;
import java.sql.*;

public class ResultSet implements java.sql.ResultSet
{
    Vector Rows;                  // The results
    Field[] Fields;               // The fields

    int currentRow = -1;          // Cursor to current row;
    byte[][] This_Row;              // Values for current row
    org.gjt.mm.mysql.Connection Conn; // The connection that created us
    java.sql.SQLWarning Warnings = null;   // The warning chain
    boolean wasNullFlag = false;  // for wasNull()
    boolean reallyResult = false; // for executeUpdate vs. execute

    // These are longs for 
    // recent versions of the MySQL server.
    //
    // They get reduced to ints via the JDBC API,
    // but can be retrieved through a MySQLStatement
    // in their entirety.
    //

    long updateID = -1;           // for AUTO_INCREMENT
    long updateCount;             // How many rows did we update? 
    
    // For getTimestamp()

    private static SimpleDateFormat _TSDF = 
	new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    /**
     * A ResultSet is initially positioned before its first row,
     * the first call to next makes the first row the current row;
     * the second call makes the second row the current row, etc.
     *
     * <p>If an input stream from the previous row is open, it is
     * implicitly closed.  The ResultSet's warning chain is cleared
     * when a new row is read
     *
     * @return true if the new current is valid; false if there are no
     *    more rows
     * @exception java.sql.SQLException if a database access error occurs
     */

    public boolean next() throws java.sql.SQLException
    { 
    
	if (!reallyResult())
	    throw new java.sql.SQLException("ResultSet is from UPDATE. No Data", "S1000");
              
	if (currentRow + 1 >= Rows.size()) {
	    return false;
	}
	else {
	    clearWarnings();
	    currentRow = currentRow + 1;
	    This_Row = (byte[][])Rows.elementAt(currentRow);
	    return true;
	}
    }

    /**
     * The prev method is not part of JDBC, but because of the
     * architecture of this driver it is possible to move both
     * forward and backward within the result set.
     *
     * <p>If an input stream from the previous row is open, it is
     * implicitly closed.  The ResultSet's warning chain is cleared
     * when a new row is read
     *
     * @return true if the new current is valid; false if there are no
     *    more rows
     * @exception java.sql.SQLException if a database access error occurs
     */

    public boolean prev() throws java.sql.SQLException
    {
	if (currentRow - 1 >= 0) {
	    currentRow--;
	    This_Row = (byte[][])Rows.elementAt(currentRow);
	    return true;
	}
	else {
	    return false;
	}
    }

    /**
     * In some cases, it is desirable to immediately release a ResultSet
     * database and JDBC resources instead of waiting for this to happen
     * when it is automatically closed.  The close method provides this
     * immediate release.
     *
     * <p><B>Note:</B> A ResultSet is automatically closed by the Statement
     * the Statement that generated it when that Statement is closed,
     * re-executed, or is used to retrieve the next result from a sequence
     * of multiple results.  A ResultSet is also automatically closed
     * when it is garbage collected.
     *
     * @exception java.sql.SQLException if a database access error occurs
     */

    public void close() throws java.sql.SQLException
    {
	if (Rows != null) {
	    Rows.removeAllElements();
	}
    }

    /**
     * A column may have the value of SQL NULL; wasNull() reports whether
     * the last column read had this special value.  Note that you must
     * first call getXXX on a column to try to read its value and then
     * call wasNull() to find if the value was SQL NULL
     *
     * @return true if the last column read was SQL NULL
     * @exception java.sql.SQLException if a database access error occurred
     */

    public boolean wasNull() throws java.sql.SQLException
    {
	return wasNullFlag;
    }
  
    /**
     * Get the value of a column in the current row as a Java String
     *
     * @param columnIndex the first column is 1, the second is 2...
     * @return the column value, null for SQL NULL
     * @exception java.sql.SQLException if a database access error occurs
     */
  
    public String getString(int columnIndex) throws java.sql.SQLException
    {
        if (Fields == null) {
		throw new java.sql.SQLException("Query generated no fields for ResultSet", "S1002");
	}

	if (columnIndex < 1 || columnIndex > Fields.length)
	    throw new java.sql.SQLException("Column Index out of range ( " + columnIndex + " > " + Fields.length + ").", "S1002");

	try {
	    if (This_Row[columnIndex - 1] == null) {
		wasNullFlag = true;
	    }
	    else {
		wasNullFlag = false;
	    }
	}
	catch (NullPointerException E) {
	    wasNullFlag = true;
	}
  
	if(wasNullFlag)
	    return null;
	
	if (Conn != null && Conn.useUnicode()) {
	    try {
		String Encoding = Conn.getEncoding();

		if (Encoding == null) {
		    return new String(This_Row[columnIndex - 1]);
		}
		else {
		    return new String(This_Row[columnIndex - 1], Conn.getEncoding());
		}
	    }
	    catch (java.io.UnsupportedEncodingException E) {
		throw new SQLException("Unsupported character encoding '" + 
                                       Conn.getEncoding() + "'.", "0S100"); 
	    }
	}
	else {
	    return new String(This_Row[columnIndex - 1]);
	}
    }
  
    /**
     * Get the value of a column in the current row as a Java boolean
     *
     * @param columnIndex the first column is 1, the second is 2...
     * @return the column value, false for SQL NULL
     * @exception java.sql.SQLException if a database access error occurs
     */

    public boolean getBoolean(int columnIndex) throws java.sql.SQLException
    {
	String S = getString(columnIndex);

	if (S != null && S.length() > 0) {
	    int c = S.toLowerCase().charAt(0);
	    return ((c == 't') || (c == 'y') || (c == '1'));
	}
	return false;               // SQL NULL
    }

    /**
     * Get the value of a column in the current row as a Java byte.
     *
     * @param columnIndex the first column is 1, the second is 2,...
     * @return the column value; 0 if SQL NULL
     * @exception java.sql.SQLException if a database access error occurs
     */

    public byte getByte(int columnIndex) throws java.sql.SQLException
    {
	if (columnIndex < 1 || columnIndex > Fields.length)
	    throw new java.sql.SQLException("Column Index out of range ( " + columnIndex + " > " + Fields.length + ").", "S1002");

	try {
	    if (This_Row[columnIndex - 1] == null) {
		wasNullFlag = true;
	    }
	    else {
		wasNullFlag = false;
	    }
	}
	catch (NullPointerException E) {
	    wasNullFlag = true;
	}
  
	if(wasNullFlag) {
	    return 0;
	}

	Field F = Fields[columnIndex - 1];

	switch (F.getMysqlType()) {
	case MysqlDefs.FIELD_TYPE_DECIMAL:
	case MysqlDefs.FIELD_TYPE_TINY:
	case MysqlDefs.FIELD_TYPE_SHORT:
	case MysqlDefs.FIELD_TYPE_LONG:
	case MysqlDefs.FIELD_TYPE_FLOAT:
	case MysqlDefs.FIELD_TYPE_DOUBLE:
	case MysqlDefs.FIELD_TYPE_LONGLONG:
	case MysqlDefs.FIELD_TYPE_INT24:
	    try {
		String S = getString(columnIndex);

				// Strip off the decimals
		if (S.indexOf(".") != -1) {
		    S = S.substring(0, S.indexOf("."));
		}
		return Byte.parseByte(S);
	    }
	    catch (NumberFormatException NFE) {
		throw new SQLException("Value '" + getString(columnIndex) + "' is out of range [-127,127]", "S1009");
	    }
	default:
	    return This_Row[columnIndex - 1][0];
	}
    }

    /**
     * Get the value of a column in the current row as a Java short.
     *
     * @param columnIndex the first column is 1, the second is 2,...
     * @return the column value; 0 if SQL NULL
     * @exception java.sql.SQLException if a database access error occurs
     */

    public short getShort(int columnIndex) throws java.sql.SQLException
    {
	String S = getString(columnIndex);

	if (S != null) {
	    if (S.length() == 0) {
		return 0;
	    }
	    try {
		return Short.parseShort(S);
	    } 
	    catch (NumberFormatException E) {
		throw new java.sql.SQLException("Bad format for short '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
	    }
	}
	return 0;           // SQL NULL
    }

    /**
     * Get the value of a column in the current row as a Java int.
     *
     * @param columnIndex the first column is 1, the second is 2,...
     * @return the column value; 0 if SQL NULL
     * @exception java.sql.SQLException if a database access error occurs
     */

    public int getInt(int columnIndex) throws java.sql.SQLException
    {
	String S = getString(columnIndex);

	if (S != null) {
	    if (S.length() == 0) {
		return 0;
	    }
	    try {
		return Integer.parseInt(S);
	    } 
	    catch (NumberFormatException E) {
		throw new java.sql.SQLException ("Bad format for integer '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
	    }
	}
	return 0;           // SQL NULL
    }
  
    /**
     * Get the value of a column in the current row as a Java long.
     *
     * @param columnIndex the first column is 1, the second is 2,...
     * @return the column value; 0 if SQL NULL
     * @exception java.sql.SQLException if a database access error occurs
     */

    public long getLong(int columnIndex) throws java.sql.SQLException
    {
	String S = getString(columnIndex);

	if (S != null) {
	    if (S.length() == 0) {
		return 0;
	    }
	    try {
		return Long.parseLong(S);
	    } 
	    catch (NumberFormatException E) {
		throw new java.sql.SQLException ("Bad format for long '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
	    }
	}
	return 0;           // SQL NULL
    }
  
    /**
     * Get the value of a column in the current row as a Java float.
     *
     * @param columnIndex the first column is 1, the second is 2,...
     * @return the column value; 0 if SQL NULL
     * @exception java.sql.SQLException if a database access error occurs
     */

    public float getFloat(int columnIndex) throws java.sql.SQLException
    {
	String S = getString(columnIndex);

	if (S != null) {
	    if (S.length() == 0) {
		return 0;
	    }
	    try {
		return Float.valueOf(S).floatValue();
	    } 
	    catch (NumberFormatException E) {
		throw new java.sql.SQLException ("Bad format for float '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
	    }
	}
	return 0;           // SQL NULL
    }
  
    /**
     * Get the value of a column in the current row as a Java double.
     *
     * @param columnIndex the first column is 1, the second is 2,...
     * @return the column value; 0 if SQL NULL
     * @exception java.sql.SQLException if a database access error occurs
     */

    public double getDouble(int columnIndex) throws java.sql.SQLException
    {
	String S = getString(columnIndex);

	if (S != null) {
	    if (S.length() == 0) {
		return 0;
	    }
	    try {
		return Double.valueOf(S).doubleValue();
	    } 
	    catch (NumberFormatException E) {
		throw new java.sql.SQLException ("Bad format for double '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
	    }
	}
	return 0;           // SQL NULL
    }

    /**
     * Get the value of a column in the current row as a
     * java.lang.BigDecimal object
     *
     * @param columnIndex  the first column is 1, the second is 2...
     * @param scale the number of digits to the right of the decimal
     * @return the column value; if the value is SQL NULL, null
     * @exception java.sql.SQLException if a database access error occurs
     */

    public BigDecimal getBigDecimal(int columnIndex, int scale) 
	throws java.sql.SQLException
    {
	String S = getString(columnIndex);
	BigDecimal Val;

	if (S != null) {
	    if (S.length() == 0) {
		Val = new BigDecimal(0);
		return Val.setScale(scale);
	    }
	    try {
		Val = new BigDecimal(S);
	    } 
	    catch (NumberFormatException E) {
		throw new java.sql.SQLException ("Bad format for BigDecimal '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
	    }
	    try {
		return Val.setScale(scale);
	    } 
	    catch (ArithmeticException E) {
		throw new java.sql.SQLException ("Bad format for BigDecimal '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
	    }
	}
	return null;                // SQL NULL
    }

    /**
     * Get the value of a column in the current row as a Java byte array.
     *
     * <p><b>Be warned</b> If the blob is huge, then you may run out
     * of memory.
     *
     * @param columnIndex the first column is 1, the second is 2, ...
     * @return the column value; if the value is SQL NULL, the result
     *    is null
     * @exception java.sql.SQLException if a database access error occurs
     */

    public byte[] getBytes(int columnIndex) throws java.sql.SQLException
    {
	if (columnIndex < 1 || columnIndex > Fields.length)
	    throw new java.sql.SQLException("Column Index out of range ( " + columnIndex + " > " + Fields.length + ").", "S1002");

	try {
	    if (This_Row[columnIndex - 1] == null) {
		wasNullFlag = true;
	    }
	    else {
		wasNullFlag = false;
	    }
	}
	catch (NullPointerException E) {
	    wasNullFlag = true;
	}
  
	if(wasNullFlag) {
	    return null;
	}
	else {
	    return This_Row[columnIndex - 1];
	}
    }
    
    /**
     * Get the value of a column in the current row as a java.sql.Date
     * object
     *
     * @param columnIndex the first column is 1, the second is 2...
     * @return the column value; null if SQL NULL
     * @exception java.sql.SQLException if a database access error occurs
     */
  
    public java.sql.Date getDate(int columnIndex) throws java.sql.SQLException
    {
	Integer Y = null, M = null, D = null;
	String S = "";
	
   	try {
	    S = getString(columnIndex);
	    
	    if (S == null) {
		return null;
	    }
	    else if (Fields[columnIndex - 1].getMysqlType() == MysqlDefs.FIELD_TYPE_TIMESTAMP) {
				// Convert from TIMESTAMP
		switch (S.length()) {
		case 14: 
		case 8:
		    {
			Y =  new Integer(S.substring(0,4));
			M =  new Integer(S.substring(4,6));
			D =  new Integer(S.substring(6,8));
			return new java.sql.Date(Y.intValue()-1900, M.intValue()-1,D.intValue());
		    }
		case 12: 
		case 10: 
		case 6:
		    {
			Y  = new Integer(S.substring(0,2));
			M  = new Integer(S.substring(2,4));
			D  = new Integer(S.substring(4,6));
			return new java.sql.Date(Y.intValue(), M.intValue()-1,D.intValue());
		    }
		case 4:
		    {
			Y  = new Integer(S.substring(0,2));
			M  = new Integer(S.substring(2,4));
			return new java.sql.Date(Y.intValue(), M.intValue()-1, 1);
		    }
		case 2:
		    {
			Y  = new Integer(S.substring(0,2));
			return new java.sql.Date(Y.intValue(), 0, 1);
		    }
		default:
		    throw new SQLException("Bad format for Date '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
		} /* endswitch */
	    }
	    else {
		if( S.length() < 10) {
		    throw new SQLException("Bad format for Date '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
		}
		
		Y = new Integer(S.substring(0,4));
		M = new Integer(S.substring(5,7));
		D = new Integer(S.substring(8,10));
	    }

	    return new java.sql.Date(Y.intValue()-1900, M.intValue()-1,D.intValue());
	}
	catch( Exception e ) {
	    throw new java.sql.SQLException("Cannot convert value '" + S + "' from column " + columnIndex + "(" + Fields[columnIndex]+ " ) to DATE.", "S1009");
	}
    }

    /**
     * Get the value of a column in the current row as a java.sql.Time
     * object
     *
     * @param columnIndex the first column is 1, the second is 2...
     * @return the column value; null if SQL NULL
     * @exception java.sql.SQLException if a database access error occurs
     */
    
    public Time getTime(int columnIndex) throws java.sql.SQLException
    {  
	int hr = 0, min = 0, sec = 0;
	
	try {
	    String S = getString(columnIndex);
	    if (S == null) return null;
	    
	    Field F = Fields[columnIndex - 1];

	    if (F.getMysqlType() == MysqlDefs.FIELD_TYPE_TIMESTAMP) {
				// It's a timestamp
   		int length = S.length();
		switch (length) {
		case 14:
		case 12: {
		    hr  = Integer.parseInt(S.substring(length - 6, length - 4));
		    min = Integer.parseInt(S.substring(length - 4, length - 2));
		    sec = Integer.parseInt(S.substring(length -2, length));
		}
		break;
		case 10: {
		    hr  = Integer.parseInt(S.substring(6, 8));
		    min = Integer.parseInt(S.substring(8,10));
		    sec = 0;
		}
		break;
		default:
		    throw new SQLException("Timestamp too small to convert to Time value in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
		} /* endswitch */
	  
		SQLWarning W = new SQLWarning("Precision lost converting TIMESTAMP to Time with getTime() on column " + columnIndex + "(" + Fields[columnIndex] + ").");

		if (Warnings == null) {
		    Warnings = W;
		}
		else {
		    Warnings.setNextWarning(W);
		}
	    }
	    else if (F.getMysqlType() == MysqlDefs.FIELD_TYPE_DATETIME) {
		
   		hr  = Integer.parseInt(S.substring(11, 13));
   		min = Integer.parseInt(S.substring(14, 16));
   		sec = Integer.parseInt(S.substring(17, 19)); 

   		SQLWarning W = new SQLWarning("Precision lost converting DATETIME to Time with getTime() on column " + columnIndex + "(" + Fields[columnIndex] + ").");
		
   		if (Warnings == null) {
		    Warnings = W;
		}
   		else {
		    Warnings.setNextWarning(W);
   		}
	    }
	    else {
				// convert a String to a Time
		
   		if (S.length() != 5 && S.length() != 8) {
		    throw new SQLException("Bad format for Time '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
   		}

   		hr  = Integer.parseInt(S.substring(0,2));
   		min = Integer.parseInt(S.substring(3,5));
   		sec = (S.length() == 5) ? 0 : Integer.parseInt(S.substring(6));
	    }
	    return new Time(hr, min, sec);
	}
	catch( Exception E ) {
	    throw new java.sql.SQLException(E.getClass().getName(), "S1009");
	}
    }



    /**
     * Get the value of a column in the current row as a
     * java.sql.Timestamp object
     *
     * @param columnIndex the first column is 1, the second is 2...
     * @return the column value; null if SQL NULL
     * @exception java.sql.SQLException if a database access error occurs
     */
    
    public Timestamp getTimestamp(int columnIndex) throws java.sql.SQLException
    {
	String S = getString(columnIndex);
	
	if (S == null) {
	    return null;
	}

	try {
	    switch (S.length()) {
	    case 19:
		{
		    try {
			java.util.Date D = _TSDF.parse(S);
			return new java.sql.Timestamp(D.getTime());
		    }
		    catch (ParseException E) {
			throw new java.sql.SQLException("Bad format for Timestamp '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
		    }
		}
	    case 14:
		{
		    Integer Y =  new Integer(S.substring(0,4));
		    Integer M =  new Integer(S.substring(4,6));
		    Integer D =  new Integer(S.substring(6,8));
		    Integer HR = new Integer(S.substring(8,10));
		    Integer MI = new Integer(S.substring(10,12));
		    Integer SE = new Integer(S.substring(12,14));
		    return new java.sql.Timestamp(Y.intValue()-1900, M.intValue()-1, D.intValue(), HR.intValue(), MI.intValue(), SE.intValue(), 0);
		}
	    case 12:
		{
		    Integer Y  = new Integer(S.substring(0,2));
		    Integer M  = new Integer(S.substring(2,4));
		    Integer D  = new Integer(S.substring(4,6));
		    Integer HR = new Integer(S.substring(6,8));
		    Integer MI = new Integer(S.substring(8,10));
		    Integer SE = new Integer(S.substring(10,12));
		    return new java.sql.Timestamp(Y.intValue(), M.intValue()-1, D.intValue(), HR.intValue(), MI.intValue(), SE.intValue(), 0);
		}
	    case 10:
		{
		    Integer Y  = new Integer(S.substring(0,2));
		    Integer M  = new Integer(S.substring(2,4));
		    Integer D  = new Integer(S.substring(4,6));
		    Integer HR = new Integer(S.substring(6,8));
		    Integer MI = new Integer(S.substring(8,10));
		    return new java.sql.Timestamp(Y.intValue(), M.intValue()-1, D.intValue(), HR.intValue(), MI.intValue(), 0, 0);
		}
	    case 8:
		{
		    Integer Y = new Integer(S.substring(0,4));
		    Integer M = new Integer(S.substring(4,6));
		    Integer D = new Integer(S.substring(6,8));
		    return new java.sql.Timestamp(Y.intValue()-1900, M.intValue()-1, D.intValue(), 0, 0, 0, 0);
		}
	    case 6:
		{
		    Integer Y = new Integer(S.substring(0,2));
		    Integer M = new Integer(S.substring(2,4));
		    Integer D = new Integer(S.substring(4,6));
		    return new java.sql.Timestamp(Y.intValue(), M.intValue()-1, D.intValue(), 0, 0, 0, 0);
		}
	    case 4:
		{
		    Integer Y = new Integer(S.substring(0,2));
		    Integer M = new Integer(S.substring(2,4));
		    return new java.sql.Timestamp(Y.intValue(), M.intValue()-1, 1, 0, 0, 0, 0);
		}
	    case 2:
		{
		    Integer Y = new Integer(S.substring(0,2));
		    return new java.sql.Timestamp(Y.intValue(), 0, 1, 0, 0, 0, 0);
		}
	    default:
		throw new java.sql.SQLException("Bad format for Timestamp '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
	    }
	}
	catch( Exception e ) {
	    throw new java.sql.SQLException(e.getClass().getName(), "S1009");
	}
    }

    /**
     * A column value can be retrieved as a stream of ASCII characters
     * and then read in chunks from the stream.  This method is
     * particulary suitable for retrieving large LONGVARCHAR values.
     * The JDBC driver will do any necessary conversion from the
     * database format into ASCII.
     *
     * <p><B>Note:</B> All the data in the returned stream must be read
     * prior to getting the value of any other column.  The next call
     * to a get method implicitly closes the stream.  Also, a stream
     * may return 0 for available() whether there is data available
     * or not.
     *
     * @param columnIndex the first column is 1, the second is 2, ...
     * @return a Java InputStream that delivers the database column
     *    value as a stream of one byte ASCII characters.  If the
     *    value is SQL NULL then the result is null
     * @exception java.sql.SQLException if a database access error occurs
     * @see getBinaryStream
     */

    public InputStream getAsciiStream(int columnIndex) throws java.sql.SQLException
    {
	return getBinaryStream(columnIndex);
    }

    /**
     * A column value can also be retrieved as a stream of Unicode
     * characters. We implement this as a binary stream.
     *
     * @param columnIndex the first column is 1, the second is 2...
     * @return a Java InputStream that delivers the database column value
     *    as a stream of two byte Unicode characters.  If the value is
     *    SQL NULL, then the result is null
     * @exception java.sql.SQLException if a database access error occurs
     * @see getAsciiStream
     * @see getBinaryStream
     */
  
    public InputStream getUnicodeStream(int columnIndex) throws java.sql.SQLException
    {
	return getBinaryStream(columnIndex);
    }

    /**
     * A column value can also be retrieved as a binary strea.  This
     * method is suitable for retrieving LONGVARBINARY values.
     *
     * @param columnIndex the first column is 1, the second is 2...
     * @return a Java InputStream that delivers the database column value
     * as a stream of bytes.  If the value is SQL NULL, then the result
     * is null
     * @exception java.sql.SQLException if a database access error occurs
     * @see getAsciiStream
     * @see getUnicodeStream
     */

    public InputStream getBinaryStream(int columnIndex) throws java.sql.SQLException
    {
	byte b[] = getBytes(columnIndex);

	if (b != null) {
	    return new ByteArrayInputStream(b);
	}
	return null;                // SQL NULL
    }

    /**
     * The following routines simply convert the columnName into
     * a columnIndex and then call the appropriate routine above.
     *
     * @param columnName is the SQL name of the column
     * @return the column value
     * @exception java.sql.SQLException if a database access error occurs
     */

  
    public String getString(String ColumnName) throws java.sql.SQLException
    {
	return getString(findColumn(ColumnName));
    }
  
    public boolean getBoolean(String ColumnName) throws java.sql.SQLException
    {
	return getBoolean(findColumn(ColumnName));
    }
  
    public byte getByte(String ColumnName) throws java.sql.SQLException
    {
	return getByte(findColumn(ColumnName));
    }

    public short getShort(String ColumnName) throws java.sql.SQLException
    {
	return getShort(findColumn(ColumnName));
    }

    public int getInt(String ColumnName) throws java.sql.SQLException
    {
	return getInt(findColumn(ColumnName));
    }

    public long getLong(String ColumnName) throws java.sql.SQLException
    {
	return getLong(findColumn(ColumnName));
    }
  
    public float getFloat(String ColumnName) throws java.sql.SQLException
    {
	return getFloat(findColumn(ColumnName));
    }

    public double getDouble(String ColumnName) throws java.sql.SQLException
    {
	return getDouble(findColumn(ColumnName));
    }
  
    public BigDecimal getBigDecimal(String ColumnName, int scale) throws java.sql.SQLException
    {
	return getBigDecimal(findColumn(ColumnName), scale);
    }
  
    public byte[] getBytes(String ColumnName) throws java.sql.SQLException
    {
	return getBytes(findColumn(ColumnName));
    }

    public java.sql.Date getDate(String ColumnName) throws java.sql.SQLException
    {
	return getDate(findColumn(ColumnName));
    }
  
    public Time getTime(String ColumnName) throws java.sql.SQLException
    {
	return getTime(findColumn(ColumnName));
    }
  
    public Timestamp getTimestamp(String ColumnName) throws java.sql.SQLException
    {
	return getTimestamp(findColumn(ColumnName));
    }
  
    public InputStream getAsciiStream(String ColumnName) throws java.sql.SQLException
    {
	return getAsciiStream(findColumn(ColumnName));
    }

    public InputStream getUnicodeStream(String ColumnName) throws java.sql.SQLException
    {
	return getUnicodeStream(findColumn(ColumnName));
    }

    public InputStream getBinaryStream(String ColumnName) throws java.sql.SQLException
    {
	return getBinaryStream(findColumn(ColumnName));
    }

    /**
     * The first warning reported by calls on this ResultSet is
     * returned.  Subsequent ResultSet warnings will be chained
     * to this java.sql.SQLWarning.
     *
     * <p>The warning chain is automatically cleared each time a new
     * row is read.
     *
     * <p><B>Note:</B> This warning chain only covers warnings caused by
     * ResultSet methods.  Any warnings caused by statement methods
     * (such as reading OUT parameters) will be chained on the
     * Statement object.
     *
     * @return the first java.sql.SQLWarning or null;
     * @exception java.sql.SQLException if a database access error occurs.
     */

    public java.sql.SQLWarning getWarnings() throws java.sql.SQLException
    {
	return Warnings;
    }
  
    /**
     * After this call, getWarnings returns null until a new warning
     * is reported for this ResultSet
     *
     * @exception java.sql.SQLException if a database access error occurs
     */

    public void clearWarnings() throws java.sql.SQLException
    {
	Warnings = null;
    }

    /**
     * Get the name of the SQL cursor used by this ResultSet
     *
     * <p>In SQL, a result table is retrieved though a cursor that is
     * named.  The current row of a result can be updated or deleted
     * using a positioned update/delete statement that references
     * the cursor name.
     *
     * <p>JDBC supports this SQL feature by providing the name of the
     * SQL cursor used by a ResultSet.  The current row of a ResulSet
     * is also the current row of this SQL cursor.
     *
     * <p><B>Note:</B> If positioned update is not supported, a java.sql.SQLException
     * is thrown.
     *
     * @return the ResultSet's SQL cursor name.
     * @exception java.sql.SQLException if a database access error occurs
     */
  
    public String getCursorName() throws java.sql.SQLException
    {
	throw new java.sql.SQLException("Positioned Update not supported.", "S1C00");
    }

    /**
     * The numbers, types and properties of a ResultSet's columns are
     * provided by the getMetaData method
     *
     * @return a description of the ResultSet's columns
     * @exception java.sql.SQLException if a database access error occurs
     */
  
    public java.sql.ResultSetMetaData getMetaData() throws java.sql.SQLException
    {
	return new ResultSetMetaData(Rows, Fields);
    }

    /**
     * Get the value of a column in the current row as a Java object
     *
     * <p>This method will return the value of the given column as a
     * Java object.  The type of the Java object will be the default
     * Java Object type corresponding to the column's SQL type, following
     * the mapping specified in the JDBC specification.
     *
     * <p>This method may also be used to read database specific abstract
     * data types.
     *
     * @param columnIndex the first column is 1, the second is 2...
     * @return a Object holding the column value
     * @exception java.sql.SQLException if a database access error occurs
     */

    public Object getObject(int columnIndex) throws java.sql.SQLException
    {
	Field F;

	if (columnIndex < 1 || columnIndex > Fields.length) {
	    throw new java.sql.SQLException("Column index out of range (" + columnIndex + " > " + Fields.length + ").", "S1002");
	}
	F = Fields[columnIndex - 1];

	if (This_Row[columnIndex - 1] == null) {
            wasNullFlag = true;
	    return null;
	}
       
        wasNullFlag = false;

	switch (F.getSQLType()) {
	case Types.BIT:
	    return new Boolean(getBoolean(columnIndex));
	case Types.TINYINT:
	case Types.SMALLINT:
	case Types.INTEGER:
	    return new Integer(getInt(columnIndex));
	case Types.BIGINT:
	    return new Long(getLong(columnIndex));
	case Types.DECIMAL:
	case Types.NUMERIC:
	    String S = getString(columnIndex);
	    BigDecimal Val;

	    if (S != null) {
		if (S.length() == 0) {
		    Val = new BigDecimal(0);
				
		    return Val;
		}
		try {
		    Val = new BigDecimal(S);
		} 
		catch (NumberFormatException E) {
		    throw new java.sql.SQLException ("Bad format for BigDecimal '" + S + "' in column " + columnIndex + "(" + Fields[columnIndex] + ").", "S1009");
		}
		return Val;
			    
	    }
	    else {
		return null;
	    }
	case Types.REAL:
	case Types.FLOAT:
	    return new Float(getFloat(columnIndex));
	case Types.DOUBLE:
	    return new Double(getDouble(columnIndex));
	case Types.CHAR:
	case Types.VARCHAR:
	case Types.LONGVARCHAR:
	    if (F.isBinary()) {
		return getBytes(columnIndex);
	    }
	    else {
		return getString(columnIndex);
	    }
	case Types.BINARY:
	case Types.VARBINARY:
	case Types.LONGVARBINARY:
	    return getBytes(columnIndex);
	case Types.DATE:
	    return getDate(columnIndex);
	case Types.TIME:
	    return getTime(columnIndex);
	case Types.TIMESTAMP:
	    return getTimestamp(columnIndex);
	default:
	    throw new java.sql.SQLException("Unkown type", "S1009");
	}
    }

    /**
     * Get the value of a column in the current row as a Java object
     *
     *<p> This method will return the value of the given column as a
     * Java object.  The type of the Java object will be the default
     * Java Object type corresponding to the column's SQL type, following
     * the mapping specified in the JDBC specification.
     *
     * <p>This method may also be used to read database specific abstract
     * data types.
     *
     * @param columnName is the SQL name of the column
     * @return a Object holding the column value
     * @exception java.sql.SQLException if a database access error occurs
     */

    public Object getObject(String ColumnName) throws java.sql.SQLException
    {
	return getObject(findColumn(ColumnName));
    }

    /**
     * Map a ResultSet column name to a ResultSet column index
     *
     * @param columnName the name of the column
     * @return the column index
     * @exception java.sql.SQLException if a database access error occurs
     */

    public int findColumn(String ColumnName) throws java.sql.SQLException
    {
	int i;

	if (Driver.debug) {
	    System.out.println("Looking for " + ColumnName);
	}
	for (i = 0 ; i < Fields.length; ++i) {
	    if (Driver.debug) {
		System.out.println(Fields[i].Name);
	    }
	    if (Fields[i].Name.equalsIgnoreCase(ColumnName)) {
		return (i + 1);
	    }
			
	    String FullName = Fields[i].TableName + "." + Fields[i].Name;
			
	    if (FullName.equalsIgnoreCase(ColumnName)) {
		return (i + 1);
	    }
	}
	throw new java.sql.SQLException ("Column '" + ColumnName + "' not found.", "S0022");
    } 

    // ****************************************************************
    //
    //                       END OF PUBLIC INTERFACE
    //
    // ****************************************************************

    /**
     * Create a new ResultSet - Note that we create ResultSets to
     * represent the results of everything.
     *
     * @param fields an array of Field objects (basically, the
     *    ResultSet MetaData)
     * @param tuples Vector of the actual data
     * @param status the status string returned from the back end
     * @param updateCount the number of rows affected by the operation
     * @param cursor the positioned update/delete cursor name
     */

    ResultSet(Field[] Fields, Vector Tuples, org.gjt.mm.mysql.Connection Conn)
    {
	this(Fields, Tuples);
	setConnection(Conn);
    }
	
    ResultSet(Field[] Fields, Vector Tuples)
    { 
	currentRow = -1;
	this.Fields = Fields;
	Rows = Tuples;
	updateCount = (long)Rows.size();
	if (Driver.debug)
	    System.out.println("Retrieved " + updateCount + " rows");
	reallyResult = true;

	// Check for no results
	if (!(Rows.size() == 0)) {
		  
	    This_Row = (byte[][])Rows.elementAt(0);
    
		  
	    if (updateCount == 1) {
		boolean nulls = true;
		if (This_Row == null) {
		      
		    nulls = true;
		}
		else {
		    for (int i = 0; i < This_Row.length; i++) {
			if (This_Row[i] != null)  {
		          
			    nulls = false;
			    break;
			}
		    }
		}
		if (nulls) {
		    currentRow = Tuples.size() + 1;
		}
	    } 
	}
	else {
	    This_Row = null;
	}
   
    }

    /**
     * Create a result set for an executeUpdate statement.
     *
     * @param updateCount the number of rows affected by the update
     */

    ResultSet(long updateCount, long updateID)
    {
	this.updateCount = updateCount;
	this.updateID = updateID;
	reallyResult = false;
	Fields = new Field[0];
    }

    void setConnection(org.gjt.mm.mysql.Connection Conn)
    {
	this.Conn = Conn;
    }

    boolean reallyResult()
    {
	return reallyResult;
    }

    long getUpdateCount()
    {
	return updateCount;
    }
  
    long getUpdateID()
    {
	return updateID;
    }
}
