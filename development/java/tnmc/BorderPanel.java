package tnmc;

import java.awt.*;
import javax.swing.*;

public class BorderPanel extends JPanel
{
	public BorderPanel()
    {
        setLayout(new FlowLayout(FlowLayout.CENTER, 0, 0));
        
        ImageIcon borderImage = new ImageIcon("images/border.gif");
        add(new JLabel(borderImage));
        
    }
}
