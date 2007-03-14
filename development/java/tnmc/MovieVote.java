package tnmc;

import java.util.*;

public class MovieVote
{
    public static final int VOTE_FOR     = 1;
    public static final int VOTE_NONE    = 0;
    public static final int VOTE_AGAINST = -1;
    
    public int       movieID;
    public String    title;
    public int       statusNew;
    
    public String    userName;
    public String    userStatus;
    public int       vote;
    
    public Vector    votesFor;
    public Vector    votesAgainst;
    
    public MovieVote ()
    {
        votesFor = new Vector();
        votesAgainst = new Vector();
    }
}
