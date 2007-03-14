package tnmc.sql;

import java.sql.*;

public abstract class SQL
{
    private static String URL = "jdbc:mysql://steinbok.dhs.org:3306/tnmc";    private static String USER = "remote";    private static String PASS = "tnmc";    
    private static Connection s_conn = null;        static    {
        try         {   Class.forName("org.gjt.mm.mysql.Driver");
        } catch(java.lang.ClassNotFoundException e)         {   System.err.print("ClassNotFoundException: ");
            System.err.println(e.getMessage());            System.exit(0);
        }                if (!connect())            System.exit(-1);
    }        public static boolean connect()
    {        try         {   s_conn = DriverManager.getConnection(URL, USER, PASS);
        } catch(SQLException ex)         {   //System.err.println("SQLException: " + ex.getMessage());            return false;
        }
        return true;
    }
    
    public static ResultSet query(String in_query)
    {
        ResultSet retVal = null;
        
        try
        {   Statement stmt = s_conn.createStatement();
            retVal = stmt.executeQuery(in_query);
        }   catch (SQLException sql_e)
        {   sql_e.printStackTrace();
        }
        
        return retVal;
    }
    
    public static void update(String in_update)
    {
        try
        {   Statement stmt = s_conn.createStatement();
            stmt.executeUpdate(in_update);
        }   catch (SQLException sql_e)
        {   System.out.println(sql_e);
        }
    }
}
