package tnmc;

import java.awt.*;
import javax.swing.*;

public class TNMC extends JFrame
{
    private static TNMC s_instance = null;
    
    private static int s_loginId = -1;
    private static String s_loginName = null;
    
    private TemplateTop m_templateTop;

	public TNMC()
    {
        s_instance = this;
        setupGUI();
        pack();
        setVisible(true);
    }
    
    public static TNMC getInstance()
    {   return s_instance;
    }
    
    static
    {
        try 
        { UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (Exception e) 
        { System.err.println("Couldn't use the system look and feel: " + e);
        }
    
        // This is to get around some of the option pane stuff, the real
        // button settings are in QuizButton.
        UIManager.put("Button.background", Color.white);
        //UIManager.put("Button.foreground", bgColor);
        UIManager.put("Button.foreground", Color.blue);
    
        UIManager.put("Panel.background", Color.white);
        UIManager.put("Label.foreground", Color.black);
        //UIManager.put("Label.background", bgColor);
    
        //UIManager.put("TextField.background", Color.white);
        //UIManager.put("Table.background", bgColor);
        //UIManager.put("Table.foreground", fgColor);
    
        //UIManager.put("Table.font", new Font("Arial", Font.BOLD, 12));
        UIManager.put("Label.font", new Font("Verdana", Font.PLAIN, 10));
        UIManager.put("Button.font", new Font("Verdana", Font.BOLD, 12));
        //UIManager.put("TitledBorder.titleColor", fgColor);
    
        //UIManager.put("OptionPane.background", bgColor);
        //UIManager.put("OptionPane.foreground", fgColor);
    
        //UIManager.put("List.background", bgColor);
        //UIManager.put("List.foreground", fgColor);
        //UIManager.put("List.font", new Font("Arial", Font.BOLD, 12));
    
        /*
        UIManager.put("Table.selectionForegound", fgColor);
        UIManager.put("Table.selectionBackgound", bgColor);
    
        UIManager.put("TextArea.selectionForegound", fgColor);
        UIManager.put("TextArea.selectionBackgound", bgColor);
        */

    }
    
    private void setupGUI()
    {
        Container pane = this.getContentPane();
        pane.setLayout(new FlowLayout(FlowLayout.CENTER));
        
        JPanel topLevelP = new JPanel();
        topLevelP.setLayout(new BorderLayout());
        
        pane.setBackground(new Color(128, 255, 0));
        pane.add(topLevelP);
         
        m_templateTop = new TemplateTop();
        
        topLevelP.add(m_templateTop, "North");
        topLevelP.add(new MainPanel(), "Center");
        topLevelP.add(new TemplateBottom(), "South");
 
    }
    
    public static void login(int in_userid, String in_username)
    {
        s_loginId = in_userid;
        s_loginName = in_username;
        if (s_instance != null)
        {   s_instance.m_templateTop.changeName(in_username);
        }
    }
    
    public static void logout()
    {
        s_loginId = -1;
        s_loginName = null;
        if (s_instance != null)
            s_instance.m_templateTop.setName("");
    }
    
    public static int getLoginId()
    {   
        return s_loginId;
    }
    
    public static String getLoginName()
    {
        return s_loginName;
    }
    
    public static void main (String[] args)
	{
		new TNMC();
	}
}
