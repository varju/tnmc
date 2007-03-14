package tnmc;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

public class MenuPanel extends JPanel implements ActionListener
{
    JButton menu_home;
    JButton menu_people;
    JButton menu_movies;
    JButton menu_prefs;
    JButton menu_logout;
    
    public static final int STATE_LOGOUT = 1;
    public static final int STATE_LOGIN  = 2;
    public static final int STATE_ADMIN  = 3;
    
    MainPanel m_parent;
    
	public MenuPanel(MainPanel in_parent)
    {
        m_parent = in_parent;
        
        setOpaque(true);
        
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        
        ImageIcon spacerImage = new ImageIcon("images/menu_spacer.gif");

        menu_home = new JButton("Home");
        menu_home.addActionListener(this);
        menu_home.setBorderPainted(false);
        menu_home.setOpaque(false);
        menu_home.setFocusPainted(false);
        
        
        menu_people = new JButton("People");
        menu_people.addActionListener(this);
        menu_people.setBorderPainted(false);
        menu_people.setOpaque(false);
        menu_people.setFocusPainted(false);
        
        
        menu_movies = new JButton("Movies");
        menu_movies.addActionListener(this);
        menu_movies.setBorderPainted(false);
        menu_movies.setOpaque(false);
        menu_movies.setFocusPainted(false);
        
        
        menu_prefs = new JButton("Preferences");
        menu_prefs.addActionListener(this);
        menu_prefs.setBorderPainted(false);
        menu_prefs.setOpaque(false);
        menu_prefs.setFocusPainted(false);
        
        
        menu_logout = new JButton("Logout");
        menu_logout.addActionListener(this);
        menu_logout.setBorderPainted(false);
        menu_logout.setOpaque(false);
        menu_logout.setFocusPainted(false);
        
        
        
        
        
        add(new JLabel(spacerImage));
        
       
        add(menu_home);
        add(menu_people);
        add(menu_movies);
        add(menu_prefs);
        add(menu_logout);
        
        setBackground(new Color(255, 255, 127));
        
        
        setMenuState(STATE_LOGOUT);
    }
    
    public void setMenuState(int in_menuState)
    {
        switch (in_menuState)
        {   case STATE_LOGOUT:
                menu_home.setVisible(false);
                menu_people.setVisible(false);
                menu_movies.setVisible(false);
                menu_prefs.setVisible(false);
                menu_logout.setVisible(false);
                break;
             
            case STATE_ADMIN:
              
            case STATE_LOGIN:
                menu_home.setVisible(true);
                menu_people.setVisible(true);
                menu_movies.setVisible(true);
                menu_prefs.setVisible(true);
                menu_logout.setVisible(true);
                break;
                
        }
    }
    
    public void actionPerformed(ActionEvent e)
    {
        if (e.getSource() == menu_logout)
        {
            TNMC.logout();
            m_parent.logout();
        }
    }
}
