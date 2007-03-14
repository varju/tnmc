package tnmc;

import java.awt.*;
import java.awt.event.*;
import java.sql.*;
import javax.swing.*;

import tnmc.sql.*;

public class LoginPanel extends JPanel
{  
    JComboBox m_nameList;
    JPasswordField m_passwordField;
    
    private MainPanel m_parent;
    
	public LoginPanel(MainPanel in_parent)
    {   
        m_parent = in_parent;
        
        setLayout(new FlowLayout(FlowLayout.LEFT));
        
        m_nameList = new JComboBox();
        m_nameList.setFont(new Font("Arial", Font.PLAIN, 10));
        
        m_passwordField = new JPasswordField(15);
        m_passwordField.setEchoChar('*');
        m_passwordField.addActionListener(new ActionListener()
            {   public void actionPerformed(ActionEvent e)
                {   login();
                }
            });
        
        JButton loginBtn = new JButton("Login");
        loginBtn.addActionListener(new ActionListener()
            {   public void actionPerformed(ActionEvent e)
                {   login();
                }
            });
        
        ResultSet personalData = SQL.query("SELECT username FROM Personal ORDER BY username");
        
        try
        {   while (personalData.next()) 
            {
                m_nameList.addItem(personalData.getString("username")); 
            }
        }   catch (SQLException sql_e)
        {   sql_e.printStackTrace();
        }
        
        add(m_nameList);
        add(m_passwordField);
        add(loginBtn);
    }
    
    private boolean login()
    {
        boolean fail = true;
        
        String userName = (String)m_nameList.getSelectedItem();
        String password = new String(m_passwordField.getPassword());
        int userid = -1;
        
        ResultSet rs = SQL.query("SELECT password, userid FROM Personal WHERE username='" + userName + "'");
        
        try
        {   rs.next();
            userid = rs.getInt("userid");
            
            if (password.equals(rs.getString("password")))
                fail = false;
        }   catch (SQLException sql_e)
        {   sql_e.printStackTrace();
        }
        
        System.out.println(fail);
        if (!fail)
        {   TNMC.login(userid, userName);
            m_parent.login();
        }
        
        return fail;
    }
}
