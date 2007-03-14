package tnmc;

import java.awt.*;
import javax.swing.*;

public class MainPanel extends JPanel
{
    MenuPanel    m_menuPanel;
    
    LoginPanel   m_loginPanel;
    HomePanel    m_homePanel;
    
    JPanel      m_cardPanel;
    
	public MainPanel()
    {
        setOpaque(true);
        
        setLayout(new BorderLayout());

        m_menuPanel = new MenuPanel(this);
             
   
        JPanel mainP = new JPanel();
        mainP.setLayout(new BorderLayout());
     
        m_loginPanel = new LoginPanel(this);
        m_homePanel = new HomePanel(this);
        
        m_cardPanel = new JPanel();
        m_cardPanel.setBackground(Color.white);
        m_cardPanel.setLayout(new CardLayout());
        
        m_cardPanel.add(m_loginPanel, "LOGIN");
        m_cardPanel.add(m_homePanel, "HOME");
        
        showCard("LOGIN");
        
        JScrollPane scrollP = new JScrollPane();
        scrollP.setPreferredSize(new Dimension(500, 300));
        scrollP.setViewportView(m_cardPanel);
        
        mainP.add(scrollP, "Center");
        mainP.add(m_menuPanel, "East");
        
        add(new BorderPanel(), "West");
        add(mainP, "Center");
        add(new BorderPanel(), "East");
        
    }
    
    public void showCard(String in_cardName)
    {
        ((CardLayout)m_cardPanel.getLayout()).show(m_cardPanel, in_cardName);
        if (in_cardName.equals("HOME"))
            m_homePanel.refresh();
    }
    
    public void login()
    {
        m_menuPanel.setMenuState(MenuPanel.STATE_LOGIN);
        showCard("HOME");
    }
    
    public void logout()
    {
        m_menuPanel.setMenuState(MenuPanel.STATE_LOGOUT);
        showCard("LOGIN");
    }
}
