package tnmc.sql;

import java.sql.*;
import java.util.*;

import tnmc.*;

public abstract class Movies
{
    private static final int VOTE_FOR     = 1;
    private static final int VOTE_NONE    = 0;
    private static final int VOTE_AGAINST = -1;
    
    public static Enumeration getMovieList()
    {
        String sql = "SELECT m.movieID, m.title, m.statusNew, p.username, v.type, p.status ";
        sql += "FROM Movies as m ";
        sql += "LEFT JOIN MovieVotes as v USING (movieID) ";
        sql += "LEFT JOIN Personal as p USING (userID) ";
        sql += "ORDER BY m.title ASC, p.username ASC";
        
        
        Vector data = new Vector();
        
        try
        {   
            ResultSet rs = SQL.query(sql);
            while (rs.next())
            {
                MovieVote mv = new MovieVote();
                mv.movieID   = rs.getInt("m.movieID");
                mv.title     = rs.getString("m.title");
                mv.statusNew = rs.getInt("m.statusNew");
                mv.userName  = rs.getString("p.username");
                mv.vote      = rs.getInt("v.type");
                mv.userStatus= rs.getString("p.status");
                
                data.addElement(mv);
            }
        }   catch (SQLException sql_e)
        {   System.out.println(sql_e);
        }
        
        return data.elements(); 
    }
    
    public static void setVote(int in_userId, int in_movieId, int in_type)
    { 
        SQL.update("DELETE FROM MovieVotes WHERE movieID=" + in_movieId + " AND userID=" + in_userId);
        SQL.update("REPLACE INTO MovieVotes (movieID, userID, type) VALUES(" + in_movieId + ", " + in_userId + ", " + in_type + ")");
    }
    
    public static int getVote(int in_userId, int in_movieId)
    { 
        int retVal = 0;
        
        try
        {   
            ResultSet rs = SQL.query("SELECT type FROM MovieVotes WHERE userID=" + in_userId + " AND movieID =" + in_movieId);
            retVal = rs.getInt("type");
        }   catch (SQLException sql_e)
        {   sql_e.printStackTrace();
        }
        
        return retVal;
    }
}
