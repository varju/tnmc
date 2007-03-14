package tnmc;

import java.awt.*;
import java.awt.event.*;
import java.sql.*;
import javax.swing.*;

import tnmc.sql.*;

public class HomePanel extends JPanel implements Refreshable
{  
    private MainPanel m_parent;
    
    private TallyGrid m_tallyGrid;
    
	public HomePanel(MainPanel in_parent)
    {   
        m_parent = in_parent;
        
        m_tallyGrid = new TallyGrid();
        
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        
        add(new SectionPanel("Current Movie"));
        add(new CurrentMoviePanel());
        add(new SectionPanel("Bulletins"));
        add(m_tallyGrid);
        
    }
    
    public void refresh()
    {
        m_tallyGrid.refresh();
    }
}
