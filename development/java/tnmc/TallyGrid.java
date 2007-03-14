package tnmc;

import java.awt.*;
import java.awt.event.*;
import java.sql.*;
import javax.swing.*;
import java.util.*;

import tnmc.sql.*;

public class TallyGrid extends JPanel
{  
    private static final int VOTE_FOR     = 1;
    private static final int VOTE_NONE    = 0;
    private static final int VOTE_AGAINST = -1;
    
    GridBagLayout m_layout;
    
	public TallyGrid()
    {   
        refresh();
    }
    
    public void refresh()
    {   
        this.removeAll();
        
        m_layout = new GridBagLayout();
        
        setLayout(m_layout);

        makeTitleBar();
        
        Enumeration rawdata = Movies.getMovieList();
        TreeMap data = new TreeMap();
        
        int oldMovieID = -1;
  
        while (rawdata.hasMoreElements())
        {   
            MovieVote tempmv = (MovieVote)rawdata.nextElement();
            if (tempmv.movieID != oldMovieID)
            {   data.put(tempmv.title, tempmv);
                oldMovieID = tempmv.movieID;
            }

            MovieVote movie = (MovieVote)data.get(tempmv.title);
            
            switch (tempmv.vote)
            {   case MovieVote.VOTE_FOR:
                    movie.votesFor.addElement(tempmv.userName);
                    break;
                case MovieVote.VOTE_AGAINST:
                    movie.votesAgainst.addElement(tempmv.userName);
                    break;
            }
        }

        Iterator i = data.values().iterator();
        
        while (i.hasNext())
        {
            MovieVote m = (MovieVote)i.next();
            
           
            makeMovieEntry( m.movieID,
                            Movies.getVote(TNMC.getLoginId(), m.movieID),
                            m.title,
                            "UNUSED SO FAR",
                            m.votesFor.elements(),
                            m.votesAgainst.elements());
        
       
        
        }
    }

    private void makeTitleBar()
    {
        GridBagConstraints c = new GridBagConstraints();
        c.fill = GridBagConstraints.BOTH;
        c.weightx = 1.0;
        
        JLabel n_label = new JLabel("N");
        m_layout.setConstraints(n_label, c);
        add(n_label);
        
        JLabel undecided_label = new JLabel("?");
        m_layout.setConstraints(undecided_label, c);
        add(undecided_label);
        
        JLabel y_label = new JLabel("Y");
        m_layout.setConstraints(y_label, c);
        add(y_label);
        
        
        c.weightx = 10.0;
        JLabel title_label = new JLabel("Title");
        m_layout.setConstraints(title_label, c);
        add(title_label);
        
        c.weightx = 10.0;
        c.gridwidth = GridBagConstraints.REMAINDER;
        JLabel votes_label = new JLabel("Votes");
        m_layout.setConstraints(votes_label, c);
        add(votes_label);
        
    }
    
    private void makeMovieEntry(int in_movieID,
                                int in_vote,
                                String in_title,
                                String in_type,
                                Enumeration in_votesFor,
                                Enumeration in_votesAgainst)
    {
        final int movieID = in_movieID;
        
        GridBagConstraints c = new GridBagConstraints();
        
        c.fill = GridBagConstraints.BOTH;
        c.weightx = 1.0;
        
        JRadioButton NButton = new JRadioButton();
        NButton.setOpaque(false);
        if (in_vote == VOTE_AGAINST) NButton.setSelected(true);
        NButton.addActionListener( new ActionListener()
            { public void actionPerformed(ActionEvent e)
              { Movies.setVote(TNMC.getLoginId(), movieID, VOTE_AGAINST);
              }
            });
 
        JRadioButton UndecidedButton = new JRadioButton();
        UndecidedButton.setOpaque(false);
        if (in_vote == VOTE_NONE) UndecidedButton.setSelected(true);
        UndecidedButton.addActionListener( new ActionListener()
            { public void actionPerformed(ActionEvent e)
              { Movies.setVote(TNMC.getLoginId(), movieID, VOTE_NONE);
              }
            });
        
       
        JRadioButton YButton = new JRadioButton();
        YButton.setOpaque(false);
        if (in_vote == VOTE_FOR) YButton.setSelected(true);
        YButton.addActionListener( new ActionListener()
            { public void actionPerformed(ActionEvent e)
              { Movies.setVote(TNMC.getLoginId(), movieID, VOTE_FOR);
              }
            });
        
        
        // Group the radio buttons.
        ButtonGroup group = new ButtonGroup();
        group.add(YButton);
        group.add(UndecidedButton);
        group.add(NButton);
        
        
        m_layout.setConstraints(YButton, c);
        add(NButton);
        
        m_layout.setConstraints(UndecidedButton, c);
        add(UndecidedButton);

        m_layout.setConstraints(NButton, c);
        add(YButton);
        
        c.weightx = 10.0;
        JLabel title_label = new JLabel(in_title);
        m_layout.setConstraints(title_label, c);
        add(title_label);
        
        
        String forStr = new String();
        while (in_votesFor.hasMoreElements())
            forStr += in_votesFor.nextElement() + " ";
        
        String againstStr = new String();
        while (in_votesAgainst.hasMoreElements())
            againstStr += in_votesAgainst.nextElement() + " ";
        
        c.weightx = 5.0;
        JLabel for_label = new JLabel(forStr);
        m_layout.setConstraints(for_label, c);
        add(for_label);
        
        
        c.weightx = 5.0;
        c.gridwidth = GridBagConstraints.REMAINDER;
        JLabel against_label = new JLabel(againstStr);
        against_label.setForeground(Color.red);
        m_layout.setConstraints(against_label, c);
        add(against_label);
        
    }
}
