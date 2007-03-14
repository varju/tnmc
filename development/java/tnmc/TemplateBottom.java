package tnmc;

import java.awt.*;
import javax.swing.*;

public class TemplateBottom extends JPanel
{
	public TemplateBottom()
    {
        setOpaque(false);
        
        //setLayout(new FlowLayout(FlowLayout.CENTER, 0, 0));
        setLayout(new BoxLayout(this, BoxLayout.X_AXIS));
        
        ImageIcon botLeftImage = new ImageIcon("images/bottom_left.gif");
        ImageIcon botCenterImage = new ImageIcon("images/bottom_center.gif");
        ImageIcon botRightImage = new ImageIcon("images/bottom_right.gif");

        add(new JLabel(botLeftImage));
        
        /*
        JButton centerButton = new JButton("site info", botCenterImage);
        centerButton.setHorizontalTextPosition(SwingConstants.CENTER);
        centerButton.setOpaque(false);
        centerButton.setBorderPainted(false);
        centerButton.setContentAreaFilled(false);
        centerButton.setFocusPainted(false);
        centerButton.setMargin(new Insets(0, 0, 0, 0));
        
        add(centerButton);
        */
        
        JLabel centerLabel = new JLabel("site info", botCenterImage, SwingConstants.CENTER);
        centerLabel.setForeground(Color.black);
        centerLabel.setHorizontalTextPosition(SwingConstants.CENTER);
        
        add(Box.createHorizontalGlue());
        
        add(centerLabel);
        add(new JLabel(botRightImage));
    }
}
