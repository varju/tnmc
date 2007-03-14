package tnmc.sql;

import java.sql.*;

public abstract class GeneralConfig
{
    public static String get(String in_key)
    {
        String retVal = null;
        
        try
        {   
            ResultSet rs = SQL.query("SELECT value FROM GeneralConfig WHERE name='" + in_key + "'");
            retVal = rs.getString("value");
        }   catch (SQLException sql_e)
        {   sql_e.printStackTrace();
        }
        
        return retVal;
    }
}
