package tnmc;

import java.awt.*;
import javax.swing.*;

public class SectionPanel extends JPanel
{  
	public SectionPanel(String in_title)
    {   
        setLayout(new FlowLayout(FlowLayout.LEFT, 0, 0));
        setBackground(new Color(68, 136, 0));
        
        JLabel titleLabel = new JLabel(in_title);
        titleLabel.setOpaque(false);
        titleLabel.setForeground(Color.white);

        add(titleLabel);
        
        setPreferredSize(new Dimension(300, 20));
    }
}
