package tnmc;

import java.awt.*;
import javax.swing.*;

public class TemplateTop extends JPanel
{
    JLabel m_topCenterLabel;
    
	public TemplateTop()
    {
        setOpaque(false);
        
        //setLayout(new FlowLayout(FlowLayout.CENTER, 0, 0));
        setLayout(new BoxLayout(this, BoxLayout.X_AXIS));
        
        ImageIcon logoImage = new ImageIcon("images/logo/basic.gif");
        ImageIcon topCenterImage = new ImageIcon("images/top_center.gif");
        ImageIcon topRightImage = new ImageIcon("images/top_right.gif");

        add(new JLabel(logoImage));
        
        m_topCenterLabel = new JLabel("", topCenterImage, SwingConstants.CENTER);
        m_topCenterLabel.setHorizontalTextPosition(SwingConstants.CENTER);
        m_topCenterLabel.setForeground(Color.white);
        m_topCenterLabel.setFont(new Font("verdana", Font.BOLD, 28));
        
        add(Box.createHorizontalGlue());
        
        add(m_topCenterLabel);
        add(new JLabel(topRightImage));
    }
    
    public void changeName(String in_name)
    {
        m_topCenterLabel.setText(in_name);
    }
}
