#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;

require 'pics/PICS.pl';


#############
### Main logic

&db_connect();
&header();

&show_pic_rating_guide

&footer();
&db_disconnect();


sub show_pic_rating_guide{
    
    print qq {
      <b>Content:</b><br>
      Content refers to what's in the picture, both the people and the atistry.. Assume that the quality of the picture is perfect, there's no blurryness, no smudges, no double images, lighting isn't off, the flash fired, etc, etc..
      <ol>
          <li value="2"><b>Award-winner.</b> Beautiful picture, attractive people, an artfully arranged image, or maybe it just captures the moment.. there's sothing about this picture that really stands out.
          <li value="1"><b>Great.</b> This is a picture that people will want to see.
          <li value="0"><b>Average.</b> nothing special, nothing wrong.
          <li value="-1"><b>Below Average.</b> There's something wrong with this pic. someone's back is turned, it's at an ugly angle, there's a camera strap dangling across the middle, it's the 4th picture in a row of the exact same thing..
          <li value="-2"><b>Not showable.</b> Pics labled -2 won't ever be seen by most people. Typically either blackmail material, or a waste of electrons. (ie a <i>really ugly</i> picture of someone, or a shot of the ground, sky or lenscap)
      </ol>

      <p>
      <b>Image:</b><br>
      Image is all about the quality of the pixels. is it out of focus? is it too dark? too light? smudged? double images? do people have 4 eyes and 3 mouthes? Is is grainy?
      <ol>
          <li value="2"><b>Perfect.</b> Just like being there.
          <li value="0"><b>Nice/average.</b> All things considered, there's nothing <i>really</i> wrong with this pic
          <li value="-1"><b>Not so nice.</b> There's something wrong with this pic, but it's still recognizeable.

          <li value="-2"><b>Garbage.</b> Can't really determine what's what. Seriously over exposed, underexposed, or otherwise useless.

      </ol>

        
        
        
    }; 

}
